function tests = functiontests(localFcns)
% functiontests - Create a suite of tests defined from local functions
%
%   The functiontests function provides a simple way to collect a
%   function's local functions into a test suite that can be run.
%
%   TESTS = functiontests(LOCALFUNCTIONS) creates a test suite from all the
%   test functions included in LOCALFUNCTIONS. LOCALFUNCTIONS is a cell
%   array of function handles to local functions defined in the calling
%   function. From those function handles, tests are defined as those with
%   names that start or end with "test" ignoring case differences. Functions
%   named "setup" or "teardown" are used to set up and tear down fresh
%   fixtures common to all test functions. Likewise functions named "setupOnce"
%   or "teardownOnce" are used to set up and tear down fixtures shared among
%   all tests in the function. All these functions require one input argument
%   into which the test framework will pass a FunctionTestCase when running
%   the tests. This FunctionTestCase can be used for verifications, assertions,
%   assumptions, and fatal assertions in the test. Also, data can be passed 
%   between setup, test, and teardown methods using the TestData property on 
%   the FunctionTestCase supplied to each function.
%   
%
%   Example:
%
%       % figurePropertiesTest.m
%       function tests = figurePropertiesTest
%       % figurePropertiesTest an example local function test
%
%       tests = functiontests(localfunctions);
%
%       function setup(testCase)
%       testCase.TestData.Figure = figure;
%
%       function teardown(testCase)
%       close(testCase.TestData.Figure);
%    
%       function testDefaultCurrentPoint(testCase)
%
%       cp = get(testCase.TestData.Figure, 'CurrentPoint');
%       verifyEqual(testCase, cp, [0 0], ...
%           'Default current point is incorrect')
%
%       function defaultCurrentObjectTest(testCase)
%
%       co = get(testCase.TestData.Figure, 'CurrentObject');
%       verifyEmpty(testCase, co, ...
%           'Default current object should be empty');
%
%
%       % In the Command Window
%       >> tests = figurePropertiesTest;
%       >> run(tests)
%
%       There are 2 tests created and run in this example corresponding
%       to testDefaultCurrentPoint and defaultCurrentObjectTest. The setup
%       and teardown functions are used to set up and tear down the fresh
%       fixture before and after each test function.
%
%   See also: localfunctions, runtests, matlab.unittest.Test,
%      matlab.unittest.FunctionTestCase

% Copyright 2013-2016 The MathWorks, Inc.

import matlab.unittest.Test;
import matlab.unittest.internal.DefaultTestNameMatcher;

validateattributes(localFcns, {'cell'}, {}, '', 'localFcns');

cellfun(@validateScopedFunction, localFcns);

% Get the function names
fcnNames = cellfun(@func2str, localFcns, 'UniformOutput', false);

% Filter out any non-test functions
areTestFcns = cellfun(...
    @(fcnName) DefaultTestNameMatcher.isTest(fcnName), fcnNames);
testFcns = localFcns(areTestFcns);
% Row vectorize
testFcns = testFcns(:)'; 

% Must have at least one test in the cell array
if isempty(testFcns)
    throw(MException(message('MATLAB:unittest:functiontests:NoTestsFound')));
end

% Add the setup and teardown functions if provided
paramValues = {};
setupFcnIdx = strcmp(fcnNames, 'setup');
if any(setupFcnIdx(:))
    paramValues = [paramValues {'SetupFcn'}, localFcns(setupFcnIdx)];
end

teardownFcnIdx = strcmp(fcnNames, 'teardown');
if any(teardownFcnIdx(:))
    paramValues = [paramValues {'TeardownFcn'}, localFcns(teardownFcnIdx)];
end

setupOnceFcnIdx = strcmp(fcnNames, 'setupOnce');
if any(setupOnceFcnIdx(:))
    paramValues = [paramValues {'SetupOnceFcn'}, localFcns(setupOnceFcnIdx)];
end

teardownOnceFcnIdx = strcmp(fcnNames, 'teardownOnce');
if any(teardownOnceFcnIdx(:))
    paramValues = [paramValues {'TeardownOnceFcn'}, localFcns(teardownOnceFcnIdx)];
end
tests = Test.fromFunctions(testFcns, paramValues{:});

end

function validateScopedFunction(fcn)

if ~isa(fcn, 'function_handle')
    throw(MException(message('MATLAB:unittest:functiontests:MustProvideCellOfFunctions')));
end

fcnInfo = functions(fcn);
% Must be a scoped function
if ~strcmp(fcnInfo.type, 'scopedfunction')
    throw(MException(message('MATLAB:unittest:functiontests:MustBeLocalFunction')));
end

end

% LocalWords:  LOCALFUNCTIONS cp scopedfunction
