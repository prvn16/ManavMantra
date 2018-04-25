function suite = testsuite(varargin)
% testsuite - Create a suite of tests.
%
%   The testsuite function provides a simple way to create a suite for a
%   collection of tests.
%
%   SUITE = testsuite(TESTS) creates a test suite specified by TESTS. TESTS
%   can be a string containing the name of a test element, a test class, a
%   test file, a package that contains the desired tests, or a folder that
%   contains the desired test files. TESTS can also be a cell array of
%   strings where each element of the cell array is a string specifying a
%   test suite in this manner.
%
%   SUITE = testsuite(TESTS, 'IncludeSubfolders', true) also includes all
%   the tests defined in the subfolders of any specified folders.
%
%   SUITE = testsuite(TESTS, 'IncludeSubpackages', true) also includes all
%   the tests defined in the subpackages of any specified packages.
%
%   SUITE = testsuite(TESTS, ATTRIBUTE_1, CONSTRAINT_1, ...) creates a
%   suite for all the tests specified by TESTS that satisfy the specified
%   conditions. Specify any of the following attributes:
%
%       * Name              - Name of the suite element
%       * ProcedureName     - Name of the test procedure in the test
%       * Superclass        - Name of a class that the test class derives
%                             from
%       * BaseFolder        - Name of the folder that holds the file
%                             defining the test class or function.
%       * ParameterProperty - Name of a property that defines a
%                             Parameter used by the suite element
%       * ParameterName     - Name of a Parameter used by the suite element
%       * Tag               - Name of a tag defined on the suite element.
%
%   Each value is specified as a string scalar or a character vector. For
%   all attributes except Superclass, the value can contain wildcard
%   characters "*" (matches any number of characters, including zero) and
%   "?" (matches exactly one character). A test is included only if it
%   satisfies all the specified criteria.
%
%
%   Examples:
%
%       % Create a suite using a variety of methods.
%       suite = testsuite('mypackage.MyTestClass')
%       suite = testsuite('SomeTestFile.m')
%       suite = testsuite(pwd)
%       suite = testsuite('mypackage.subpackage')
%       suite = testsuite('MyTestClass/MyTestMethod')
%
%       % Create them all in one function call
%       suite = testsuite({'mypackage.MyTestClass', 'SomeTestFile.m', ...
%            pwd, 'mypackage.subpackage', 'MyTestClass/MyTestMethod'})
%
%       % Include all the tests in the current folder and any subfolders, but
%       % require that the name "feature1" appear somewhere in the folder name.
%       suite = testsuite(pwd, 'IncludeSubfolders', true, 'BaseFolder', '*feature1*');
%
%       % Include all the tests in the current folder and any subfolders that
%       % have a tag "featureA".
%       suite = testsuite(pwd, 'IncludeSubfolders', true, 'Tag', 'featureA');
%
%       % Run the tests using the default test runner:
%       results = run(suite);
%
%       % Run the tests using a custom test runner:
%       runner = matlab.unittest.TestRunner.withNoPlugins;
%       results = run(runner, suite);
% 
%   See also: runtests, matlab.unittest.TestSuite

% Copyright 2015-2017 The MathWorks, Inc.

import matlab.unittest.internal.selectors.convertParsingResultsToSelector;
import matlab.unittest.Test;

parser = inputParser;
parser.addOptional('tests', pwd, @(c) isstring(c) || iscellstr(c) || (ischar(c)&&~isempty(c)&&isrow(c)));
parser.addParameter('BaseFolder',[]);
parser.addParameter('IncludeSubfolders', false, @(x)validateIncludeSub(x,'IncludeSubfolders'));
parser.addParameter('IncludeSubpackages', false, @(x)validateIncludeSub(x,'IncludeSubpackages'));
parser.addParameter('IncludingSubfolders', false, @(x)validateIncludeSub(x,'IncludingSubfolders')); % supported alias
parser.addParameter('IncludingSubpackages', false, @(x)validateIncludeSub(x,'IncludingSubpackages')); % supported alias
parser.addParameter('Name',[]);
parser.addParameter('ParameterName',[]);
parser.addParameter('ParameterProperty',[]);
parser.addParameter('Tag',[]);
parser.addParameter('ProcedureName',[]);
parser.addParameter('Superclass',[]);

parser.parse(varargin{:});

