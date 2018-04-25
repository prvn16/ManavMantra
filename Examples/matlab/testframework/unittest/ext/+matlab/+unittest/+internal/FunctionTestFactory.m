classdef FunctionTestFactory < matlab.unittest.internal.TestSuiteFactory
    % This class is undocumented.
    
    % FunctionTestFactory - Factory for creating suites for function-based tests.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Constant)
        CreatesSuiteForValidTestContent = true;
    end
    
    properties (Access=private)
        TestFunctionName;
    end
    
    methods
        function factory = FunctionTestFactory(fcn)
            factory.TestFunctionName = fcn;
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
            suite = selectIf(feval(factory.TestFunctionName), selector);
        end
    end
end

