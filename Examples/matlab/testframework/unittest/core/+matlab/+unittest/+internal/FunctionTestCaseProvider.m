classdef(Hidden) FunctionTestCaseProvider < matlab.unittest.internal.TestCaseProvider
    % FunctionTestCaseProvider is a TestCaseProvider that holds onto a
    % TestCase instance.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties(SetAccess=immutable, GetAccess=private)
        TestCase
    end
    
    properties(Dependent, SetAccess=immutable)
        TestClass
        TestParentName
        TestName
    end
    
    properties (SetAccess=private)
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        Tags = cell(1,0);
    end
    
    properties(Transient, SetAccess=immutable)
        TestMethodName = 'test';
    end
    
    methods
        function provider = FunctionTestCaseProvider(testFcns, varargin)
            
            import matlab.unittest.internal.FunctionTestCaseProvider;
            import matlab.unittest.FunctionTestCase;
            
            if nargin == 0
                % Allow pre-allocation
                return
            end
            
            numElements = numel(testFcns);
            if numElements > 0
                provider(numElements) = FunctionTestCaseProvider;
                testCaseCell = cellfun(@(fcn) FunctionTestCase.fromFunction(fcn, varargin{:}), testFcns, ...
                                       'UniformOutput', false);                
                [provider.TestCase] = testCaseCell{:};
            end
            provider = reshape(provider, size(testFcns));
        end
        
        function testCase = provideClassTestCase(provider)
            % Create a copy to keep each run independent
            testCase = copy(provider.TestCase);
        end
        
        function testCase = createTestCaseFromClassPrototype(provider, prototype) 
              testCase = prototype.copyFor(provider.TestCase.TestFcn);
        end

        function testClass = get.TestClass(provider)
            testClass = provider.getDefaultTestClass;
        end
        
        function testParentName = get.TestParentName(provider)
            import matlab.unittest.internal.getParentNameFromFilename;
            fcnInfo = functions(provider.TestCase.TestFcn);
            testParentName = getParentNameFromFilename(fcnInfo.file);
        end
        function testName = get.TestName(provider)
            testName = func2str(provider.TestCase.TestFcn);
        end
    end
    
    
end

% LocalWords:  func
