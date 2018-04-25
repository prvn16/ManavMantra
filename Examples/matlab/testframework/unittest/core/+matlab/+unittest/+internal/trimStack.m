function stack = trimStack(stack)
% This function is undocumented.

%  Copyright 2016 MathWorks, Inc.

import matlab.unittest.internal.services.ServiceLocator;
import matlab.unittest.internal.services.ServiceFactory;
import matlab.unittest.internal.services.stacktrimming.StackTrimmingLiaison;
import matlab.unittest.internal.services.stacktrimming.CoreFrameworkStackTrimmingService;

package = 'matlab.unittest.internal.services.stacktrimming.located';
locator = ServiceLocator.forPackage(meta.package.fromName(package));
cls = ?matlab.unittest.internal.services.stacktrimming.StackTrimmingService;
locatedServiceClasses = locator.locate(cls);
locatedServices = ServiceFactory.create(locatedServiceClasses);

% Trim both ends of the stack
liaison  = StackTrimmingLiaison(stack);
services = [CoreFrameworkStackTrimmingService; locatedServices];
fulfill(services, liaison);
stack = liaison.Stack;

end