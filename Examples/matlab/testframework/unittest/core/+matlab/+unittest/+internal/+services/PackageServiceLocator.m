classdef PackageServiceLocator < matlab.unittest.internal.services.ServiceLocator
    % This class is undocumented and will change in a future release.
    
    % PackageServiceLocator - ServiceLocator which finds classes in packages.
    %
    % See Also: ServiceLocator, Service, ServiceFactory
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(Access=private)
        Package meta.package;
    end
    
    methods
        function serviceClasses = locate(locator, interfaceClass)
            locator.validateInterfaceClass(interfaceClass);

            packages = locator.Package;
            serviceClassCell = cell(1, numel(packages));
            for idx = 1:numel(packages)
                classes = packages(idx).ClassList;
                classes = classes(classes < interfaceClass);
                classes = classes(~[classes.Abstract]);
                serviceClassCell{idx} = classes(:);
            end
            serviceClasses = vertcat(interfaceClass(1:0,1), serviceClassCell{:});

        end
    end
    methods(Access=?matlab.unittest.internal.services.ServiceLocator)
        function locator = PackageServiceLocator(pkg)
            locator.Package = pkg;
        end
    end
    methods(Static, Access=private)
        function validateInterfaceClass(interfaceClass)
            validateattributes(interfaceClass,...
                {'meta.class'}, {'scalar'}, '', 'interfaceClass');
            
            if ~(interfaceClass <= ?matlab.unittest.internal.services.Service)
                throw(MException(message(...
                    'MATLAB:unittest:ServiceLocator:InvalidInterfaceClass')));
            end
        end
    end
end

