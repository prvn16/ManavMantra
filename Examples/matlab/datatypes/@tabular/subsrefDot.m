function [b,varargout] = subsrefDot(t,s)
%SUBSREFDOT Subscripted reference for a table.

%   Copyright 2012-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isScalarInt

% '.' is a reference to a table variable or property.  Any sort of
% subscripting may follow.  Row labels for cascaded () or {} subscripting on
% a variable are inherited from the table.

% This method handles RHS subscripting expressions such as
%    t.Var
%    t.Var.Field
%    t.Var{rowindices} or t.Var{rowindices,...}
%    t.Var{rownames}   or t.Var{rownames,...}
% or their dynamic var name versions, and also when there is deeper subscripting such as
%    t.Var.Field[anything else]
%    t.Var{...}[anything else]
% However, dotParenReference is called directly for RHS subscripting expressions such as
%    t.Var(rowindices) or t.Var(rowindices,...)
%    t.Var(rownames)   or t.Var(rownames,...)
% or their dynamic var name versions, and also when there is deeper subscripting such as
%    t.Var(...)[anything else]

if ~isstruct(s), s = struct('type','.','subs',s); end

% Translate variable (column) name into an index. Avoid overhead of
% t.varDim.subs2inds in this simple case.
varName = s(1).subs;
if isnumeric(varName)
    % Allow t.(i) where i is an integer
    varIndex = varName;
    if ~isScalarInt(varIndex,1)
        error(message('MATLAB:table:IllegalVarIndex'));
    elseif varIndex > t.varDim.length
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
elseif ischar(varName) && (isrow(varName) || isequal(varName,'')) % isCharString(varName)
    varIndex = find(strcmp(varName,t.varDim.labels));
    if isempty(varIndex)
        % If there's no such var, it may be a reference to the 'Properties'
        % (virtual) property.  Handle those, but disallow references to
        % any property directly. Check this first as a failsafe against
        % shadowing .Properties by a dimension name.
        if strcmp(varName,'Properties')
            if isscalar(s)
                if nargout < 2
                    b = t.getProperties;
                else
                    nargoutchk(0,1);
                end
            else
                % If there's cascaded subscripting into the property, let the
                % property's subsref handle the reference. This may result in
                % a comma-separated list, so ask for and assign to as many
                % outputs as we're given. That is the number of outputs on
                % the LHS of the original expression, or if there was no LHS,
                % it comes from numArgumentsFromSubscript.
                try
                    if nargout < 2
                        b = t.getProperty(s(2:end));
                    else
                        [b,varargout{1:nargout-1}] = t.getProperty(s(2:end));
                    end
                catch ME
                    if strcmp(ME.identifier,'MATLAB:table:UnknownProperty')
                        propName = s(2).subs;
                        match = find(strcmpi(propName,t.propertyNames),1);
                        if ~isempty(match) % a property name, but with wrong case
                            match = t.propertyNames{match};
                            error(message('MATLAB:table:UnknownPropertyCase',propName,match));
                        else
                            throw(ME);
                        end
                    else
                        throw(ME);
                    end
                end
            end
            return
        elseif strcmp(varName,t.metaDim.labels{1})
            % If it's the row dimension name, return the row labels
            varIndex = 0;
        elseif strcmp(varName,t.metaDim.labels{2})
            % If it's the vars dimension name, return t{:,:}. Deeper subscripting
            % is not supported, use explicit braces for that.
            if ~isscalar(s)
                error(message('MATLAB:table:NestedSubscriptingWithDotVariables',t.metaDim.labels{2}));
            end
            varIndex = -1;
        elseif strcmpi(varName,'Properties') % .Properties, but with wrong case
            error(message('MATLAB:table:UnrecognizedVarNamePropertiesCase',varName));
        else
            match = find(strcmpi(varName,t.propertyNames),1);
            if ~isempty(match)
                match = t.propertyNames{match};
                if strcmp(varName,match) % a valid property name
                    error(message('MATLAB:table:IllegalPropertyReference',varName,varName));
                else % a property name, but with wrong case
                    error(message('MATLAB:table:IllegalPropertyReferenceCase',varName,match,match));
                end
            else
                match = find(strcmpi(varName,t.varDim.labels),1);
                if ~isempty(match) % an existing variable name
                    match = t.varDim.labels{match};
                    error(message('MATLAB:table:UnrecognizedVarNameCase',varName,match));
                elseif ~isempty(find(strcmp(varName,t.defaultDimNames{1}),1)) % trying to access row labels by default name
                    t.throwSubclassSpecificError('RowDimNameNondefault',varName, t.metaDim.labels{1})           
                else
                    methodList = methods(t);
                    match = find(strcmpi(varName,methodList),1);
                    if ~isempty(match) % a method name
                        match = methodList{match};
                        error(message('MATLAB:table:IllegalDotMethod',varName,match,match));
                    else % no obvious match
                        error(message('MATLAB:table:UnrecognizedVarName',varName));
                    end
                end
            end
        end
    end
