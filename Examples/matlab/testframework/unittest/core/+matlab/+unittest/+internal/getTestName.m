function name = getTestName(parentName, testName, parameterization)

% Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.getParameterNameString

classSetupParams = parameterization.filterByClass( ...
    'matlab.unittest.parameters.ClassSetupParameter');
methodSetupParams = parameterization.filterByClass( ...
    'matlab.unittest.parameters.MethodSetupParameter');
testParams = parameterization.filterByClass( ...
    'matlab.unittest.parameters.TestParameter');

classSetupParamsStr  = getParameterNameString(classSetupParams, '[', ']');
methodSetupParamsStr = getParameterNameString(methodSetupParams, '[', ']');
testParamsStr        = getParameterNameString(testParams, '(', ')');

name = [parentName, classSetupParamsStr, '/', ...
    methodSetupParamsStr, testName, testParamsStr];
end