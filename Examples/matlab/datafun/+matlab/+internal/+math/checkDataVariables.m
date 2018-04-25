function dataVars = checkDataVariables(A,dataVars,eid)
%checkDataVariables Validate DataVariables value
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2016 The MathWorks, Inc.

% Validate DataVariables value by calling a no-op varfun
if isstring(dataVars)
    % InputVariables in varfun does not (yet) accept string
    dataVars(ismissing(dataVars)) = '';
    dataVars = cellstr(dataVars); % errors for <missing> string
end
try
    varfun(@(x)x,A,'InputVariables',dataVars);
catch ME
    if strcmp(ME.identifier,'MATLAB:table:varfun:InvalidInputVariablesFun')
        error(message(['MATLAB:',eid,':DataVariablesFunctionHandle']));
    else
        error(message(['MATLAB:',eid,':DataVariablesTableSubscript']));
    end
end
% Return a row of numeric indices
if isnumeric(dataVars)
    dataVars = sort(reshape(dataVars,1,[]));
else
    % DataVariables: function handle, variable name, or logical vector
    if isa(dataVars,'function_handle')
        dataVars = varfun(dataVars,A,'OutputFormat','uniform');
    elseif ischar(dataVars) || iscellstr(dataVars)
        dataVars = ismember(A.Properties.VariableNames,dataVars);
    end
    dataVars = find(reshape(dataVars,1,[]));
end