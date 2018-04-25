function results = runtests(varargin)
% runtests - Run a set of tests.
%
%   The runtests function provides a simple way to run a collection of
%   tests. 
%
%   RESULT = runtests(TESTS) creates a test suite specified by TESTS, runs
%   them, and returns the RESULT. TESTS can be a string containing the name
%   of a test element, a test class, a test file, a package that contains
%   the desired tests, or a folder that contains the desired test files.
%   TESTS can also be a cell array of strings where each element of the
%   cell array is a string specifying a test suite in this manner.
%   
%   RESULT = runtests(TESTS, 'UseParallel', true) runs the specified tests
%   using a parallel pool if available.  Testing will occur in parallel if
%   Parallel Computing Toolbox(TM) is installed and a parallel pool is
%   open. If there are no open parallel pools but automatic creation is
%   enabled in the parallel preferences, the default pool will be
%   automatically opened and testing will occur in parallel. If there are
%   no open parallel pools and automatic creation is disabled, or if
%   Parallel Computing Toolbox is not installed, testing will occur in
%   serial. Testing will occur in serial if the value is false or
%   unspecified. Testing in parallel might not be compatible with other
%   options. For example, testing will occur in serial when 'UseParallel'
%   and 'Debug' are both set to true.
%                                                                          
%   RESULT = runtests(TESTS,'Debug',true) applies debugging capabilities
%   when running TESTS. For example, the framework pauses test execution to  
%   enter debug mode if a test failure is encountered.
%
%   RESULT = runtests(TESTS,'Strict',true) applies strict checks while
%   running TESTS. For example, the framework generates a qualification
%   failure if a warning is issued during test execution.
% 
%   RESULT = runtests(TESTS,'Verbosity',VERBOSITY) runs the specified tests
%   at the specified VERBOSITY level. For example, RUNTESTS displays the
%   progress of the test run at VERBOSITY and reacts to the messages logged
%   by calls to the matlab.unittest.TestCase log method at VERBOSITY or
%   lower. VERBOSITY can be specified using the text "Terse", "Concise",
%   "Detailed", or "Verbose", or using a numeric value between 1 to 4.
%
%   RESULT = runtests(TESTS, NAME, VALUE, ...) also supports those
%   name-value pairs of the testsuite function.
%   
%
%   Examples:
%
%       % Run tests using a variety of methods.
%       results = runtests('mypackage.MyTestClass')
%       results = runtests('SomeTestFile.m')
%       results = runtests(pwd)
%       results = runtests('mypackage.subpackage')
%       results = runtests('MyTestClass/MyTestMethod')
%
%       % Run them all in one function call
%       result = runtests({'mypackage.MyTestClass', 'SomeTestFile.m', ...
%            pwd, 'mypackage.subpackage', 'MyTestClass/MyTestMethod'})
%
%       % Run all the tests in the current folder and any subfolders, but
%       % require that the name "feature1" appear somewhere in the folder name.
%       result = runtests(pwd, 'IncludeSubfolders', true, 'BaseFolder', '*feature1*');
%
%       % Run all the tests in the current folder and any subfolders that
%       % have a tag "featureA".
%       result = runtests(pwd, 'IncludeSubfolders', true, 'Tag', 'featureA');
%
%       % Run all tests in the current folder with debugging capabilities and
%       % verbosity level "Verbose"
%       runtests(pwd,'Debug',true,'Verbosity','Verbose');
%
%   See also: testsuite, matlab.unittest.TestSuite,
%   matlab.unittest.TestRunner, matlab.unittest.TestResult,
%   matlab.unittest.Verbosity

% Copyright 2013-2016 The MathWorks, Inc.

import matlab.unittest.TestRunner;
import matlab.unittest.plugins.ToStandardOutput;

parser = inputParser;
parser.KeepUnmatched = true;
parser.addOptional('tests', pwd, @(c) (ischar(c)&&~isempty(c)&&isrow(c)) || iscellstr(c) || isstring(c));
parser.addParameter('IncludeSubfolders', false);
parser.addParameter('IncludeSubpackages', false);
parser.addParameter('IncludingSubfolders', false); % supported alias
parser.addParameter('IncludingSubpackages', false); % supported alias
parser.addParameter('Debug', false,@(value)validateTruthyScalar(value,'Debug'));
parser.addParameter('Strict', false,@(value)validateTruthyScalar(value,'Strict'));
parser.addParameter('Verbosity', 1,@validateVerbosity);
parser.addParameter('Recursively', false, @(value)validateTruthyScalar(value,'Recursively')); % backward-compatibility
parser.addParameter('UseParallel', false, @(value)validateTruthyScalar(value,'UseParallel'));
parser.addParameter('OutputStream',ToStandardOutput,@validateOutputStream); % for testing only
parser.parse(varargin{:});

pvcell = reformatInputsToTestSuite(parser);
suites = testsuite(parser.Results.tests,pvcell{:});
stream = parser.Results.OutputStream;

runner = TestRunner.withNoPlugins;

