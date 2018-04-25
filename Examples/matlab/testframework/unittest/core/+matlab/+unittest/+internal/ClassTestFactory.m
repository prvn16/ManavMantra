classdef ClassTestFactory < matlab.unittest.internal.TestSuiteFactory
    % This class is undocumented.
    
    % ClassTestFactory - Factory for creating suites for TestCase classes.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Constant)
        CreatesSuiteForValidTestContent = true;
    end
    
    properties (SetAccess=immutable)
        TestClass;
    end
    
    methods
        function factory = ClassTestFactory(testClass)
            factory.TestClass = testClass;
        end
        
        function suite = createSuiteExplicitly(factory, selector)
            suite = factory.createSuite(selector);
        end
        
        function suite = createSuiteImplicitly(factory, selector)
            suite = factory.createSuite(selector);
        end
    end
    
    methods (Access=private)
        function suite = createSuite(factory, selector)
            suite = matlab.unittest.Test.fromClass(factory.TestClass, selector);
        end
    end
end

