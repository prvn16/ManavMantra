function results = runperf(varargin)
% runperf - Run a set of tests as a performance experiment.
%
%   The runperf function provides a simple way to run a collection of
%   tests as a performance experiment.
%
%   RESULT = runperf(TESTS) creates a test suite specified by TESTS, runs
%   them using a variable sample time experiment, and returns the RESULT.
%   TESTS can be a string containing the name of a test element, a test
%   class, a test file, a package that contains the desired tests, or a
%   folder that contains the desired test files. TESTS can also be a cell
%   array of strings where each element of the cell array is a string
%   specifying a test suite in this manner.
%
%   RESULT = runperf(TESTS, NAME, VALUE, ...) supports those name-value
%   pairs of the testsuite function.
%   
%
%   Examples:
%
%       % Run tests using a variety of methods.
%       results = runperf('mypackage.MyTestClass')
%       results = runperf('SomeTestFile.m')
%       results = runperf(pwd)
%       results = runperf('mypackage.subpackage')
%       results = runperf('MyTestClass/MyTestMethod')
%
%       % Run them all in one function call
%       result = runperf({'mypackage.MyTestClass', 'SomeTestFile.m', ...
%            pwd, 'mypackage.subpackage', 'MyTestClass/MyTestMethod'})
%
%       % Run all the tests in the current folder and any subfolders, but
%       % require that the name "feature1" appear somewhere in the folder name.
%       result = runperf(pwd, 'IncludeSubfolders', true, 'BaseFolder', '*feature1*');
%
%       % Run all the tests in the current folder and any subfolders that
%       % have a tag "featureA".
%       result = runperf(pwd, 'IncludeSubfolders', true, 'Tag', 'featureA');
% 
%   See also: runtests, testsuite, matlab.unittest.TestSuite, matlab.perftest.TimeExperiment, matlab.unittest.measurement.MeasurementResult

% Copyright 2015 The MathWorks, Inc.

import matlab.perftest.TimeExperiment;

suites = testsuite(varargin{:});
experiment = TimeExperiment.limitingSamplingError;

results = experiment.run(suites);

end