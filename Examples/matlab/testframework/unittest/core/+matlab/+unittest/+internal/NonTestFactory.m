classdef NonTestFactory < matlab.unittest.internal.TestSuiteFactory
    % This class is undocumented.
    
    % NonTestFactory - Factory for creating suites for non-test entities.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Constant)
        CreatesSuiteForValidTestContent = false;
    end
    
    properties (Access=private)
        Exception;
    end
    
    methods
        function factory = NonTestFactory(exception)
            factory.Exception = exception;
        end
        
        function suite = createSuiteExplicitly(factory, ~) %#ok<STOUT>
            throwAsCaller(factory.Exception);
        end
        
        function suite = createSuiteImplicitly(~, ~)
            suite = matlab.unittest.Test.empty;
        end
    end
end

