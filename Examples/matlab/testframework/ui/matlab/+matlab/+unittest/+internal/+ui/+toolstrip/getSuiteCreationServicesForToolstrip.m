function locatedServices = getSuiteCreationServicesForToolstrip()
% This function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.

import matlab.unittest.internal.services.ServiceLocator;
import matlab.unittest.internal.services.ServiceFactory;
persistent services;
if isempty(services)
    package = 'matlab.unittest.internal.services.suitecreation.located';
    locator = ServiceLocator.forPackage(meta.package.fromName(package));
    cls = ?matlab.unittest.internal.services.suitecreation.SuiteCreationService;
    locatedServiceClasses = locator.locate(cls);
    
    %Remove ScriptSuiteCreationService to speed things up
    toRemove = locatedServiceClasses == ...
        ?matlab.unittest.internal.services.suitecreation.located.ScriptSuiteCreationService;
    locatedServiceClasses(toRemove) = [];
    
    services = ServiceFactory.create(locatedServiceClasses);
end
locatedServices = services;
end