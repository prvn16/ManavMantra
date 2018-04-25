function t = subsasgnDot(t,s,b,deleting)
%SUBSASGNDOT Subscripted assignment to a table.

%   Copyright 2012-2017 The MathWorks, Inc.

% '.' is assignment to or into a variable.  Any sort of subscripting
% may follow that, and row labels are inherited from the table.

import matlab.internal.datatypes.emptyLike
import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isScalarInt
subsType = matlab.internal.tabular.private.tabularDimension.subsType; % "import" for calls to subs2inds

if ~isstruct(s), s = struct('type','.','subs',s); end

% Check for deletion of entire variables, t.Var = [], or of columns/pages of a variable,
% t.Var(:,j) = []. deletion deeper that, e.g. t.Var(i).Field(...) = [] or t.Var{i}(...) = [],
% is handled by the assignment code path.
if nargin < 4
    % Short-circuit for performance before calling _isEmptySqrBrktLiteral. isequal is
    % more expensive than isnumeric, but avoids _isEmptySqrBrktLiteral in more cases. For
    % built-in types, s(2).type=='()' guarantees that length(s)==2, but for a var that is
    % itself a table, parens need not be the end, so need to check that.
    deleting = isnumeric(b) && isequal(b,[]) && builtin('_isEmptySqrBrktLiteral',b) ...
        && (isscalar(s) || ((length(s) == 2) && isequal(s(2).type,'()')));
end

t_nrows = t.rowDim.length;
t_nvars = t.varDim.length;

% Translate variable (column) name into an index. Avoid overhead of
% t.varDim.subs2inds as much as possible in this simple case.
varName = s(1).subs;
if isnumeric(varName)
    % Allow t.(i) where i is an integer
    varIndex = varName;
    if ~isScalarInt(varName,1)
        error(message('MATLAB:table:IllegalVarIndex'));
    end
    isNewVar = (varIndex > t_nvars);
    if isNewVar
        if deleting
            error(message('MATLAB:table:VarIndexOutOfRange'));
        elseif varIndex > t_nvars+1
            error(message('MATLAB:table:DiscontiguousVars'));
        else
            [~,~,~,~,updatedVarDim] = t.varDim.subs2inds(varIndex,subsType.assignment);
            varName = updatedVarDim.labels{varIndex};
        end
    end
elseif ischar(varName) && (isrow(varName) || isequal(varName,'')) % isCharString(varName)
    varIndex = find(strcmp(varName,t.varDim.labels));
    isNewVar = false; % assume for now, update below
    if isempty(varIndex)
        % Check against reserved names first as a failsafe against shadowing
        % .Properties by a dimension name.
        if ~deleting && t.varDim.checkReservedNames(varName) % one name, don't need to wrap with any()
            % Handle assignment to a property under the 'Properties' (virtual)
            % property, or to the entire 'Properties' property.
            if strcmp(varName,'Properties')
                try
                    if isscalar(s)
                        t = setProperties(t,b);
                    else
                        t = t.setProperty(s(2:end),b);
                    end
                catch ME
                    if ~isscalar(s) && strcmp(ME.identifier,'MATLAB:table:UnknownProperty')
                        propName = s(2).subs;
                        match = find(strcmpi(propName,t.propertyNames),1);
                        if ~isempty(match) % a property name. but with wrong case
                            match = t.propertyNames{match};
                            error(message('MATLAB:table:UnknownPropertyCase',propName,match));
                        else
                            throw(ME);
                        end
                    else
                        throw(ME);
                    end
                end
                return
            else % t.VariableNames or t.RowNames
                error(message('MATLAB:table:InvalidPropertyAssignment',varName,varName));
            end
        elseif strcmp(varName,t.metaDim.labels{1})
            % If it's the row dimension name, assign to the row labels
            varIndex = 0;
            % For assignments onto the row labels, accept any vector. For assignments
            % into, leave the RHS alone.
            if isscalar(s)
                if isvector(b), b = b(:); end
            elseif deleting % && ~isscalar(s)
                error(message('MATLAB:table:NestedSubscriptingWithDotRowsDeletion',t.metaDim.labels{1}));
            end
        elseif strcmp(varName,t.metaDim.labels{2})
            % If it's the vars dimension name, assign to t{:,:}. Deeper subscripting
            % is not supported, use explicit braces for that.
            if ~isscalar(s)
                error(message('MATLAB:table:NestedSubscriptingWithDotVariables',t.metaDim.labels{2}));
            end
            varIndex = -1;
        elseif deleting
            error(message('MATLAB:table:UnrecognizedVarNameDeleting',varName,varName));
        else
            isNewVar = true;
            t.varDim.makeValidName(varName,'error'); % error if invalid

            % If this is a new variable, it will go at the end.
            varIndex = t_nvars + 1;
            updatedVarDim = t.varDim.lengthenTo(varIndex,{varName});
        end
    end
