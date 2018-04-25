classdef(Sealed) FunctionTestCase < matlab.unittest.TestCase &  matlab.unittest.internal.Measurable
    % FunctionTestCase - TestCase for use in function based tests
    %
    %   The matlab.unittest.FunctionTestCase is the means by which
    %   qualification is performed in tests written using the functiontests
    %   function. For each test function, MATLAB creates a FunctionTestCase
    %   and passes it into the test function. This allows test writers to
    %   use the qualification functions (verifications, assertions,
    %   assumptions, and fatal assertions) to ensure their MATLAB code
    %   operates correctly.
    %
    %   See also: functiontests, runtests
    
    
    
    
    % Copyright 2013-2016 The MathWorks, Inc.

    properties
        % TestData - Property used to pass data between test functions.
        %
        %   The TestData property can be utilized by tests to pass data
        %   between fixture setup, test, and fixture teardown functions for
        %   tests created using functiontests. The default value of this
        %   property is a scalar structure with no fields. This allows a
        %   test writer to easily add test data as additional fields on
        %   this structure. However, the test author can reassign this
        %   value to any valid MATLAB value.
        TestData = struct;
    end

    
    properties(Hidden, Dependent, SetAccess=private)
        TestFcn
        SetupFcn
        TeardownFcn
        SetupOnceFcn
        TeardownOnceFcn
    end
    
    properties(Access=private)
        TestFcnHolder
        SetupFcnHolder
        TeardownFcnHolder
        SetupOnceFcnHolder
        TeardownOnceFcnHolder
    end
    
    properties(Constant, Access=private)
        FromFunctionParser = createFromFunctionParser;
    end
    
    
    methods(Hidden, Static)
        function testCase = fromFunction(fcn, varargin)
            import matlab.unittest.FunctionTestCase;
            
            
            testCase = FunctionTestCase;
            parser = testCase.FromFunctionParser;
            parser.parse(fcn, varargin{:});
            testCase.TestFcn = parser.Results.TestFcn;
            testCase.SetupFcn = parser.Results.SetupFcn;
            testCase.TeardownFcn = parser.Results.TeardownFcn;
            testCase.SetupOnceFcn = parser.Results.SetupOnceFcn;
            testCase.TeardownOnceFcn = parser.Results.TeardownOnceFcn;
        end
    end
    
    
    
    methods(Hidden, TestClassSetup)
        function setupOnce(testCase)
            testCase.SetupOnceFcn(testCase);
        end
    end
    
    methods(Hidden, TestClassTeardown)
        function teardownOnce(testCase)
            testCase.TeardownOnceFcn(testCase);
        end
    end
    
    methods(Hidden, TestMethodSetup)
        function setup(testCase)
            testCase.SetupFcn(testCase);
        end
    end
    
    methods(Hidden, TestMethodTeardown)
        function teardown(testCase)
            testCase.TeardownFcn(testCase);
        end
    end
    
    methods(Hidden, Test)
        function test(testCase)
            testCase.TestFcn(testCase);
        end
    end
    
    
    methods(Access=private)
        function testCase = FunctionTestCase
            % Constructor is private. Not in model to create explicitly.
        end
    end
    
    methods (Hidden)
         function testCase = copyFor(prototype,testFcn)
            testCase = copy(prototype);
            testCase.TestFcn = testFcn;
        end 
    end
    
    methods
        function set.TestFcn(testCase, fcn)
            import matlab.unittest.internal.FunctionHandleHolder;
            testCase.TestFcnHolder = FunctionHandleHolder(fcn);
        end
        
        function set.SetupFcn(testCase, fcn)
            import matlab.unittest.internal.FunctionHandleHolder;
            testCase.SetupFcnHolder = FunctionHandleHolder(fcn);
        end
        
        function set.TeardownFcn(testCase, fcn)
            import matlab.unittest.internal.FunctionHandleHolder;
            testCase.TeardownFcnHolder = FunctionHandleHolder(fcn);
        end
        
        function set.SetupOnceFcn(testCase, fcn)
            import matlab.unittest.internal.FunctionHandleHolder;
            testCase.SetupOnceFcnHolder = FunctionHandleHolder(fcn);
        end
        
        function set.TeardownOnceFcn(testCase, fcn)
            import matlab.unittest.internal.FunctionHandleHolder;
            testCase.TeardownOnceFcnHolder = FunctionHandleHolder(fcn);
        end
        
        function fcn = get.TestFcn(testCase)
            fcn = testCase.TestFcnHolder.Function;
        end
        
        function fcn = get.SetupFcn(testCase)
            fcn = testCase.SetupFcnHolder.Function;
        end
        
        function fcn = get.TeardownFcn(testCase)
            fcn = testCase.TeardownFcnHolder.Function;
        end
        
        function fcn = get.SetupOnceFcn(testCase)
            fcn = testCase.SetupOnceFcnHolder.Function;
        end
        
        function fcn = get.TeardownOnceFcn(testCase)
            fcn = testCase.TeardownOnceFcnHolder.Function;
        end
    end
end

function p = createFromFunctionParser

p = inputParser;
p.addRequired('TestFcn', @validateFcn);
p.addParameter('SetupFcn', @defaultFixtureFcn, @validateFcn);
p.addParameter('TeardownFcn', @defaultFixtureFcn, @validateFcn);
p.addParameter('SetupOnceFcn', @defaultFixtureFcn, @validateFcn);
p.addParameter('TeardownOnceFcn', @defaultFixtureFcn, @validateFcn);

end

function validateFcn(fcn)
validateattributes(fcn, {'function_handle'}, {}, '', 'fcn');

% Test/Fixture functions must accept exactly one input argument
if nargin(fcn) ~= 1
    throw(MException(message('MATLAB:unittest:functiontests:MustAcceptExactlyOneInputArgument', func2str(fcn))));
end

end

function defaultFixtureFcn(~)
% A do nothing function to be used as fixture setup and teardown when no
% functions have been provided.
end

% LocalWords:  func
