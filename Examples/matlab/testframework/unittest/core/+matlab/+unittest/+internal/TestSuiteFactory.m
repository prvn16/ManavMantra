classdef TestSuiteFactory
    % This class is undocumented.
    
    % TestSuiteFactory - Abstract factory class for creating suites.
    %   TestSuiteFactory abstracts out static analysis and suite creation
    %   operations for test content defined using different interfaces.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Abstract, Constant)
        CreatesSuiteForValidTestContent
    end
    
    methods (Abstract)
        % createSuiteExplicitly - Attempt to create the suite.
        %   Create the suite given a specific entity (e.g., a class name).
        suite = createSuiteExplicitly(factory, selector)
        
        % createSuiteImplicitly - Attempt to create the suite.
        %   Create the suite using an entity discovered inside a container
        %   (e.g., folder or package).
        suite = createSuiteImplicitly(factory, selector)
    end
    
    methods (Hidden)
        function suite = createSuiteFromParentName(factory, selector)
            suite = factory.createSuiteExplicitly(selector);
        end
    end
    
    methods (Static)
        function factory = fromParentName(varargin)
            % fromParentName - Create a TestSuiteFactory for a given test parent name.
            %   TestSuiteFactory.fromParentName(parentName, namingConventionService)
            %   creates a TestSuiteFactory for test content with the given parent name
            %   according to the supplied naming convention service. If a naming
            %   convention service is not supplied, this method locates the service.
            
            import matlab.unittest.internal.services.ServiceLocator;
            import matlab.unittest.internal.services.ServiceFactory;
            import matlab.unittest.internal.services.suitecreation.SuiteCreationLiaison;
            import matlab.unittest.internal.services.suitecreation.ClassSuiteCreationService;
            
            package = 'matlab.unittest.internal.services.suitecreation.located';
            locator = ServiceLocator.forPackage(meta.package.fromName(package));
            cls = ?matlab.unittest.internal.services.suitecreation.SuiteCreationService;
            locatedServiceClasses = locator.locate(cls);
            locatedServices = ServiceFactory.create(locatedServiceClasses);
            
            services = [ClassSuiteCreationService; locatedServices];
            liaison = SuiteCreationLiaison.fromParentName(varargin{:});
            fulfill(services, liaison);
            factory = liaison.Factory;
        end
    end
    
    methods (Access=protected)
        function factory = TestSuiteFactory
        end
    end
end

% LocalWords:  suitecreation cls
