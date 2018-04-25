function results = runInParallel(runner, tests, varargin)
% RUNINPARALLEL - Run all the tests in a TestSuite array on a parallel pool
%
%   RESULT = RUNINPARALLEL(RUNNER, TESTS) splits TESTS into separate groups
%   and uses RUNNER to run each group on the current parallel pool.  TESTS
%   is a matlab.unittest.Test array and RUNNER is an instance of
%   matlab.unittest.TestRunner. RESULT is a matlab.unittest.TestResult
%   array containing information regarding the parallel run.
%
%   The order in which TESTS are run and the number of groups and workers
%   used to run TESTS is undefined and subject to change.
%
%   Example:
%       import matlab.unittest.TestSuite;
%       import matlab.unittest.TestRunner;
%       import matlab.unittest.Verbosity;
%
%       suite = TestSuite.fromClass(?mypackage.MyTestClass);
%       runner = TestRunner.withTextOutput();
%
%       result = runner.runInParallel(suite)
%
%   See also: run, TestSuite, TestResult, plugins.TestRunnerPlugin
%

% Copyright 2014-2017 MathWorks Inc.
import matlab.unittest.plugins.ToStandardOutput;
import matlab.unittest.internal.createConditionallyKeptFolderEnvironment;
import matlab.unittest.internal.generateParserWithNewRunIdentifier;

for plugin = runner.Plugins
    if ~plugin.supportsParallel
        throw(MException(...
            message('MATLAB:unittest:TestRunner:PluginDoesNotSupportParallel', class(plugin))));
    end
end

parser = generateParserWithNewRunIdentifier();
parser.addParameter('OutputStream',ToStandardOutput,...
    @(x) validateattributes(x,{'matlab.unittest.plugins.OutputStream'},{'scalar'},'','OutputStream'));
parser.parse(varargin{:});

stream = parser.Results.OutputStream;
runIdentifier = parser.Results.RunIdentifier;

artifactsFolder = runner.ArtifactsRootFolder + filesep + runIdentifier;
env = createConditionallyKeptFolderEnvironment(artifactsFolder); %#ok<NASGU>

p = gcp();
if isempty(p)
    throw(MException(message('MATLAB:unittest:TestRunner:NoPool')));
end
numWorkers = p.NumWorkers;
numGroups = numWorkers*3; % Target three groups/worker

groups = scheduleGroups(runner, runIdentifier, tests, numGroups);
printRunningMessage(stream, numel(tests), numel(groups), numWorkers);
printFinishedOutput(groups, stream);
results = fetchOutputs(groups);
results = reloadTransientProperties(results,runner,tests);
results = reshape(results, size(tests));
end


function groups = scheduleGroups(runner, runIdentifier, unscheduledSuite, numGroupsToSchedule)
% Schedule the groups
haveMoreSchedules = true;
while haveMoreSchedules
    frontloadFactor = 0.01*(numGroupsToSchedule-1); % Front load the groups
    groupLength = ceil((1 + frontloadFactor)*numel(unscheduledSuite)/numGroupsToSchedule);
    groups(numGroupsToSchedule) = ...
        parfeval(@(runner,suite) runner.run(suite,'RunIdentifier',runIdentifier), 1, runner, unscheduledSuite(1:groupLength)'); %#ok<AGROW> incorrect analysis
    numGroupsToSchedule = numGroupsToSchedule - 1;
    unscheduledSuite(1:groupLength) = [];
    haveMoreSchedules = ~isempty(unscheduledSuite);
end
% Remove any groups not needed
groups(1:numGroupsToSchedule) = [];
groups = flip(groups);
end


function printFinishedOutput(groups, stream)
for idx = 1:numel(groups)
    % fetchNext blocks until next results are available.
    groupIdx = fetchNext(groups);
    printOutput(stream, groups(groupIdx).Diary, groupIdx);
end
end


function printRunningMessage(stream, numTests, numGroups, numWorkers)
catalog = matlab.internal.Catalog('MATLAB:unittest:TestRunner');

if numTests == 1
    msg = catalog.getString('RunningGroupOnWorker');
elseif numGroups == 1
    msg = catalog.getString('RunningTestsOnGroupOnWorker');
elseif numWorkers == 1
    msg = catalog.getString('RunningGroupsOnWorker', numGroups);
else
    msg = catalog.getString('RunningGroupsOnWorkers', numGroups, min(numWorkers, numGroups));
end
stream.print('%s\n', msg);
end


function printOutput(stream, output, idx)
import matlab.unittest.internal.diagnostics.wrapHeader;

header = getString(message('MATLAB:unittest:TestRunner:FinishedGroup', idx));
stream.print('%s\n%s\n', wrapHeader(header), output);
end

function results = reloadTransientProperties(results,runner,suite)
import matlab.unittest.internal.generateUUID;

N = numel(suite);
uuid = generateUUID(N);
for idx = 1:N
    results(idx).TestElement = suite(idx);
    results(idx).ResultIdentifier = uuid(idx);
end
[results.TestRunner] = deal(runner);
end

% LocalWords:  mypackage env gcp frontload parfeval
