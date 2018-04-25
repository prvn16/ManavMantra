% This function is undocumented.

%  Copyright 2016-2017 The MathWorks, Inc.

function conds = convertToCasualConditions(diags)
conds = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
for k=1:numel(diags)
    conds = [conds,...
        getInnerMostConditions(diags(k))]; %#ok<AGROW>
end
end

function conds = getInnerMostConditions(diag)
import matlab.unittest.internal.diagnostics.RequirementDiagnostic;
if ~isa(diag,'RequirementDiagnostic') || numel(diag.ConditionsList) == 0 || ~diag.DisplayConditions
    conds = diag;
    return;
end
conds = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
for k=1:numel(diag.ConditionsList)
    conds = [conds,getInnerMostConditions(diag.ConditionsList(k))]; %#ok<AGROW>
end
end