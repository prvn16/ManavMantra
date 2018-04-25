function t = subsasgnParens(t,s,b,creating,deleting)
%SUBSASGNPARENS Subscripted assignment to a table.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.matricize
subsType = matlab.internal.tabular.private.tabularDimension.subsType; % "import" for calls to subs2inds

% '()' is assignment to a subset of a table.  Only dot subscripting
% may follow.

if nargin < 4, creating = false; end
if ~isstruct(s), s = struct('type','()','subs',{s}); end

if numel(s(1).subs) ~= t.metaDim.length
    error(message('MATLAB:table:NDSubscript'));
end

if ~isscalar(s)
    switch s(2).type
    case '()'
        error(message('MATLAB:table:InvalidSubscriptExpr'));
    case '{}'
        error(message('MATLAB:table:InvalidSubscriptExpr'));
    case '.'
        if creating
            error(message('MATLAB:table:InvalidSubscriptExpr'));
        end
        
        % Syntax:  t(rowIndices,varIndices).name = b
        % Syntax:  t(rowIndices,varIndices).name(...) = b
        % Syntax:  t(rowIndices,varIndices).name{...} = b
        % Syntax:  t(rowIndices,varIndices).name.field = b
        %
        % Assignment into a variable of a subarray.
        %
        % This may also be followed by deeper levels of subscripting.
        %
        % t(rowIndices,varIndices) must refer to rows and vars that exist, and
        % the .name assignment can't add rows or refer to a new variable.  This
        % is to prevent cases where the indexing beyond t(rowIndices,varIndices)
        % refers to things that are new relative to that subarray, but which
        % already exist in t itself.  So, cannot grow the table by an assignment
        % like this.
        %
        % This can be deletion, but it must be "inside" a variable, and not
        % change the size of t(rowIndices,varIndices).
        
        % Get the subarray, do the dot-variable assignment on that.
        try
            c = t.subsrefParens(s(1));
        catch ME
            outOfRangeIDs = {'MATLAB:table:RowIndexOutOfRange' 'MATLAB:table:UnrecognizedRowName' ...
                             'MATLAB:table:VarIndexOutOfRange' 'MATLAB:table:UnrecognizedVarName'};
            if any(strcmp(ME.identifier,outOfRangeIDs))
                error(message('MATLAB:table:InvalidExpansion'));
            else
                rethrow(ME);
            end
        end
        
        % Assigning to .Properties of a subarray is not allowed.
        if strcmp(s(2).subs,'Properties')
            error(message('MATLAB:table:PropertiesAssignmentToSubarray'));
        end
        
        % Check numeric before builtin to short-circuit for performance and
        % to distinguish between '' and [].
        nestedDeleting = isnumeric(b) && builtin('_isEmptySqrBrktLiteral',b);   
        b = c.subsasgnDot(s(2:end),b);
        
        % Changing the size of the subarray -- growing it by assignment or
        % deleting part of it -- is not allowed.
        if ~isequal(size(b),size(c))
            if nestedDeleting
                error(message('MATLAB:table:EmptyAssignmentToSubarrayVar'));
            else
                error(message('MATLAB:table:InvalidExpansion'));
            end
        end
        
        % Now let the simple () subscripting code handle assignment of the updated
        % subarray back into the original array.
        s = s(1);
    end
end

% If the RHS is (still) [], we are deleting a variable from the table.
if nargin < 5
    deleting = isnumeric(b) && builtin('_isEmptySqrBrktLiteral',b);
end

% If a new table is being created, or if the LHS is 0x0, then interpret
% ':' as the size of the corresponding dim from the RHS, not as nothing.
colonFromRHS = ~deleting && (creating || all(size(t)==0));

[b_nrows,b_nvars] = size(b);
t_nrowsExisting = t.rowDim.length;
t_nvarsExisting = t.varDim.length;

if colonFromRHS && tabular.iscolon(s(1).subs{1})
    rowIndices = 1:b_nrows;
    numRowIndices = b_nrows;
    maxRowIndex = b_nrows;
    isColonRows = true;
    t.rowDim = t.rowDim.createLike(b_nrows); % b's row names do not propagate to t
else
    % Translate row labels into indices (leave logical and ':' alone)
    if deleting
        [rowIndices,numRowIndices,maxRowIndex,isColonRows,t.rowDim] = ...
                               t.rowDim.subs2inds(s(1).subs{1},subsType.deletion);
    else
        [rowIndices,numRowIndices,maxRowIndex,isColonRows,t.rowDim] = ...
                               t.rowDim.subs2inds(s(1).subs{1},subsType.assignment);
    end
end

