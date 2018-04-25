function tf = issortedrows(T,varargin)
%ISSORTEDROWS TRUE for a sorted table.
%   TF = ISSORTEDROWS(A) returns TRUE if the rows of table A are sorted in
%   ascending order by all variables in A, namely, returns TRUE if A and
%   SORTROWS(A) are identical.
%
%   TF = ISSORTEDROWS(A,VARS) checks if the rows of table A are sorted
%   by the variables specified by VARS. VARS is a positive integer, a
%   vector of positive integers, a variable name, a cell array containing
%   one or more variable names, or a logical vector. VARS can also include
%   the name of the row dimension, i.e. A.Properties.DimensionNames{1}, to
%   check if A is sorted by row names as well as by data variables. By
%   default, the row dimension name is 'Row'.
%
%   VARS can also contain a mix of positive and negative integers.  If an
%   element of VARS is positive, the corresponding variable in A will be
%   sorted in ascending order; if an element of VARS is negative, the
%   corresponding variable in A will be sorted in descending order.  These
%   signs are ignored if you provide the MODE input described below.
%
%   TF = ISSORTEDROWS(A,'RowNames') checks if A is sorted by the row names.
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION) checks if the rows are sorted
%   according to the direction(s) specified by MODE:
%       'ascend'          - (default) Checks if data is in ascending order.
%       'descend'         - Checks if data is in descending order.
%       'monotonic'       - Checks if data is in either ascending or
%                           descending order.
%       'strictascend'    - Checks if data is in ascending order and does
%                           not contain duplicate or missing elements.
%       'strictdescend'   - Checks if data is in descending order and does
%                           not contain duplicate or missing elements.
%       'strictmonotonic' - Checks if data is in either ascending or
%                           descending order and does not contain duplicate
%                           or missing elements.
%   You can also use a different direction for each variable specified by
%   VARS, for example, ISSORTEDROWS(A,[2 3],{'ascend' 'descend'}).
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION,'MissingPlacement',M) specifies
%   where missing elements (NaN/NaT/<undefined>/<missing>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements placed first.
%       'last'  - Missing elements placed last.
%
%   TF = ISSORTEDROWS(A,VARS,DIRECTION,...,'ComparisonMethod',C) specifies
%   how complex numbers are sorted. The comparison method C must be:
%       'auto' - (default) Checks if real numbers are sorted according to
%                'real', and complex numbers according to 'abs'.
%       'real' - Checks if data is sorted according to REAL(A). For
%                elements with equal real parts, it also checks IMAG(A).
%       'abs'  - Checks if data is sorted according to ABS(A). For elements
%                with equal magnitudes, it also checks ANGLE(A).
%
%   See also SORTROWS, UNIQUE.

%   Copyright 2016-2017 The MathWorks, Inc.

[vars,varData,sortMode,sortModeStrs,nvPairs] = sortrowsFlagChecks(true,T,varargin{:});

if isempty(vars)
    % Ensure consistency with sortrows(T,[],...) not sorting and returning
    % T, i.e., issortedrows(sortrows(T,[],...),[],...) returns true.
    tf = true;
    return
end

% Prepare the data for the sort check:
hasMultiColumnVars = false;
for jj = 1:numel(vars)
    V = varData{jj};
    % Same errors as in tabular.sortrows
    if ~ismatrix(V)
        error(message('MATLAB:table:issortedrows:NDVar',T.varDim.labels{vars(jj)}));
    elseif matlab.internal.datatypes.istabular(V)
        % Error gracefully when trying to sort tables of tables
        error(message('MATLAB:table:issortedrows:IssortedOnVarFailed',T.varDim.labels{vars(jj)},class(V)));
    end
    % Convert row labels to string because of no issortedrows support for cellstr.
    % No <missing> string here, because row labels cannot be empty ''.
    if iscellstr(V)
        if vars(jj) == 0
            varData{jj} = string(V);
        else
            error(message('MATLAB:table:issortedrows:CellstrVar',T.varDim.labels{vars(jj)}));
        end
    end
    hasMultiColumnVars = hasMultiColumnVars | (size(V,2) > 1);
end
if hasMultiColumnVars
    % Convert multi-column variables into separate columns to facilitate
    % tiebreak behavior for duplicate missing rows in matrix variables:
    varsOld     = vars;
    varDataOld  = varData;
    sortModeOld = sortMode;
    thisjj = 1;
    for jj = 1:numel(varsOld)
        V = varDataOld{jj};
        [mV,nV] = size(V);
        vars(thisjj:(thisjj+nV-1))     = varsOld(jj);
        varData(thisjj:(thisjj+nV-1))  = mat2cell(V,mV,ones(1,nV));
        sortMode(thisjj:(thisjj+nV-1)) = sortModeOld(jj);
        thisjj = thisjj+nV;
    end
end

% Perform issortedrows check starting with the first specified table
% variable and moving on to the next one if ties are present:
[tf,failInfo] = matlab.internal.math.issortedrowsFrontToBack(varData,sortMode,sortModeStrs,nvPairs{:});

% Throw helpful error message for unsupported table variables:
if ~isempty(failInfo)
    jj = failInfo.colNum;
    if vars(jj) == 0
        m = message('MATLAB:table:issortedrows:IssortedOnRowFailed');
    else
        m = message('MATLAB:table:issortedrows:IssortedOnVarFailed',T.varDim.labels{vars(jj)},class(varData{jj}));
    end
    throw(addCause(MException(m.Identifier,'%s',getString(m)),failInfo.ME));
end