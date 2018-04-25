function stack = trimStackEnd(stack)
% This function is undocumented.

%  Copyright 2013-2016 MathWorks, Inc.

import matlab.unittest.internal.services.ServiceLocator;
import matlab.unittest.internal.services.ServiceFactory;
import matlab.unittest.internal.services.stacktrimming.StackTrimmingLiaison;
import matlab.unittest.internal.services.stacktrimming.CoreFrameworkStackTrimmingService;

package = 'matlab.unittest.internal.services.stacktrimming.located';
locator = ServiceLocator.forPackage(meta.package.fromName(package));
cls = ?matlab.unittest.internal.services.stacktrimming.StackTrimmingService;
locatedServiceClasses = locator.locate(cls);
locatedServices = ServiceFactory.create(locatedServiceClasses);

% Trim the stack from below the desired frame(s)
liaison  = StackTrimmingLiaison(stack);
services = [CoreFrameworkStackTrimmingService; locatedServices];
trimEnd(services, liaison);
stack = liaison.Stack;

end