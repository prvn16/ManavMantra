function [varargout] = subsrefBraces(t,s)
%SUBSREFBRACES Subscripted reference for a table.

%   Copyright 2012-2014 The MathWorks, Inc.

subsType = matlab.internal.tabular.private.tabularDimension.subsType; % "import" for calls to subs2inds

% '{}' is a reference to the contents of a subset of a table.  If no
% subscripting follows, return those contents as a single array of whatever
% type they are.  Any sort of subscripting may follow.

if ~isstruct(s), s = struct('type','{}','subs',{s}); end

if numel(s(1).subs) ~= t.metaDim.length
    error(message('MATLAB:table:NDSubscript'));
end

% Translate row labels into indices (leaves logical and ':' alone)
[rowIndices,numRowIndices] = t.rowDim.subs2inds(s(1).subs{1});

% Translate variable (column) names into indices (translates logical and ':')
varIndices = t.varDim.subs2inds(s(1).subs{2},subsType.reference,t.data);

% Extract the specified variables as a single array.
if isscalar(varIndices)
    b = t.data{varIndices};
else
    b = t.extractData(varIndices);
end

% Retain only the specified rows.
if isa(b,'tabular')
    b = b.subsrefParens({rowIndices ':'}); % force dispatch to overloaded table subscripting
elseif ismatrix(b)
    b = b(rowIndices,:); % without using reshape, may not have one
else
    % The contents could have any number of dims.  Treat it as 2D to get
    % the necessary row, and then reshape to its original dims.
    outSz = size(b); outSz(1) = numRowIndices;
    b = reshape(b(rowIndices,:), outSz);
end

if isscalar(s)
    % If there's no additional subscripting, return the table contents.
    if nargout > 1
        % Output of table brace subscripting will always be scalar
        error(message('MATLAB:table:TooManyOutputsBracesIndexing'));
    end
    varargout{1} = b;
else
    if ~strcmp(s(2).type,'.')  % t{rows,vars}(...) or t{rows,vars}{...}
        rowIndices = s(2).subs{1};
        if isnumeric(rowIndices) || islogical(rowIndices) || tabular.iscolon(rowIndices)
            % Can leave these alone to save overhead of calling subs2inds
        else
            % The second level of braces-parens or braces-braces subscripting might use row
            % labels inherited from the table's rows, translate those to indices.
            rowIndices = t.rowDim.subs2inds(rowIndices);
            if (size(b,2)>1) && isscalar(s(2).subs)
                error(message('MATLAB:table:InvalidLinearIndexing'));
            end
            s(2).subs{1} = rowIndices;
        end
    else
        % A reference to a property or field, so no row labels
    end
    
    % Let b's subsref handle any remaining additional subscripting.  This may
    % return a comma-separated list when the cascaded subscripts resolve to
    % multiple things, so ask for and assign to as many outputs as we're
    % given. That is the number of outputs on the LHS of the original expression,
    % or if there was no LHS, it comes from numArgumentsFromSubscript.
    if length(s) == 2
        try %#ok<ALIGN>
            [varargout{1:nargout}] = subsref(b,s(2)); % dispatches correctly, even to tabular
        catch ME, throw(ME); end
    else % length(s) > 2
        % Trick the third and higher levels of subscripting in things like
        % t.Var{i}(...) etc. into dispatching to the right place when
        % t.Var{i}, or something further down the chain, is itself a table.
        try %#ok<ALIGN>
            [varargout{1:nargout}] = matlab.internal.tabular.private.subsrefRecurser(b,s(2:end));
        catch ME, rethrow(ME); end % point to the line in subsrefRecurser
    end
end
