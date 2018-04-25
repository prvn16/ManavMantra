function t = cell2table(c,varargin)
%CELL2TABLE Convert cell array to table.
%   T = CELL2TABLE(C) converts the M-by-N cell array C to an M-by-N table T.
%   CELL2TABLE vertically concatenates the contents of the cells in each column
%   of C to create each variable in T, with one exception: if a column of C
%   contains character vectors, then the corresponding variable in T is a
%   cell array of character vectors.
%
%   T = CELL2TABLE(C, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in C are converted.
%
%      'VariableNames'  A cell array of character vectors containing
%                       variable names for T.  The names must be valid
%                       MATLAB identifiers, and must be unique.
%      'RowNames'       A cell array of character vectors containing row
%                       names for T. The names need not be valid MATLAB
%                       identifiers, but must be unique.
%
%   See also TABLE2CELL, ARRAY2TABLE, STRUCT2TABLE, TABLE.

%   Copyright 2012-2016 The MathWorks, Inc.

if ~iscell(c) || ~ismatrix(c)
    error(message('MATLAB:cell2table:NDCell'));
end
[nrows,nvars] = size(c);

pnames = {'VariableNames' 'RowNames'};
dflts =  {            []         [] };
[varnames,rownames,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

% Each column of C becomes a variable in D
vars = tabular.container2vars(c);

if supplied.VariableNames
    haveVarNames = true;
else
    baseName = inputname(1);
    haveVarNames = ~(isempty(baseName) || (nvars == 0));
    if haveVarNames
        if size(c,2) == 1
            varnames = {baseName};
        else
            varnames = matlab.internal.datatypes.numberedNames(baseName,1:nvars);
        end
    end
end

if isempty(vars) 
    % create an empty table
    t = table.empty(nrows,nvars);
else
    dummyNames = matlab.internal.tabular.defaultVariableNames(1:nvars);
    t = table.fromScalarStruct(cell2struct(vars,dummyNames,2)); % cell -> scalarStruct -> table
end
if haveVarNames, t.Properties.VariableNames = varnames; end
if supplied.RowNames, t.Properties.RowNames = rownames; end
