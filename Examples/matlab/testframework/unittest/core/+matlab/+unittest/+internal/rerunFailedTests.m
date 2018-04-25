function rerunResult = rerunFailedTests(resultName,expectedKey)
% This function is undocumented.

% Copyright 2017 The MathWorks, Inc.

if ~evalin('base',sprintf('exist(''%s'',''var'');',resultName))
    throwAsCaller(MException(message('MATLAB:unittest:TestResult:TestResultVariableMustExist',resultName)));
end
result = evalin('base', resultName);

if ~isa(result,'matlab.unittest.TestResult')
    throwAsCaller(MException(message('MATLAB:unittest:TestResult:MustBeATestResult',resultName)));
end

allFailureIdentifiers = join(sort(['', result.ResultIdentifier]),",");
actualKey = matlab.unittest.internal.str2key(allFailureIdentifiers);

if ~strcmp(actualKey,expectedKey)
    throwAsCaller(MException(message('MATLAB:unittest:TestResult:StaleTestResults',resultName)));
end

failedTestResults = result([result.Failed]);
failedTestSuite = [failedTestResults.TestElement];
runner = validateRunner(failedTestResults);
rerunResult = runner.run(failedTestSuite);
end

function runner = validateRunner(failedTestResults)
runnerArray = [failedTestResults.TestRunner];
firstRunner = runnerArray(1);
if ~all(firstRunner==runnerArray)
    throwAsCaller(MException(message('MATLAB:unittest:TestResult:TestRunnerMismatch')));
end
runner = firstRunner;
end