checkForOverdeterminedParameters(parser,'IncludeSubfolders','IncludingSubfolders');
checkForOverdeterminedParameters(parser,'IncludeSubpackages','IncludingSubpackages');

results = rmfield(parser.Results, parser.UsingDefaults);
selector = convertParsingResultsToSelector(results);

includeSubfolders = parser.Results.IncludeSubfolders || parser.Results.IncludingSubfolders;
includeSubpackages = parser.Results.IncludeSubpackages || parser.Results.IncludingSubpackages;

tests = string(parser.Results.tests);
suites = cell(1,length(tests));
for k=1:numel(tests)
    testAsChar = char(tests(k));
    if isempty(deblank(testAsChar))
        error(message('MATLAB:unittest:TestSuite:UnrecognizedSuite',testAsChar));
    end
    suites{k} = createSuite(testAsChar, selector, ...
        includeSubfolders, includeSubpackages);
end

suite = [Test.empty, suites{:}];

end

function suite = createSuite(test, selector, includeSubfolders, includeSubpackages)

import matlab.unittest.TestSuite;
import matlab.unittest.internal.NameParser;
import matlab.unittest.internal.TestSuiteFactory;
import matlab.unittest.internal.getFilenameFromParentName;
import matlab.unittest.internal.whichFile;
import matlab.unittest.internal.services.namingconvention.AllowsAnythingNamingConventionService;

% fromName
parser = NameParser(test);
parser.parse;
fromNameException = [];
if parser.Valid
    try
        suite = TestSuite.fromName(test);
        suite = addPathAndCurrentFolderFixturesIfNeeded(suite);
        return;
    catch fromNameException
    end
end

% fromParentName
factory = TestSuiteFactory.fromParentName(test, AllowsAnythingNamingConventionService);
if factory.CreatesSuiteForValidTestContent || ...
        isa(factory, 'matlab.unittest.internal.InvalidTestFactory')
    suite = factory.createSuiteFromParentName(selector);
    suite = addPathAndCurrentFolderFixturesIfNeeded(suite);
    return;
end

% fromFile
if isequal(exist(test, 'file'), 2)
    file = whichFile(test);
    if isempty(file)
        file = test;
    end
    suite = TestSuite.fromFile(file, selector);
    return;
end

% fromPackage
if ~isempty(meta.package.fromName(test))
    suite = TestSuite.fromPackage(test, selector, 'IncludingSubpackages', includeSubpackages);
    suite = addPathAndCurrentFolderFixturesIfNeeded(suite);
    return;
end

% fromFolder
if exist(test, 'dir')
    [status, info] = fileattrib(test);
    if status
        % folder relative to PWD or absolute path
        folder = info.Name;
    else
        % folder on the path
        folderInfo = what(test);
        folder = folderInfo(1).path;
    end
    suite = TestSuite.fromFolder(folder, selector, 'IncludingSubfolders', includeSubfolders);
    return;
end

me = MException(message('MATLAB:unittest:TestSuite:UnrecognizedSuite',test));
if ~isempty(fromNameException) && ...
        exist(getFilenameFromParentName(parser.ParentName), 'file') == 2
    me = me.addCause(fromNameException);
end
throwAsCaller(me);
end

function suite = addPathAndCurrentFolderFixturesIfNeeded(suite)
% Add fixtures if test content isn't on the path already.

baseFolders = {suite.BaseFolder};
[uniqueBaseFolders, ~, uniqueIdx] = unique(baseFolders);
pathFolders = strsplit(path, pathsep);
onPath = ismember(uniqueBaseFolders, pathFolders);

for idx = find(~onPath(:).')
    mask = uniqueIdx == idx;
    suite(mask) = suite(mask).addInternalPathAndCurrentFolderFixtures(uniqueBaseFolders{idx});
end
end

function validateIncludeSub(value,varname)
validateattributes(value, {'numeric','logical'}, {'scalar'}, '' ,varname)
end

function checkForOverdeterminedParameters(parser,p1,p2)
if ~any(ismember({p1,p2},parser.UsingDefaults))
    error(message('MATLAB:unittest:NameValue:OverdeterminedParameters',p1,p2));
end
end

% LocalWords:  subfolders subpackages mypackage namingconvention varname
% LocalWords:  subpackage unittest Plugins runtests isstring strsplit
