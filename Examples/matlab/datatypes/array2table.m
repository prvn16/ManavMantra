function t = array2table(x,varargin)
%ARRAY2TABLE Convert homogeneous array to table.
%   T = ARRAY2TABLE(A) converts the M-by-N array A to an M-by-N table T.
%   Each column of A becomes a variable in T.
%
%   NOTE:  A can be any type of array, including a cell array.  However, in that
%   case you probably want to use CELL2TABLE instead.  ARRAY2TABLE creates the
%   variables in T from each column of A.  If A is a cell array, ARRAY2TABLE
%   does not extract the contents of its cells -- T in this case is a table each
%   of whose variables is a column of cells.  To create a table from the
%   contents of the cells in A, use CELL2TABLE(A).
%
%   T = ARRAY2TABLE(X, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in X are converted.
%
%      'VariableNames'  A cell array of character vectors containing
%                       variable names for T.  The names must be valid
%                       MATLAB identifiers, and must be unique.
%      'RowNames'       A cell array of character vectors containing row
%                       names for T.  The names need not be valid MATLAB
%                       identifiers, but must be unique.
%
%   See also TABLE2ARRAY, CELL2TABLE, STRUCT2TABLE, TABLE.

%   Copyright 2012-2016 The MathWorks, Inc.

if ~ismatrix(x)
    error(message('MATLAB:array2table:NDArray'));
end
[nrows,nvars] = size(x);

pnames = {'VariableNames' 'RowNames'};
dflts =  {            {}         {} };
[varnames,rownames,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

if supplied.VariableNames
    haveVarNames = true;
else
    baseName = inputname(1);
    haveVarNames = ~(isempty(baseName) || (nvars == 0));
    if haveVarNames
        if nvars == 1
            varnames = {baseName};
        else
            varnames = matlab.internal.datatypes.numberedNames(baseName,1:nvars);
        end
    else
        varnames = matlab.internal.tabular.private.varNamesDim.dfltLabels(1:nvars);
    end
end

vars = mat2cell(x,nrows,ones(1,nvars));

if isempty(vars) 
    % Create an empty table with the correct dimensions.
    t = table.empty(nrows,nvars);
    % This checks that number of supplied var names matches number of variables (zero) to
    % throw a consistent error.
    if haveVarNames, t.Properties.VariableNames = varnames; end  
    if supplied.RowNames, t.Properties.RowNames = rownames; end
else
    % Each column of x becomes a variable in t
    t = table.init(vars,nrows,rownames,nvars,varnames);
end