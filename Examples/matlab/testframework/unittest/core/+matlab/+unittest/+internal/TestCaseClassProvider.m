classdef(Hidden) TestCaseClassProvider < matlab.unittest.internal.ClassBasedProvider
    % TestCaseClassProvider is a TestCaseProvider that holds onto a
    % TestCase class.
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    
    properties(Dependent, SetAccess=immutable)
        TestMethodName
    end
    
    properties(SetAccess=immutable)
        TestParentName
        TestName
    end
    
    methods (Static)
        function provider = withSpecificParameterization(testClass, methods, parameterization)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            provider = TestCaseClassProvider(testClass, methods);
            provider = provider.setParameterization(parameterization);
        end
        
        function provider = withAllParameterizations(testClass, methods, varargin)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            provider = TestCaseClassProvider(testClass, methods);
            provider = provider.expandBasedOnParameterization(testClass, methods, varargin{:});
        end
    end
    
    methods
        function provider = TestCaseClassProvider(testClass, methods)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            if nargin == 0
                return % Allow pre-allocation
            end
            
            provider = TestCaseClassProvider.empty;
            numElements = numel(methods);
            if numElements > 0
                provider(numElements) = TestCaseClassProvider;
                [provider.TestParentName] = deal(testClass.Name);
                [provider.TestName] = methods.Name;
                provider = provider.assignNumInputParameters(methods);
            end
            
            provider = provider.assignSharedTestFixtures(testClass);
            provider = provider.assignTags(testClass, methods);
            
            provider = reshape(provider, size(methods));
            provider = provider.determineSuperclasses(testClass);
        end
        
        function testCase = provideClassTestCase(provider)
            % Construct a new TestCase from the class.  Note that the class
            % definition must be on the path when calling this method to
            % ensure predictable behavior.
            constructTestCase = str2func(provider.TestParentName);
            testCase = constructTestCase();
        end
        
        function testCase = createTestCaseFromClassPrototype(~, classTestCase)
            testCase = copy(classTestCase);
        end

        function testMethodName = get.TestMethodName(provider)
            testMethodName = provider.TestName;
        end
    end
end

% LocalWords:  func Parameterizations
