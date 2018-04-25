function t = subsasgnBraces(t,s,b)
%SUBSASGNBRACES Subscripted assignment to a table.

%   Copyright 2012-2017 The MathWorks, Inc.

subsType = matlab.internal.tabular.private.tabularDimension.subsType; % "import" for calls to subs2inds

% '{}' is assignment to or into the contents of a subset of a table array.
% Any sort of subscripting may follow.

if ~isstruct(s), s = struct('type','{}','subs',{s}); end

if numel(s(1).subs) ~= t.metaDim.length
    error(message('MATLAB:table:NDSubscript'));
end

if ~isscalar(s)
    % Syntax:  t{rowIndices,varIndices}(...) = b
    %          t{rowIndices,varIndices}{...} = b
    %          t{rowIndices,varIndices}.name = b
    %
    % Assignment into contents of a table.
    %
    % t{rowIndices,varIndices} must refer to rows and vars that exist, and the
    % assignment on whatever follows that can't add rows or columns or otherwise
    % reshape the contents.  This avoids cases where the indexing beyond
    % t{rowIndices,varIndices} refers to things outside the subarray, but which
    % already exist in t itself.  So, cannot grow the table by an assignment
    % like this.  Even if the number of elements stayed the same, if the shape
    % of those contents changed, we wouldn't know how to put them back into the
    % original table.
    
    % Get the subarray's contents, and do the assignment on that.
    try
        c = t.subsrefBraces(s(1));
    catch ME
        outOfRangeIDs = {'MATLAB:table:RowIndexOutOfRange' 'MATLAB:table:UnrecognizedRowName' ...
                         'MATLAB:table:VarIndexOutOfRange' 'MATLAB:table:UnrecognizedVarName'};
        if any(strcmp(ME.identifier,outOfRangeIDs))
            error(message('MATLAB:table:InvalidExpansion'));
        else
            rethrow(ME);
        end
    end
    szOut = size(c);
    s2 = s(2:end);
    
    if ~strcmp(s(2).type,'.') % t{rows,vars}(...) = ... or t{rows,vars}{...} = ...
        rowIndices = s2(1).subs{1};
        if isnumeric(rowIndices) || islogical(rowIndices) || tabular.iscolon(rowIndices)
            % Can leave these alone to save overhead of calling subs2inds
        else
            % The second level of braces-parens or braces-braces subscripting might use row
            % labels inherited from the table's rows, translate those to indices.
            if (size(c,2)>1) && isscalar(s2(1).subs)
                error(message('MATLAB:table:InvalidLinearIndexing'));
            end
            rowIndices = t.rowDim.subs2inds(rowIndices);
            s2(1).subs{1} = rowIndices;
        end
    else
        % A reference to a property or field, so no row labels
    end
    
    % Let t{rowIndices,varIndices}'s subsasgn handle the cascaded subscripting.
    if isscalar(s2)
        try %#ok<ALIGN>
            % If b is a built-in type, or the same class as c, call subsasgn directly for
            % fastest dispatch to c's (possibly overloaded) subscripting. Otherwise, force
            % dispatch to c's subscripting even when b is dominant. In most cases, calling
            % subsasgn via builtin guarantees dispatch on the first input. However, if c is
            % a table, builtin would dispatch to default, not overloaded, subscripting, so
            % use dot-method syntax.
            if isobject(b)
                if isa(c,class(b)) % c first is fast when it is built-in
                    c = subsasgn(c,s2,b); % dispatches correctly, even to tabular
                elseif isa(c,'tabular')
                    c = c.subsasgn(s2,b);
                else
                    c = builtin('subsasgn',c,s2,b);
                end
            else
                c = subsasgn(c,s2,b);
            end
        catch ME, throw(ME); end
    else % ~isscalar(s2)
        % Trick the third and higher levels of subscripting in things like
        % t{i,j}(...) etc. into dispatching to the right place even when
        % t{i,j}, or something further down the chain, is itself a table.
        try %#ok<ALIGN>
            c = matlab.internal.tabular.private.subsasgnRecurser(c,s2,b);
        catch ME, rethrow(ME); end % point to the line in subsasgnRecurser
    end
    
    % The nested assignment is not allowed to change the size of the target.
    if ~isequal(size(c),szOut)
        error(message('MATLAB:table:InvalidContentsReshape'));
    end
    
    % Now let the simple {} subscripting code handle assignment of the updated
    % contents back into the original array.
    b = c;
    s = s(1);
end

% If the LHS is 0x0, then interpret ':' as the size of the corresponding dim
% from the RHS, not as nothing.
colonFromRHS = all(size(t) == 0);

% Translate variable (column) names into indices (translate ':' to 1:nvars)
if colonFromRHS && tabular.iscolon(s(1).subs{2})
    varIndices = 1:size(b,2);
else
    varIndices = t.varDim.subs2inds(s(1).subs{2},subsType.assignment,t.data);
end
existingVarLocs = find(varIndices <= t.varDim.length); % subscripts corresponding to existing vars
newVarLocs = find(varIndices > t.varDim.length);  % subscripts corresponding to new vars

% Syntax:  t{rowIndices,varIndices} = b
%
% Assignment to contents of a table.
colSizes = ones(1,length(varIndices));
colSizes(existingVarLocs) = cellfun(@(x)size(x,2),t.data(varIndices(existingVarLocs)));
% *** need to have subsasgnParens accept a row of cells to avoid the work of
% *** explicitly creating a table
if isscalar(b)
    t0 = table;
    b = t0.subsasgnDot({'Var1'},b); % avoid constructor arg list issues when b is a char row
else
    % We know the number of columns in each existing var, assume one column for
    % new vars.  If we have the right number of columns on the RHS, good.
    if size(b,2) ~= sum(colSizes)
        if (size(b,2) > sum(colSizes)) && isscalar(newVarLocs)
            % If we have too many columns, but there's only one new var, give that var
            % multiple columns.
            colSizes(newVarLocs) = size(b,2) - sum(colSizes(existingVarLocs));
        elseif isnumeric(b) && isequal(b,[]) && builtin('_isEmptySqrBrktLiteral',b)...
                    && isempty(newVarLocs) && (tabular.iscolon(s(1).subs{1}) || tabular.iscolon(s(1).subs{2}))
            % If we have the wrong number of columns, and this looks like an attempt at
            % deletion of existing contents, say how many columns were expected but also
            % give a helpful error suggesting parens subscripting. Assignment of [] can
            % never be deletion here, so if there's no colons or if there's an out of
            % range subscript, let the else handle it as true assignment.
            error(message('MATLAB:table:BracesAssignDelete',sum(colSizes)));
        else
            % Otherwise say how many columns were expected.
            error(message('MATLAB:table:WrongNumberRHSCols',sum(colSizes)));
        end
    end
    dimSz = num2cell(size(b)); dimSz{2} = colSizes;
    b_data = mat2cell(b,dimSz{:});
    b = table(b_data{:});
end
t = t.subsasgnParens(s,b,false);
