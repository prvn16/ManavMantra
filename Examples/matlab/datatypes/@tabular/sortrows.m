function [b,idx] = sortrows(a,varargin)
%SORTROWS Sort rows of a table.
%   B = SORTROWS(A) returns a copy of the table A, with the rows sorted in
%   ascending order by all of the variables in A.  The rows in B are sorted
%   first by the first variable, next by the second variable, and so on.
%   Each variable in A must be a valid input to SORT, or, if the variable
%   has multiple columns, to the MATLAB SORTROWS function or to its own
%   SORTROWS method.
%
%   B = SORTROWS(A,VARS) sorts the rows in A by the variables specified by
%   VARS. VARS must be a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector. VARS can also include the name of the row dimension, i.e.
%   A.Properties.DimensionNames{1}, to sort by row names as well as by data
%   variables. By default, the row dimension name is 'Row'.
%
%   VARS can also contain a mix of positive and negative integers.  If an
%   element of VARS is positive, the corresponding variable in A will be
%   sorted in ascending order; if an element of VARS is negative, the
%   corresponding variable in A will be sorted in descending order.  These
%   signs are ignored if you provide the DIRECTION input described below.
%
%   B = SORTROWS(A,'RowNames') sorts the rows in A by the row names.
%
%   B = SORTROWS(A,VARS,DIRECTION) also specifies the sort direction(s):
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%   SORTROWS sorts A in ascending or descending order according to all
%   variables specified by VARS. You can also use a different direction for
%   each variable by specifying multiple 'ascend' and 'descend' directions,
%   for example, SORTROWS(X,[2 3],{'ascend' 'descend'}).
%   Specify VARS as 1:SIZE(A,2) to sort using all variables.
%
%   B = SORTROWS(A,VARS,DIRECTION,'MissingPlacement',M) specifies where to
%   place the missing elements (NaN/NaT/<undefined>/<missing>). M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements first.
%       'last'  - Places missing elements last.
%
%   B = SORTROWS(A,VARS,DIRECTION,'ComparisonMethod',C) specifies how to
%   sort complex numbers. The comparison method C must be:
%       'auto' - (default) Sorts real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Sorts according to REAL(A). Elements with equal real parts
%                are then sorted by IMAG(A).
%       'abs'  - Sorts according to ABS(A). Elements with equal magnitudes
%                are then sorted by ANGLE(A).
%
%   [B,I] = SORTROWS(A,...) also returns an index vector I which describes
%   the order of the sorted rows, namely, B = A(I,:).
%
%   See also ISSORTEDROWS, UNIQUE.

%   Copyright 2012-2017 The MathWorks, Inc.

[vars,varData,sortMode,sortModeStrs,varargin] = sortrowsFlagChecks(false,a,varargin{:});

% Sort on each index variable, last to first.  Since sort is stable, the
% result is as if they were sorted all together.
if isequal(vars,0) % fast special case for simple row labels cases
    rowLabels = varData{1};
    
    % If sorting by RowNames with no labels fast exit
    if (~a.rowDim.hasLabels)
        b = a;
        return
    end
    
    if sortMode == 1
        [~,idx] = sort(rowLabels,varargin{:});
    else % sortMode == 2
        if iscell(rowLabels)
            [~,idx] = sortrows(rowLabels,-1,varargin{:}); % cellstr does not support 'descend'.
        else
            [~,idx] = sort(rowLabels,'descend',varargin{:});
        end
    end
else
    idx = (1:a.rowDim.length)';
    for j = length(vars):-1:1
        var_j = varData{j};
        if ~ismatrix(var_j)
            error(message('MATLAB:table:sortrows:NDVar',a.varDim.labels{vars(j)}));
        elseif matlab.internal.datatypes.istabular(var_j)
            % Error gracefully when trying to sort tables of tables
            error(message('MATLAB:table:sortrows:SortOnVarFailed',a.varDim.labels{vars(j)},class(var_j)));
        end
        var_j = var_j(idx,:);
        % cell/sort is only for cellstr, use sortrows for cell always.
        if ~iscell(var_j) && isvector(var_j) && (size(var_j,2) == 1)
            try
                [~,ord] = sort(var_j,1,sortModeStrs{sortMode(j)},varargin{:});
            catch ME
                m = message('MATLAB:table:sortrows:SortOnVarFailed',a.varDim.labels{vars(j)},class(var_j));
                throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
            end
        else % multi-column, or cell
            % Sort by all columns, all either ascending or descending
            cols = (1:size(var_j,2)) * 2*(1.5-sortMode(j));
            try
                [~,ord] = sortrows(var_j,cols,varargin{:});
            catch ME
                m = message('MATLAB:table:sortrows:SortrowsOnVarFailed',a.varDim.labels{vars(j)},class(var_j));
                throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
            end
        end
        idx = idx(ord);
    end
end

b = a.subsrefParens({idx ':'});