else
    error(message('MATLAB:table:IllegalVarSubscript'));
end

% Handle empty assignment intended as deletion of an entire variable or of
% columns/pages/etc. of a variable.  Deletion of rows in a (single)
% variable is caught here and not allowed.  Other empty assignment
% syntaxes may be assignment to cells or may be deletion of things deeper
% in a non-atomic variable, neither is handled here.
if deleting
    % Syntax:  t.var = []
    %
    % Delete an entire variable.
    if isscalar(s)
        if varIndex > 0
            t.data(varIndex) = [];
            t.varDim = t.varDim.deleteFrom(varIndex);
        elseif varIndex == 0
            t.rowDim = t.rowDim.removeLabels(); % this might error
        else % varindex == -1
            varIndex = 1:t.varDim.length;
            t.data(varIndex) = [];
            t.varDim = t.varDim.deleteFrom(varIndex);
        end
    % Syntax:  t.var(:,...) = []
    %          t.var(rowIndices,...) = [] is illegal
    %
    % Delete columns/pages/etc. of a variable, with ':' as the first index
    % in subscript.  This may change the dimensionality of the variable,
    % but won't change the number of rows because we require ':' as the
    % first index.
    else % length(s) == 2
        % All vars in a table must have the same number of rows, so subscripted assignment
        % deletion on one var isn't allowed to remove rows: no linear indexing, and the
        % first subscript in 2- or N-D indexing, and all others except one, must be :.
        if isscalar(s(2).subs) ...
                || ~strcmp(s(2).subs{1},':') ... % ~tabular.iscolon(s(2).subs{1})
                || all(strcmp(s(2).subs,':')) % all(cellfun(@(c)tabular.iscolon(c),s(2).subs))
            error(message('MATLAB:table:EmptyAssignmentToVariableRows'));
        end
        
        var_j = t.data{varIndex};
        try %#ok<ALIGN>
            if isa(var_j,'tabular')
                var_j = var_j.subsasgnParens(s(2),[],false,true); % force dispatch to overloaded table subscripting
            else
                var_j(s(2).subs{:}) = [];
            end
        catch ME, throw(ME); end
        t.data{varIndex} = var_j;
    end
    
