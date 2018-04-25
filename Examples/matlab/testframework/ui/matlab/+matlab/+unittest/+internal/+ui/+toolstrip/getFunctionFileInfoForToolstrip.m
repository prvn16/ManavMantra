function isTestFile = getFunctionFileInfoForToolstrip(file,parseTree)
% This function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.
import matlab.unittest.internal.services.suitecreation.SuiteCreationLiaison;
import matlab.unittest.internal.services.namingconvention.AllowsAnythingNamingConventionService;
import matlab.unittest.internal.ui.toolstrip.getSuiteCreationServicesForToolstrip;

locatedServices = getSuiteCreationServicesForToolstrip();
liaison = SuiteCreationLiaison.fromFilename(file,parseTree,AllowsAnythingNamingConventionService);
liaison.SkipMCheck = true;
try
    fulfill(locatedServices, liaison);
catch
    isTestFile = false;
    return;
end

factory = liaison.Factory;

isTestFile = factory.CreatesSuiteForValidTestContent;
end