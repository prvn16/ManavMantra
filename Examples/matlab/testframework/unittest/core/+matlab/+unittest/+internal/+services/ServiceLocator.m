classdef ServiceLocator
    % This class is undocumented and will change in a future release.
    
    % ServiceLocator - Interface that is used to locate services across module
    % boundaries dynamically.
    %
    % See Also: Service, ServiceFactory
    
    % Copyright 2015 The MathWorks, Inc.
   
    methods(Static)
        function locator = forPackage(pkg)
            % forPackage - Create an instance which locates services in a package.
            %
            %   LOCATOR = matlab.unittest.internal.services.ServiceLocator.forPackage(PKG)
            %   creates a ServiceLocator that is able to look at all of the classes
            %   that reside in a given package and return those that are of a specific
            %   interface type. PKG is a meta.package instance and LOCATOR is the
            %   ServiceLocator which finds services contained in the PKG.
            locator = matlab.unittest.internal.services.PackageServiceLocator(pkg);
        end
    end
    
    methods(Abstract)
        % locate - Locate all the services meeting a certain service interface
        %
        %   SERVICECLASSES = locate(LOCATOR, INTERFACECLASS) use the LOCATOR to
        %   find all of the classes which derive from the INTERFACECLASS and
        %   returns them in the SERVICECLASSES array. INTERFACECLASS is the
        %   matlab.unittest.internal.services.Service class or one of its
        %   subclasses.
        serviceClasses = locate(locator, interfaceClass)
    end
end
