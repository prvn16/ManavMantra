classdef(Hidden) TestCaseInstanceProvider < matlab.unittest.internal.ClassBasedProvider
    % TestCaseInstanceProvider is a TestCaseProvider that holds onto a
    % TestCase instance.
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    
    properties(SetAccess=immutable)
        TestName
    end
    
    properties(Dependent, SetAccess=immutable)
        TestParentName
        TestMethodName
    end
    
    properties(SetAccess=immutable, GetAccess=private)
        TestCase
    end
    
    methods
        function provider = TestCaseInstanceProvider(testCase, methods)
            import matlab.unittest.internal.TestCaseInstanceProvider;        
            
            if nargin == 0
                return % Allow pre-allocation
            end
            
            provider = TestCaseInstanceProvider.empty;
            numElements = numel(methods);
            if numElements > 0
                provider(numElements) = TestCaseInstanceProvider;
                [provider.TestCase] = deal(testCase);
                [provider.TestName] = methods.Name;
                provider = provider.assignNumInputParameters(methods);
            end
            
            testClass = metaclass(testCase);
            provider = provider.assignSharedTestFixtures(testClass);
            provider = provider.assignTags(testClass, methods);
            provider = provider.expandBasedOnParameterization(testClass, methods);
            provider = provider.determineSuperclasses(testClass);
        end

        function testCase = provideClassTestCase(provider)
            % Create a copy to keep each run independent
            testCase = copy(provider.TestCase);
        end
        
        function testCase = createTestCaseFromClassPrototype(~, classTestCase)
            testCase = copy(classTestCase);
        end
        
        function testClassName = get.TestParentName(provider)
            testClassName = class(provider.TestCase);
        end
        
        function testMethodName = get.TestMethodName(provider)
            testMethodName = provider.TestName;
        end
    end
end
