function t2 = rows2vars(t1,varargin)
%ROWS2VARS Reorient rows of table or timetable to be variables of output table.
%   T2 = ROWS2VARS(T1) reorients the rows of table or timetable T1, so that
%   they become variables in the output table T2. If rows2vars can
%   concatenate the contents of the rows of T1, then the corresponding
%   variables of T2 are arrays. Otherwise, the variables of T2 are cell
%   arrays. ROWS2VARS always returns a table, though T1 can be either a
%   table or a timetable. ROWS2VARS copies the names of the variables of T1
%   to a new variable of T2. If T1 has row names, they become the new
%   variable names of T2. Otherwise, ROWS2VARS generates default variable
%   names for T2 (Var1, Var2,...).
%   
%   T2 = ROWS2VARS(T1, 'PARAM', VAL, ...) allows you to specify optional
%   parameter name/value pairs to control how ROWS2VARS operates on T1.
%   Parameters are:
%
%       'VariableNamesSource' - Specify a variable name, numeric index, or
%                               logical vector to specify which single
%                               variable in T1 becomes the new
%                               VariableNames in T2.
%       'DataVariables'       - Select the variables to be reoriented. Other
%                               variables are dropped. DataVariables is a 
%                               positive integer, a vector of positive
%                               integers, a variable name, a cell array
%                               containing one or more variable names, or a
%                               logical vector.
%
%   The same variable cannot appear in both 'VariableNamesSource' and
%   'DataVariables' specifications.
%
% See also STACK, UNSTACK, JOIN, INNERJOIN, OUTERJOIN, INNER2OUTER

%   Copyright 2017 The MathWorks, Inc.

pnames = {'VariableNamesSource' 'DataVariables'};
dflts =  {                []                 ':'};
[varNamesSource,dataVars,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames,dflts,varargin{:});

% Provisionally name t2's dimensions using t1's dim names, flipped
%dimNames = t1.metaDim.labels([2 1]); % probably a bad choice
% start with the defaults
dfltDimNames = table.defaultDimNames;
dimNames = dfltDimNames;
nonDfltDimNames = ~strcmp(dfltDimNames,t1.metaDim.labels);
if nonDfltDimNames(1) % the row dims name becomes the var dims name if it's not the default ('rows')
    dimNames{2} = t1.metaDim.labels{1};
end
if nonDfltDimNames(2)
    dimNames{1} = t1.metaDim.labels{2};
end

% get dataVars first
if supplied.DataVariables
    varIndices = t1.getVarOrRowLabelIndices(dataVars); 
else
    varIndices = 1:t1.varDim.length;
end

% Remove the var to use as var names from t1
if supplied.VariableNamesSource
    asVarNames = t1.getVarOrRowLabelIndices(varNamesSource); 
    if ~isscalar(asVarNames)
        error(message('MATLAB:table:rows2vars:InvalidNewVarNamesSpec'))
    end
    varNames = t1.getVarOrRowLabelData(asVarNames);
    varNames = varNames{1};
    if ~supplied.DataVariables
        % given a variable for VariableNamesSource but DataVariables not
        % specified, use setdiff to get the data variables.
        varIndices = setdiff(varIndices,asVarNames);
    elseif any(asVarNames==varIndices)
        % else, the DataVariables must not include the VariableNameSource
        error(message('MATLAB:table:rows2vars:DataVarsIncludeVarNames'));
    end
    if asVarNames > 0
        % New var names are an old variable. Use this old variable's name
        % as the new 2nd dim name.
        dimNames{2} = t1.varDim.labels{asVarNames};
    end
elseif ~isempty(t1.rowDim.labels)
    varNames = t1.rowDim.labels;
else % Construct default var names.
    varNames = matlab.internal.tabular.private.varNamesDim.dfltLabels(1:t1.rowDim.length)'; % transpose to column vector of varnames for consistency
end

% Check if any variables are tabular, in order to throw a better error.
for ii=varIndices
    if isa(t1.data{ii},'tabular')
        % if nested tables, throw better error
        error(message('MATLAB:table:rows2vars:CannotTransposeTableInTable'))
    end
    sz = size(t1.data{ii});
    if any(sz(2:end) > 1) % check for multi-column/ND vars
        error(message('MATLAB:table:rows2vars:CannotTransposeMulticolumnVar'))
    elseif any(sz(2:end) < 1) % check for multi-column/ND vars
        error(message('MATLAB:table:rows2vars:CannotTransposeNoColumnVar'))
    end
end

try
    % Let braces create a homogeneous array if it can
    a = t1.subsrefBraces({':' varIndices});
catch ME
    if any(strcmp(ME.identifier,{'MATLAB:table:ExtractDataIncompatibleTypeError', 'MATLAB:table:ExtractDataCatError'}))
        % If braces can't, just create a cell array
        a = table2cell(t1.subsrefParens({':' varIndices}));
    else
        rethrow(ME)
    end
end

% Split up the transposed data into vars, one per column
[nvars,nrows] = size(a);
vars = mat2cell(a',nrows,ones(1,nvars));

% Add t1's var names as a var in t2
vars = [{t1.varDim.labels(varIndices)'}, vars];
% Use t1's var dim name as the new var's name
try
    varNames = string(varNames)'; % Transpose to row vector.
catch ME % No string conversion
    m = message('MATLAB:table:rows2vars:InvalidNewVarNames');
    throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
end
if numel(varNames) ~= nvars
    error(message('MATLAB:table:rows2vars:IncorrectNumVarNames'))
end
varNames = [string(getString(message('MATLAB:table:uistrings:Rows2varsNewVarName'))), varNames];
missingVarNames = ismissing(varNames);
varNames(missingVarNames) = t1.varDim.dfltLabels(find(missingVarNames)); %#ok<FNDSB>
varNames = t1.varDim.makeValidName(cellstr(varNames),'warn');
% Make sure names don't conflict with each other or dim names
varNames = matlab.lang.makeUniqueStrings(varNames,dimNames,namelengthmax);
nvars = nvars + 1;
% Update nrows based on number of varNames, in case t1 was empty.
nrows = size(vars{1},1);
rowNames = {};

t2 = table.init(vars,nrows,rowNames,nvars,varNames);
t2.metaDim = t2.metaDim.setLabels(dimNames);
