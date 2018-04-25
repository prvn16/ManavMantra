function plugins = locateAdditionalDefaultPlugins(interface, packageName)
% locateAdditionalDefaultPlugins - Dynamically locate plugins.
%   By default, the testing framework will add these plugins to the factory
%   default list when running tests.
%
%   PLUGINS = locateAdditionalDefaultPlugins(INTERFACE, PACKAGENAME) locates 
%   only those plugins provided by services deriving from the specified 
%   INTERFACE and residing under the specified PACKAGENAME.
%
% See also: matlab.unittest.services.plugins.TestRunnerPluginService

% Copyright 2017 The MathWorks, Inc.
import matlab.unittest.internal.services.ServiceLocator
import matlab.unittest.internal.services.ServiceFactory
import matlab.unittest.internal.services.plugins.TestRunnerPluginLiaison

package        = meta.package.fromName(packageName);
serviceLocator = ServiceLocator.forPackage(package);

serviceClassesWithInterface = serviceLocator.locate(interface);
serviceFactory = ServiceFactory;
pluginServices = serviceFactory.create(serviceClassesWithInterface);

pluginLiaison = TestRunnerPluginLiaison;
pluginServices.fulfill(pluginLiaison);
plugins = pluginLiaison.Plugins;
end