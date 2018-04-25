% TestCase - Superclass of all tests written in matlab.unittest
%
%   The TestCase class is the means by which a test is written using
%   matlab.unittest. It provides the means to write and identify 
%   test content as well as test fixture setup and teardown routines. 
%   Creating such a test requires deriving from TestCase to produce a 
%   TestCase subclass. All subclasses can then leverage the following 
%   meta-data attributes to specify tests and test fixtures:
%
%   Method Attributes
%   -----------------
%
%   Classes that derive from TestCase can define methods blocks which
%   contain matlab.unittest specific attributes to specify test
%   content. These additional attributes are described below:
%
%       Test - denote a method block to contain test methods
%
%           The Test attribute is the means by which a TestCase subclass
%           specifies a method to be a test method. A new instance of the
%           TestCase subclass is created in order to run the test defined
%           by each method attributed with the Test attribute. The default
%           value of this property is false.
%
%       TestMethodSetup - denote a method block to contain setup code
%
%           If a methods block contains the TestMethodSetup attribute, each
%           method in that block is identified as a method responsible for
%           setting up a test fixture. The test running framework uses this
%           information to create the test fixture prior to running each
%           Test method. Such methods are required to be instance methods,
%           and as such they can modify/adjust properties on the TestCase
%           instance which are then made available when running each Test
%           method. In order to provide a fresh fixture, these methods are
%           run before every test method. The default value of this
%           property is false.
%
%       TestMethodTeardown - denote a method block to contain teardown code
%
%           If a methods block contains the TestMethodTeardown attribute,
%           each method in that block is identified as a method responsible
%           for tearing down a test fixture. The test running framework
%           uses this information to cleanup the test fixture after running
%           each Test method. Such methods are required to be instance
%           methods, and as such they can reference properties on the
%           TestCase instance which might be needed in order to teardown
%           the test fixture. In order to cleanup stale fixtures prior to
%           each test, these methods are run after every test method. The
%           default value of this property is false.
%
%       TestClassSetup - denote a method block to contain class level setup code
%
%           If a methods block contains the TestClassSetup attribute, each
%           method in that block is identified as a method responsible for
%           setting up a test fixture that is shared over all test methods
%           in that class. The test running framework uses this information
%           to create this shared test fixture prior to running any tests
%           in the class. Such methods are required to be instance methods,
%           and as such they can modify/adjust properties on a class level
%           instance of the TestCase class under test. Through a copy,
%           these values are then made available when running each Test
%           method. These methods are run once for each class, prior to
%           running any method level setup or any tests. The default value
%           of this property is false.
%
%       TestClassTeardown - denote a method block to contain class level teardown code
%
%           If a methods block contains the TestClassTeardown attribute,
%           each method in that block is identified as a method responsible
%           for tearing down a test fixture that is shared over all test
%           methods in that class. The test running framework uses this
%           information to teardown this shared test fixture after all
%           specified tests in the class have been run. Such methods are
%           required to be instance methods, and as such they can reference
%           properties on the class level TestCase instance which might be
%           needed in order to teardown the test fixture.  These methods
%           are run once after all tests have executed and after the last
%           method level teardown code has executed. The default value of
%           this property is false.
%
%   TestCase methods:
%       forInteractiveUse     - Create a TestCase to use interactively
%       addTeardown           - Dynamically add a teardown routine
%       applyFixture          - Use a fixture within a TestCase class
%       getSharedTestFixtures - Access shared test fixtures
%       log                   - Record diagnostic information
%       run                   - Run a TestCase test
%       onFailure             - Dynamically add diagnostics for test failures
%       
%   TestCase events:
%       VerificationFailed   - Event triggered upon a failing verification
%       VerificationPassed   - Event triggered upon a passing verification
%       AssertionFailed      - Event triggered upon a failing assertion
%       AssertionPassed      - Event triggered upon a passing assertion
%       FatalAssertionFailed - Event triggered upon a failing fatal assertion
%       FatalAssertionPassed - Event triggered upon a passing fatal assertion
%       AssumptionFailed     - Event triggered upon a failing assumption
%       AssumptionPassed     - Event triggered upon a passing assumption
%       ExceptionThrown      - Event triggered when an exception is thrown
%       DiagnosticLogged     - Event triggered by calls to the log method
%
%   Examples:
%
%
%   classdef TFigureProperties < matlab.unittest.TestCase
%       % TFigureProperties an example test
%
%       properties
%           TestFigure
%       end
%
%       methods(TestMethodSetup)
%           function createFigure(testCase)
%               testCase.TestFigure = figure;
%           end
%       end
%
%       methods(TestMethodTeardown)
%           function closeFigure(testCase)
%               close(testCase.TestFigure);
%           end
%       end
%
%       methods(Test)
%
%           function defaultCurrentPoint(testCase)
%
%               cp = get(testCase.TestFigure, 'CurrentPoint');
%               testCase.verifyEqual(cp, [0 0], ...
%                   'Default current point is incorrect')
%           end
%
%           function defaultCurrentObject(testCase)
%               import matlab.unittest.constraints.IsEmpty;
%
%               co = get(testCase.TestFigure, 'CurrentObject');
%               testCase.verifyThat(co, IsEmpty, ...
%                   'Default current object should be empty');
%           end
%
%       end
%
%   end
%
%   See also
%       matlab.unittest.constraints
%       matlab.unittest.qualifications
%

% Copyright 2012-2017 The MathWorks, Inc.

% LocalWords:  TFigure cp
