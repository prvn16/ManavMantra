function [varNames, varIdxs] = resolveTableVarSubscript(tableVarNames, subscript)
%resolveTableVarSubscript Resolve a table 'variable' subscript
%   [varNames, varIdxs] = resolveTableVarSubscript(tableVarNames, subscript) 
%
%   Inputs:
%   'tableVarNames': cellstr containing the variable names of a table
%   'subscript': logical, string, cellstr, or char subscript either
%   for indexing, or for functions such as VARFUN which accept subscript-style
%   expressions for defining table variables.
%
%   Outputs:
%   'varNames': selected variable names
%   'varIdxs': corresponding selected variable indices
%
%   This method throws the same errors as the corresponding table indexing
%   methods.

% Copyright 2016 The MathWorks, Inc.


if islogical(subscript)
    % Also convert logical to numeric up front
    subscript = find(subscript);
elseif isstring(subscript)
    % Treat string as cellstr to fit in with ismember etc.
    subscript = cellstr(subscript);
end

if isnumeric(subscript)
    if max(subscript(:)) > numel(tableVarNames)
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    % Note that we are implicitly relying on the indexing into VariableNames to
    % perform validation of 'subscript' to check for negative / zero
    % / NaN etc. values. But see g1368852 - table allows t.(0) and
    % t.(-1)...
    varNames = tableVarNames(subscript);
elseif iscellstr(subscript)
    varNames = subscript;
elseif matlab.bigdata.internal.util.isColonSubscript(subscript)
    varNames = tableVarNames;
elseif isobject(subscript)
    subscript = subsindex(subscript) + 1;
    if max(subscript(:)) > numel(tableVarNames)
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    varNames = tableVarNames(subscript);
else
    if ~ischar(subscript)
        error(message('MATLAB:table:InvalidVarSubscript'));
    end
    if isempty(subscript) || (ischar(subscript) && ~isrow(subscript))
        error(message('MATLAB:table:InvalidVarName'));
    end
    varNames = {subscript};
end

% Ensure we've got varNames as a row
varNames = reshape(varNames, 1, []);

% Find missing names
[tf, varIdxs] = ismember(varNames, tableVarNames);
if ~all(tf)
    missingNames = varNames(~tf);
    error(message('MATLAB:table:UnrecognizedVarName', missingNames{1}));
end
end