else
    updatedRowDim = [];
    
    % Syntax:  t.var = b
    %
    % Replace an entire variable.  It must have the right number of rows, unless
    % the LHS is 0x0.
    if isscalar(s)
        if size(b,1) ~= t_nrows && (t_nrows+t_nvars > 0)
            % If the assignment has the wrong number of rows, check for some
            % common mistakes to suggest what may have been intended
            if strcmpi(varName,'Properties') && isstruct(b) && isscalar(b)
                % Things like t.properties = scalarStruct
                str = getString(message('MATLAB:table:IntendedPropertiesAssignment'));
                error(message('MATLAB:table:RowDimensionMismatchSuggest',str));
            else
                match = find(strcmpi(varName,t.propertyNames),1);
                if ~isempty(match)
                    % Things like t.PropertyName = ...
                    match = t.propertyNames{match};
                    str = getString(message('MATLAB:table:IntendedPropertyAssignment',match,match));
                    error(message('MATLAB:table:RowDimensionMismatchSuggest',str));
                end
            end
            % Anything else, no suggestion. No point in checking for a case
            % insensitive match to an existing var, even with the correct case,
            % this would still be an illegal assignment
            error(message('MATLAB:table:RowDimensionMismatch'));
        end
        var_j = b;
        
    % Syntax:  t.var(rowIndices,...) = b
    %          t.var{rowIndices,...} = b
    %          t.var{rowIndices,...} = [] (this is assignment, not deletion)
    %          t.var.field = b
    %
    % Assign to elements in a variable.  Assignment can also be used to
    % expand the variable's number of rows, or along another dimension.
    %
    % Cell indexing, e.g. t.var{rowIndices,...}, or a reference to a
    % field, e.g. t.var.field, may also be followed by deeper levels of
    % subscripting. Cannot create a new var implicitly by deeper indexing.
    else % ~isscalar(s)
        if isNewVar && (length(s) > 2) && ~isequal(s(2).type,'.')
            % If the assignment is not to an existing var, check for some common
            % mistakes to suggest what may have been intended
            match = find(strcmpi(varName,t.varDim.labels),1);
            if ~isempty(match)
                % An existing variable name, but with wrong case
                match = t.varDim.labels{match};
                str = getString(message('MATLAB:table:IntendedVarAssignment',match));
                error(message('MATLAB:table:InvalidExpansionDotDepthSuggest',str));
            end
            % Anything else, no suggestion
            error(message('MATLAB:table:InvalidExpansionDotDepth'));
        end
        
        if isequal(s(2).type,'.') % dot indexing into variable
            % If the assignment is not to an existing var, check for some common
            % mistakes to suggest what may have been intended
            if isNewVar
                if strcmpi(varName,'Properties') && isCharString(s(2).subs)
                    % Things like t.properties.name
                    str = getString(message('MATLAB:table:IntendedPropertiesAssignment'));
                    error(message('MATLAB:table:InvalidExpansionDotSuggest',str));
                else
                    match = find(strcmpi(varName,t.varDim.labels),1);
                    if ~isempty(match)
                        % An existing variable name, but with wrong case
                        match = t.varDim.labels{match};
                        str = getString(message('MATLAB:table:IntendedVarAssignment',match));
                        error(message('MATLAB:table:InvalidExpansionDotSuggest',str));
                    else
                        % Anything else, no suggestion
                        error(message('MATLAB:table:InvalidExpansionDot'));
                    end
                end
            end
            if varIndex > 0
                var_j = t.data{varIndex};
            elseif varIndex == 0
                var_j = t.rowDim.labels;
            else % varIndex == -1
                assert(false);
            end
        else % () or {} subscripting into variable
            % Initialize a new var, or extract an existing var.
            if isNewVar
                % Start the new var out as an Nx0 empty of b's class, with the same
                % number of rows as the table.
                if isequal(s(2).type,'{}')
                    % {} subscripting on the new var indicates it should be a cell
                    % with contents being assigned.
                    var_j = cell(t_nrows,0);
                else
                    var_j = emptyLike([t_nrows,0],'Like',b);
                end
                
                % If the table has no rows, the new var was initialized as 0x0 and
                % a colon subscript in the first dim would be misinterpreted. Create
                % explicit row indices instead.
                if t_nrows == 0 && tabular.iscolon(s(2).subs{1})
                    if t_nvars == 0
                        % If the table is 0x0, a colon subscript in the first dim should
                        % mean "height of the RHS". t.rowDim.subs2inds would think ':' means
                        % "height of t", so create explicit row indices to let it know how
                        % big : really is.
                        s(2).subs{1} = 1:size(b,1);
                    else
                        % Otherwise, a colon subscript in the first dim should mean "height
                        % of the table", and the RHS must have matching height. var_j is
                        % initialized to have t_nrows rows to match the table, but when t_nrows
                        % is 0, var_j is initialized as 0x0, and var_j's subsasgn would treat
                        % : as "height of the RHS" and not do the proper size checking. Create
                        % explicit row indices to make sure the RHS's height is checked.
                        %
                        s(2).subs{1} = 1:t_nrows;
                    end
                end
                % If the table has one or more rows, a colon subscript in the first dim always
                % means "height of the table", and that subscript can be left alone.
                
                % Convert any trailing colon subscripts into explicit indices with length
                % inherited from the RHS.
                for k = 2:length(s(2).subs)
                    if tabular.iscolon(s(2).subs{k})
                        s(2).subs{k} = 1:size(b,k);
                    end
                end
            else
                if varIndex > 0
                    var_j = t.data{varIndex};
                elseif varIndex == 0
                    var_j = t.rowDim.labels;
                else % varIndex == -1
                    assert(false);
                end
            end
            
            subs1 = s(2).subs{1};
            haveLabelSubscripts = ~(isnumeric(subs1) || islogical(subs1) || tabular.iscolon(subs1));
            if haveLabelSubscripts
                % The variable inherits row labels from the table, translate to row indices. The
                % assignment may add rows, get the updated rowDim object with any new row labels. 
                % subs2inds returns the indices as a col vector, which prevents reshaping. This
                % is fine because the var is constrained inside the table.
                [s(2).subs{1},~,~,~,updatedRowDim] = t.rowDim.subs2inds(subs1,subsType.assignment);
                % There are some linear indexing cases that should have row semantics, or that
                % are not even legal. In those cases s(2).subs{1} can't be interpreted as row
                % labels and so calling t.rowDim.subs2inds returns something completely
                % meaningless. Those cases will be identified and caught immediately below.
            else
                % t.rowDim.subs2inds will leave rowSubscripts alone in these cases, other than
                % making it a column, so avoid calling it for performance. Leave updateRowDim
                % empty, only need that in the row labels case.
                s(2).subs{1} = subs1(:);
            end
            
            if isscalar(s(2).subs) % linear indexing into the LHS
                % If the LHS is linear indexing, e.g. t.var(indices) = b or t.var{indices} = b,
                % and new elements will be created, there are cases where we need to force it to
                % grow as a column vector, because it would try to grow as a row vector.
                %
                % If the var is
                %    a scalar or a 0x0
                %    a new var (which is initialized to Nx0, including possibly 1x0)
                %    an Nx0 (N>1) or 0xM (M>1) empty matrix
                % add a column index so it grows as a column vector.
                if isscalar(var_j)
                    s(2).subs = [s(2).subs {1}];
                elseif iscolumn(var_j) % including 0x1
                    % If the var is already a column, linear indexing will have column semantics,
                    % leave the subscript alone. A scalar is a column, but need to force it to
                    % behave like one, so catch those above.
                elseif all(size(var_j)==0) || isNewVar
                    s(2).subs = [s(2).subs {1}];
                elseif ismatrix(var_j) && isempty(var_j) && ~isrow(var_j) % Nx0 or 0xM, excluding 1x0
                    % This case is analogous to what would happen in the workspace, except in table
                    % the assignment creates a column instead of a row.
                    s(2).subs = [s(2).subs {1}];
                    var_j = var_j(:); % make it a 0x1 column to be safe

                % By now var_j must be a row (possibly 1x0), a non-empty matrix, or an N-D array.
                elseif haveLabelSubscripts
                    % Numeric, logical, and colon subscripts have unambiguous meaning as in linear
                    % indexing regardless of the shape of the var being assigned into. But row
                    % labels have meaning only for column semantics, i.e. only if the var is already
                    % a column (including a 0x1), or if we've added a column index to force the
                    % result of the assignment to _become_ a column. Otherwise, linear indexing with
                    % row labels is an error.
                    error(message('MATLAB:table:InvalidLinearIndexing'));
                else
                    % If the var is a row, linear indexing has row semantics, let that happen.
                    % If the var is a non-empty matrix, or any N-D array, assignment using linear
                    % indexing is an ambiguous dimension error, let that happen at the actual
                    % assignment.
                end
            end
        end
        
        % Now let the variable's subsasgn handle the subscripting in
        % things like t.name(...) or  t.name{...} or t.name.attribute
        
        if length(s) == 2
            try %#ok<ALIGN>
                % If b is a built-in type, or the same class as var_j, call subsasgn directly
                % for fastest dispatch to var_j's (possibly overloaded) subscripting. Otherwise,
                % force dispatch to var_j's subscripting even when b is dominant. In most cases,
                % calling subsasgn via builtin guarantees dispatch on the first input. However,
                % if var_j is a table, builtin would dispatch to default, not overloaded,
                % subscripting, so use dot-method syntax.
                if isobject(b)
                    if isa(var_j,class(b)) % var_j first is fast when it is built-in
                        var_j = subsasgn(var_j,s(2),b); % dispatches correctly, even to tabular
                    elseif isa(var_j,'tabular')
                        var_j = var_j.subsasgn(s(2),b);
                    else
                        var_j = builtin('subsasgn',var_j,s(2),b);
                    end
                else
                    % If the RHS of the assignment into the table was a literal [], and the LHS
                    % target is t.Var or t.Var(...), that's already been recognized as subscripted
                    % assignment deletion, and handled correctly. A RHS that is a 0x0 double but not
                    % a literal [] should be treated as a genuine assignment, but the built-in
                    % subsasgn called here treats that as deletion when the LHS is a built-in type
                    % subscripted with (). Happily, assignment of any other empty double will have
                    % the desired effect, so turn b into a 0x1. The same must be done for '' (which
                    % "is equal" to []) to prevent it from deleting.
                    if isequal(b,[]) && ~isobject(var_j) && isequal(s(2).type,'()')
                        % One exception: subscripted assignment deletion other than t.Var=[] or
                        % t.Var(...)=[], such as t.Var(i).Field(...)=[] or t.Var{i}(...)=[], ends up
                        % here for delegation to var_j, so don't replace a RHS that _is_ a literal [].
                        if ischar(b) || ~builtin('_isEmptySqrBrktLiteral',b), b = b(:); end
                    end
                    var_j = subsasgn(var_j,s(2),b);
                end
            catch ME, throw(ME); end
        else % length(s) > 2
            % Trick the third and higher levels of subscripting in things like
            % t.Var{i}(...) etc. into dispatching to the right place even when
            % t.Var{i}, or something further down the chain, is itself a table.
            try %#ok<ALIGN>
                % See above comments.
                if isequal(b,[]) && isequal(s(end).type,'()')
                    if ischar(b) || ~builtin('_isEmptySqrBrktLiteral',b), b = b(:); end
                end
                var_j = matlab.internal.tabular.private.subsasgnRecurser(var_j,s(2:end),b);
            catch ME, rethrow(ME); end % point to the line in subsasgnRecurser
        end
    end
    
    % If this is a new variable, make it official.
    if isNewVar
        t.varDim = updatedVarDim;
    end
    
    % If an entire var was replaced or created, the new value was required to have
    % the same number of rows as the table.  However, when assigning _into_ a new
    % var, the assignment might create something shorter than the table, so check
    % for that and tallen the new var to match the table. Also, assigning into an
    % existing var that is Nx0 using linear indexing will turn it into a col that
    % might be shorter, so tallen it to match the table, but don't warn since that's
    % an implementation artifact. (Assigning into an existing var that is 0xM using
    % linear indexing will also turn it into a col, but it can never be shorter.)
    % (Historically, a var could also get shorter by assigning a field to a
    % non-struct, or by assigning via a direct call to subsasgn into new elements of
    % _any_ matrix using linear indexing. Neither works that way now. Those would
    % have gotten fixed here too.)
    varLen = size(var_j,1);
    if varLen < t_nrows % t's original number of rows
        if isNewVar
            warning(message('MATLAB:table:RowsAddedNewVars'));
        end
        var_j = t.lengthenVar(var_j,t_nrows);
    end
    if varIndex > 0
        t.data{varIndex} = var_j;
    elseif varIndex == 0
        t.rowDim = t.rowDim.setLabels(var_j);
    else % varIndex == -1
        t = t.subsasgnBraces({':' ':'},var_j);
    end
    
    % If the var being assigned to is now taller than the table, add rows to
    % the rest of the table, including row labels.  This might be because the
    % assignment lengthened an existing var, or because an "into" assignment
    % created a new var taller than the table.  Warn only if we have to lengthen
    % existing vars that have not been assigned to -- if there's currently only
    % one var in the table (which might be existing or new), don't warn about
    % any default values "filled in in the middle".
    if varLen > t_nrows % t's original number of rows
        if t.varDim.length > 1 % some existing vars were not assigned to
            warning(message('MATLAB:table:RowsAddedExistingVars'));
        end
        if isempty(updatedRowDim)
            t.rowDim = t.rowDim.lengthenTo(varLen);
        else
            t.rowDim = updatedRowDim;
        end
        t = t.lengthenTo(varLen); % updates nrows
    end
end