s = settings;
pluginsFunction = str2func(s.matlab.unittest.DefaultPluginsFcn.ActiveValue);
plugins = pluginsFunction();
pluginsCell = num2cell(plugins);

pluginsCell = applyDebugIfProvided(pluginsCell, parser);
pluginsCell = applyStrictIfProvided(pluginsCell, parser);
pluginsCell = applyVerbosityIfProvided(pluginsCell, parser);

runFcn = @run;
if parser.Results.UseParallel
    pluginsSupportParallelMask = cellfun(@supportsParallel,pluginsCell);
    if any(~pluginsSupportParallelMask)
        incompatiblePluginsClassNamesCell = cellfun(@class,pluginsCell(~pluginsSupportParallelMask),'UniformOutput',false);
        incompatiblePluginsClassNames = strjoin(incompatiblePluginsClassNamesCell ,newline);
        displayMsg = [getString(message('MATLAB:unittest:runtests:IncompatibleWithParallel',incompatiblePluginsClassNames)),newline];
        stream.print(displayMsg);        
    elseif canRunInParallel 
        runFcn = @runInParallel;
    end
end

% Add plugins to the runner
cellfun(@(plugin) runner.addPlugin(plugin),pluginsCell);
results = runFcn(runner, suites);

end

function tf = canRunInParallel
tf = false;

import matlab.internal.parallel.canUseParallelPool;

if ~canUseParallelPool
    return
end

% The parallel utility returning true guarantees:
% * PCT is installed
% * PCT is licensed
% * Pool is running
% We still need to check the case if the license can't be checked out

licenseName = 'Distrib_Computing_Toolbox';
[canCheckout, ~] = license('checkout', licenseName);
if ~canCheckout
    return % PCT license could not be checked out
end

tf = true; % We can run in parallel
end

function pv = struct2pvcell(s)
% creates a cell array in PV-pair style of {PROP1, VALUE1, ...} given a struct

p = fieldnames(s);
v = struct2cell(s);
n = 2*numel(p);

pv = cell(1,n);
pv(1:2:n) = p;
pv(2:2:n) = v;
end

% input validation
function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric','string','char','matlab.unittest.Verbosity'}, {'nonempty','row'}, '', 'Verbosity');
if ~ischar(verbosity)
    validateattributes(verbosity, {'numeric','string','matlab.unittest.Verbosity'}, {'scalar'}, '', 'Verbosity');
end
% Validate that a numeric value is valid
matlab.unittest.Verbosity(verbosity);
end
function validateTruthyScalar(value, desc)
validateattributes(value, {'numeric','logical'}, {'scalar'}, '' ,desc)
end
function validateOutputStream(outputStream)
validateattributes(outputStream,{'matlab.unittest.plugins.OutputStream'},...
    {'scalar'},'','OutputStream')
end
function pvcell = reformatInputsToTestSuite(parser)
% Take a parsed inputParser to create a new PV cell array based on its
% Results, UsingDefaults, and Unmatched values to pass off to testsuite.

testsuiteNVstruct = parser.Unmatched;

for type={'folders','packages'}
    include = ['IncludeSub' type{1}];
    including = ['IncludingSub' type{1}];
    
    % specifying both Include<type> and Including<type> will error
    checkForOverdeterminedParameters(parser,include,including);
    
    [field,value] = assignEquivalentInclude(parser,{include,including});
    testsuiteNVstruct.(field) = value;
end

pvcell = struct2pvcell(testsuiteNVstruct);
end

function [field,value] = assignEquivalentInclude(parser,fields)

mask = ismember(fields,parser.UsingDefaults); % guaranteed at least one match

if all(mask)
    % neither specified, pick one and assign value of Recursively
    field = fields{1};
    value = parser.Results.Recursively;
    return;
end

% use appropriate field depending on which was specified
field = fields{~mask};
value = parser.Results.(field);

end

function checkForOverdeterminedParameters(parser,p1,p2)
if ~any(ismember({p1,p2},parser.UsingDefaults))
    error(message('MATLAB:unittest:NameValue:OverdeterminedParameters',p1,p2));
end
end

function pluginCell = applyDebugIfProvided(pluginCell, parser)
if ~ismember('Debug',parser.UsingDefaults)
    pluginCell = applyToEachCell(@(p) p.applyDebug(parser.Results.Debug), pluginCell);
end
end

function pluginCell = applyVerbosityIfProvided(pluginCell, parser)
if ~ismember('Verbosity',parser.UsingDefaults)
    verbosity = matlab.unittest.Verbosity(parser.Results.Verbosity);
    pluginCell = applyToEachCell(@(p) p.applyVerbosity(verbosity), pluginCell);
end
end

function pluginCell = applyStrictIfProvided(pluginCell, parser)
if ~ismember('Strict',parser.UsingDefaults)
    pluginCell = applyToEachCell(@(p) p.applyStrict(parser.Results.Strict), pluginCell);
end
end

function outCell = applyToEachCell(fcn,pluginCell)
outCell = cellfun(fcn,pluginCell,'UniformOutput',false);
end
% LocalWords:  subfolders subpackages mypackage isscript