else
    error(message('MATLAB:table:IllegalVarSubscript'));
end

if varIndex > 0
    b = t.data{varIndex};
elseif varIndex == 0
    b = t.rowDim.labels;
else % varIndex == -1
    b = t.extractData(1:t.varDim.length);
end

if isscalar(s)
    % If there's no additional subscripting, return the table variable.
    if nargout > 1
        nargoutchk(0,1);
    end
else
    s2 = s(2);
    if ~isequal(s2.type,'.') % t.Var(...) or t.Var{...}
        rowIndices = s2.subs{1};
        if isnumeric(rowIndices) || islogical(rowIndices) || tabular.iscolon(rowIndices)
            % Can leave these alone to save overhead of calling subs2inds
        else
            % Dot-parens or dot-braces subscripting might use row labels inherited from the
            % table, translate those to indices.
            if ~iscolumn(b) && isscalar(s2.subs)
                error(message('MATLAB:table:InvalidLinearIndexing'));
            end
            numericRowIndices = t.rowDim.subs2inds(rowIndices);
            % subs2inds returns the indices as a col vector, but subscripting on
            % a table variable (as opposed to on a table) should follow the usual
            % reshaping rules. Nothing to do for one (char) name, including ':', but
            % preserve a cellstr subscript's original shape.
            if iscell(rowIndices), numericRowIndices = reshape(numericRowIndices,size(rowIndices)); end
            s(2).subs{1} = numericRowIndices;
            s2 = s(2); % update the local copy
        end
    else
        % A reference to a property or field, so no row labels
    end
    
    % Now let the variable's subsref handle the remaining subscripts in things
    % like t.name(...) or  t.name{...} or t.name.property. This may return a
    % comma-separated list, so ask for and assign to as many outputs as we're
    % given. That is the number of outputs on the LHS of the original expression,
    % or if there was no LHS, it comes from numArgumentsFromSubscript.
    if length(s) == 2
        try %#ok<ALIGN>
            if nargout < 2
                b = subsref(b,s2); % dispatches correctly, even to tabular
            else
                [b,varargout{1:nargout-1}] = subsref(b,s2); % dispatches correctly, even to tabular
            end
        catch ME, throw(ME); end
    else % length(s) > 2
        % Trick the third and higher levels of subscripting in things like
        % t.Var{i}(...) etc. into dispatching to the right place when
        % t.Var{i}, or something further down the chain, is itself a table.
        try %#ok<ALIGN>
            if nargout < 2
                b = matlab.internal.tabular.private.subsrefRecurser(b,s(2:end));
            else
                [b,varargout{1:nargout-1}] = matlab.internal.tabular.private.subsrefRecurser(b,s(2:end));
            end
        catch ME, rethrow(ME); end % point to the line in subsrefRecurser
    end
end