if colonFromRHS && tabular.iscolon(s(1).subs{2})
    varIndices = 1:b_nvars;
    numVarIndices = b_nvars;
    isColonVars = true;
    if iscell(b)
        t.varDim = t.varDim.createLike(b_nvars,t.varDim.defaultLabels(1:b_nvars));
    else
        t.varDim = b.varDim; % b's var names _do_ propagate to t
    end
else
    % Translate variable (column) names into indices (translate logical and ':')
    if deleting
        [varIndices,numVarIndices,~,isColonVars,t.varDim] = t.varDim.subs2inds(s(1).subs{2},subsType.deletion,t.data);
    else
        [varIndices,numVarIndices,~,isColonVars,t.varDim] = t.varDim.subs2inds(s(1).subs{2},subsType.assignment,t.data);
    end
end

% Syntax:  t(rowIndices,:) = []
%          t(:,varIndices) = []
%          t(:,:) = [] deletes all rows, but doesn't delete any vars
%          t(rowIndices,varIndices) = [] is illegal
%
% Deletion of complete rows or entire variables.
if deleting
    % Delete rows across all variables
    if isColonVars
        if isColonRows
            % subs2inds saw ':' and left t.rowDim alone, thinking it was t(:,varIndices) = [].
            % But it's t(:,:) = [], which should behave like t(1:n,:) = [], so remove all
            % rows as if it had been that.
            t.rowDim = t.rowDim.deleteFrom(rowIndices);
        end
        
        % Numeric indices and row labels can specify repeated LHS vars (logical and : can't).
        % Row labels have been translated to numeric indices, now remove any repeats.
        if isnumeric(rowIndices)
            rowIndices = unique(rowIndices);
            numRowIndices = length(rowIndices);
        end
        newNrows = t_nrowsExisting - numRowIndices;
        t_data = t.data;
        for j = 1:t_nvarsExisting
            var_j = t_data{j};
            if isa(var_j,'tabular')
                var_j = var_j.subsasgnParens({rowIndices ':'},[],false,true); %  % force dispatch to overloaded table subscripting
            elseif ismatrix(var_j)
                var_j(rowIndices,:) = []; % without using reshape, may not be one
            else
                sizeOut = size(var_j); sizeOut(1) = newNrows;
                var_j(rowIndices,:) = [];
                var_j = reshape(var_j,sizeOut);
            end
            t_data{j} = var_j;
        end
        t.data = t_data;
        
    % Delete entire variables
    elseif isColonRows
        varIndices = unique(varIndices); % subs2inds converts all types of var subscripts to numeric
        t.data(varIndices) = [];
        
    else
        error(message('MATLAB:table:InvalidEmptyAssignment'));
    end

% Syntax:  t(rowIndices,varIndices) = b
%
% Assignment from a table.  This operation is supposed to replace or
% grow at the level of the _table_.  So no internal reshaping of
% variables is allowed -- we strictly enforce sizes. In other words, the
% existing table has a specific size/shape for each variable, and
% assignment at this level must respect that.
else
    if isscalar(b)
        % Scalar expand a RHS that's single table element or cell (it may itself contain
        % a non-scalar) to the size of the target LHS subarray.
        b = repmat(b,numRowIndices,numVarIndices);
        [b_nrows,b_nvars] = size(b); %#ok<ASGLU> keep these current
    else
        if b_nrows ~= numRowIndices
            error(message('MATLAB:table:RowDimensionMismatch'));
        elseif b_nvars ~= numVarIndices
            error(message('MATLAB:table:VarDimensionMismatch'));
        end
    end
    
    wasCellRHS = false;
    if isa(b,'tabular')
        b_data = b.data;
    elseif iscell(b)
        if ~ismatrix(b)
            error(message('MATLAB:table:NDCell'));
        end
        b_data = tabular.container2vars(b);
        wasCellRHS = true;
    else
        % Raw values are not accepted as the RHS with '()' subscripting:  With a
        % single variable, you can use dot subscripting.  With multiple variables,
        % you can either wrap them up in a table, accepted above, or use braces
        % if the variables are homogeneous.
        error(message('MATLAB:table:InvalidRHS'));
    end
    
    % varIndices might contain repeated indices into t, but existingVarLocsInB and
    % newVarLocsInB (see below) always contain unique (and disjoint) indices into b.
    % In that case multiple vars in b will overwrite the same var in t, last one wins.
    existingVars = (varIndices <= t_nvarsExisting); % t's original number of vars
    existingVarLocsInB = find(existingVars); % vars in b being assigned to existing vars in t
    t_data = t.data;
    for j = existingVarLocsInB
        var_j = t_data{varIndices(j)};
        % The size of the RHS has to match what it's going into.
        try
            var_b = b_data{j};
            if ~ismatrix(var_b)            
                var_b = matricize(var_b);
            end
            % In cases where the whole var is moved, i.e. rowIndices is ':', this is faster, but a valid
            % RHS may not have same type or trailing size as the LHS var, and it's difficult to do the
            % right error checking - so do it as a subscripted assignment.
            % if isColonRows && isequal(sizeLHS,size(b_data{j}))) && isa(b_data{j},class(var_j))
            %     var_j = var_b;
            % else
            if isa(var_j,'tabular')
                var_j = var_j.subsasgnParens({rowIndices ':'},var_b); %  % force dispatch to overloaded table subscripting
            else
                var_j(rowIndices,:) = var_b;
            end
            % end
            % No need to check for size change, RHS and LHS are identical sizes.
            t_data{varIndices(j)} = var_j;
        catch ME
            sizeLHS = size(var_j); sizeLHS(1) = numRowIndices;
            if strcmp(ME.identifier,'MATLAB:invalidConversion') ...
                    || strcmp(ME.identifier,'MATLAB:UnableToConvert')
                if wasCellRHS && ischar(var_j) && iscellstr(var_b) %#ok<ISCLSTR>
                    % Give a specific error when tabular.container2vars has converted
                    % char inside a cell RHS into a cellstr.
                    error(message('MATLAB:table:CharAssignFromCellRHS'));
                else
                    % Otherwise preserve the conversion error.
                    rethrow(ME);
                end
            elseif prod(sizeLHS) ~= prod(size(b_data{j})) %#ok<PSIZE> avoid numel, it may return 1
                error(message('MATLAB:table:AssignmentDimensionMismatch', t.varDim.labels{varIndices(j)}));
            else
                rethrow(ME);
            end
        end
    end

    % Add new variables if necessary.  Note that b's varnames do not
    % propagate to a in () assignment, unless t is being created or grown
    % from 0x0.  They do for horzcat, though.
    newVarLocsInB = find(~existingVars); % vars in b being assigned to new vars in t
    newVarLocsInT = varIndices(~existingVars); % new vars being created in t (possibly repeats)
    if ~isempty(newVarLocsInB)
        % Warn if we have to lengthen the new variables to match the height of
        % the table. Don't warn about default values "filled in in the middle"
        % for these new vars.
        if maxRowIndex < t_nrowsExisting
            warning(message('MATLAB:table:RowsAddedNewVars'));
        end
        
        % Add cells for new vars being created, not including repeated LHS var subscripts.
        numUniqueNewVarsAssignedTo = length(unique(newVarLocsInT));
        t_data = [t_data cell(1,numUniqueNewVarsAssignedTo)];
        
        for j = newVarLocsInB
            var_b = b_data{j};
            if isColonRows
                var_j = var_b;
            else
                % Start the new variable out as 0-by-(trailing size of b),
                % then let the assignment add rows.
                var_j = repmat(var_b,[0 ones(1,ndims(var_b)-1)]);
                if isa(var_j,'tabular')
                    var_j = var_j.subsasgnParens({rowIndices ':'},matricize(var_b)); % force dispatch to overloaded table subscripting
                else
                    var_j(rowIndices,:) = matricize(var_b);
                end
            end
            % A new var may need to grow to fit the table
            if size(var_j,1) < t_nrowsExisting % t's original number of rows
                var_j = t.lengthenVar(var_j, t_nrowsExisting);
            end
            t_data{varIndices(j)} = var_j;
        end
        
        % Var-based properties need to be assigned from b to t.
        if ~iscell(b)
            t.varDim = t.varDim.moveProps(b.varDim,newVarLocsInB,newVarLocsInT);
        end
        % Detect conflicts between the new var names and the existing dim names.
        t.metaDim = t.metaDim.checkAgainstVarLabels(t.varDim.labels);
    end
    t.data = t_data;

    if (maxRowIndex > t_nrowsExisting) % t's original number of rows
        % If the vars being assigned to are now taller than the table, add rows
        % to the rest of the table, including row labels.  This might be because
        % the assignment lengthened existing vars, or because the assignment
        % created new vars taller than the table.  Warn only if we have to
        % lengthen existing vars that have not been assigned to -- if there's
        % currently only one var in the table (which might be existing or new),
        % don't warn about any default values "filled in in the middle".
        numUniqueExistingVarsAssignedTo = length(unique(varIndices(existingVars)));
        if numUniqueExistingVarsAssignedTo < t_nvarsExisting % some existing vars were not assigned to
            warning(message('MATLAB:table:RowsAddedExistingVars'));
        end
        t = t.lengthenTo(maxRowIndex);
    end
end
