classdef Test < matlab.unittest.TestSuite & matlab.mixin.CustomDisplay
    % Test - Specification of a single Test method
    %
    %   The matlab.unittest.Test class holds the information needed for the
    %   TestRunner to be able to run a single Test method of a TestCase
    %   class. A scalar Test instance is the fundamental element contained
    %   in TestSuite arrays. A simple array of Test instances is a commonly
    %   used form of a TestSuite.
    %
    %   Test properties:
    %       Name               - Name of the Test element
    %       ProcedureName      - Name of the test procedure in the test
    %       TestClass          - Test class name
    %       BaseFolder         - Name of the folder that holds the file that
    %                            defines this Test element
    %       Parameterization   - Parameters for this Test element
    %       SharedTestFixtures - Fixtures for this Test element
    %       Tags               - Tags for this Test element
    %       
    %
    %   Examples:
    %
    %       import matlab.unittest.TestSuite;
    %
    %       % Create a suite of Test instances comprised of all test methods in
    %       % the class.
    %       suite = TestSuite.fromClass(?SomeTestClass);
    %       result = run(suite)
    %
    %       % Create and run a single test method
    %       run(TestSuite.fromMethod(?SomeTestClass, 'testMethod'))
    %
    %   See also: TestSuite, TestRunner
    
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    properties(Dependent, SetAccess=immutable)
        % Name - Name of the Test element
        %
        %   The Name property is a string which identifies the Test method to be
        %   run for the instance. It includes the name of the test method or function
        %   the instance applies to as well as its parent.
        Name
        
        % ProcedureName - Name of the test procedure in the test
        %
        %   The ProcedureName property describes the name of the test procedure
        %   that will be run for this test. For example, in a class based test
        %   the ProcedureName is the name of the test method, in a function based
        %   test it corresponds to the name of the local function containing the
        %   test, and in a script based test it refers to the applicable test
        %   section.
        ProcedureName
    end
    
    properties (Dependent, SetAccess=private)
        % TestClass - Test class name
        %
        %   The TestClass is the name of the class for the TestCase
        %   instance. If a Test element is not a class-based test, then
        %   TestClass is an empty string.
        TestClass
    end
    
    properties(Dependent, SetAccess=immutable)
        % BaseFolder - Name of the folder that holds the test content
        %
        %   The BaseFolder property is a string that represents the name of the
        %   folder that holds the class, function, or script that defines the test
        %   content. For test files in packages, the BaseFolder is the parent of
        %   the top-level package folder.
        BaseFolder        
    end
    
    properties (Dependent, SetAccess=private)        
        % Parameterization - Parameters for this Test element
        %
        %   The Parameterization property holds a row vector of
        %   matlab.unittest.parameters.Parameter objects that represent all the
        %   parameterized data needed for the TestRunner to run the Test method,
        %   including any parameterized TestClassSetup and TestMethodSetup methods.
        Parameterization
        
        % SharedTestFixtures - Fixtures for this Test element
        %
        %   The SharedTestFixtures property holds a row vector of
        %   matlab.unittest.fixture.Fixture objects that represent all of the
        %   fixtures required for the Test element.
        SharedTestFixtures

        % Tags - Tags for this Test element
        %
        %   The Tags property holds a cell array of strings the Test
        %   element is tagged with.
        Tags
    end
    
    properties(Hidden, Dependent, SetAccess=immutable)
        % TestParentName - Name of the test parent 
        %
        %   The name of the test class corresponding to the TestCase
        %   instance to be created for this Test. The name describes the
        %   file which contains the test.
        TestParentName
        
        % SharedTestClassName - Name of the shared test class
        %
        %   The name of the test class that groups tests that share the
        %   same set of class setup parameters   
        SharedTestClassName
        
        % TestMethodName - Test method name
        %
        %   The name of the method which describes the test method which will be
        %   run for this Test. The method name must describe a method whose Test
        %   attribute is true.
        %
        TestMethodName
        
        % TestName - Alias for the ProcedureName property
        %
        %   TestName is a temporary alias for the ProcedureName property.
        TestName
        
        % Superclasses - List of superclasses of the TestClass
        %
        %  The names of superclasses of the TestCase instance.
        Superclasses
        
        % NumInputParameters - Number of input parameters
        %
        % The number of parameters passed into the test method
        NumInputParameters
    end
    
    properties(Access=private)
        TestCaseProvider        
    end
    
    properties (Hidden, SetAccess=?matlab.unittest.TestSuite)
       InternalHiddenFixtures = matlab.unittest.fixtures.EmptyFixture.empty(); 
    end
    
    properties (Hidden, SetAccess=private)
        ClassBoundaryMarker
        InternalSharedTestFixtures
    end    
    
    methods(Hidden, Static)
        function test = fromName(name)
            import matlab.unittest.Test;
            import matlab.unittest.internal.NameParser;
            import matlab.unittest.internal.TestSuiteFactory;
            import matlab.unittest.internal.services.namingconvention.AllowsAnythingNamingConventionService;
            import matlab.unittest.selectors.HasName;
            import matlab.unittest.internal.TestCaseClassProvider;
            import matlab.unittest.parameters.ClassSetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            import matlab.unittest.parameters.TestParameter;
            
            % Parse the Name string into its parent name, test name, and
            % parameter information
            parser = NameParser(name);
            parser.parse;
            if ~parser.Valid
                error(message('MATLAB:unittest:TestSuite:InvalidName', name));
            end
            
            % Determine and validate the class, function, or script
            factory = TestSuiteFactory.fromParentName(parser.ParentName, ...
                AllowsAnythingNamingConventionService);
            
            if isa(factory, 'matlab.unittest.internal.ClassTestFactory')
                testClass = factory.TestClass;
            else
                test = factory.createSuiteExplicitly(HasName(name));
                if isempty(test)
                    error(message('MATLAB:unittest:TestSuite:InvalidTestFunction', ...
                        parser.ParentName, parser.TestName));
                end
                return;
            end
            
            % Determine and validate the TestMethod
            [status, msg, method] = convertMethodNameToMetaMethod(testClass, parser.TestName);
            if ~status
                throwAsCaller(MException(msg));
            end
            
            % Determine and validate parameters
            classSetupParameters = constructParameters(parser.ClassSetupParameters, ...
                ClassSetupParameter.getAllParameterProperties(testClass), name, 'ClassSetup', ...
                @(propName,name)ClassSetupParameter.fromName(testClass, propName, name));
            
            methodSetupParameters = constructParameters(parser.MethodSetupParameters, ...
                MethodSetupParameter.getAllParameterProperties(testClass), name, 'MethodSetup', ...
                @(propName,name)MethodSetupParameter.fromName(testClass, propName, name));
            
            testParameters = constructParameters(parser.TestMethodParameters, ...
                TestParameter.getAllParameterProperties(testClass, parser.TestName), name, 'Test', ...
                @(propName,name)TestParameter.fromName(testClass, propName, name));
            
            parameters  = [classSetupParameters, methodSetupParameters, testParameters];
            provider = TestCaseClassProvider.withSpecificParameterization(testClass, method, parameters);
            test = Test.fromProvider(provider);
        end
        
        function test = fromMethod(testClass, method, selector)
            import matlab.unittest.Test;
            import matlab.unittest.internal.TestCaseClassProvider;
            
            [status, msg] = validateClass(testClass);
            if ~status
                throwAsCaller(MException(msg));
            end
            
            validateattributes(method, ...
                {'matlab.unittest.meta.method', 'char','string'}, {'nonempty'}, '', 'method');
            
            if isa(method,'matlab.unittest.meta.method')
                if ~all([method.Test])
                    error(message('MATLAB:unittest:Test:TestMethodAttributeNeeded'));
                end
            else
                matlab.unittest.internal.validateNonemptyText(method);
                method = char(method);
                
                [status, msg, method] = convertMethodNameToMetaMethod(testClass, method);
                if ~status
                    throwAsCaller(MException(msg));
                end
            end
            
            % Optimization: early return if the selector rejects the base
            % folder, shared test fixtures, or test class (which are the
            % same for all suite elements in a class).
            if selectorRejectsBaseFolderOrSharedTestFixtures(testClass, selector)
                test = Test.empty(1,0);
                return;
            end
            
            provider = TestCaseClassProvider.withAllParameterizations(testClass, method);
            test = Test.fromProvider(provider);
            test = selectUsingAllAttributes(test, testClass, selector);
        end
        
        function test = fromClass(testClass, selector)
            import matlab.unittest.Test;
            import matlab.unittest.internal.TestCaseClassProvider;
            
            [status, msg] = validateClass(testClass);
            if ~status
                throwAsCaller(MException(msg));
            end
            
            % Optimization: early return if the selector rejects the base
            % folder , shared test fixtures, or test class (which are the
            % same for all suite elements in a class).
            if selectorRejectsBaseFolderOrSharedTestFixtures(testClass, selector)
                test = Test.empty(1,0);
                return;
            end
            
            testMethods = rot90(testClass.MethodList.findobj('Test',true), 3);
            provider = TestCaseClassProvider.withAllParameterizations(testClass, testMethods);
            test = Test.fromProvider(provider);
            test = selectUsingAllAttributes(test, testClass, selector);
        end
        
        function test = fromTestCase(testCase, testMethods)
            import matlab.unittest.Test;
            import matlab.unittest.internal.TestCaseInstanceProvider;
            
            testClass = metaclass(testCase);
            
            if nargin > 1
                validateattributes(testMethods, ...
                    {'matlab.unittest.meta.method', 'char','string'}, {'nonempty'}, '', 'testMethod');
                
                if isstring(testMethods)
                    matlab.unittest.internal.validateNonemptyText(testMethods);
                    testMethods=char(testMethods);
                end
                
                if ischar(testMethods)
                    [status, msg, testMethods] = convertMethodNameToMetaMethod(testClass, testMethods);
                    if ~status
                        throwAsCaller(MException(msg));
                    end
                elseif ~all([testMethods.Test])
                    error(message('MATLAB:unittest:Test:TestMethodAttributeNeeded'));
                end
            else
                testMethods = rot90(testClass.MethodList.findobj('Test',true), 3);
            end
            
            provider = TestCaseInstanceProvider(testCase, testMethods);
            test = Test.fromProvider(provider);
        end
        
        function test = fromFunctions(fcns, varargin)
            import matlab.unittest.Test;
            import matlab.unittest.internal.FunctionTestCaseProvider;
            
            test = Test.fromProvider(FunctionTestCaseProvider(fcns, varargin{:}));
        end
        
        function test = fromProvider(provider)
            test = repmat(matlab.unittest.Test, size(provider));
            for idx = 1:numel(provider)
                test(idx) = matlab.unittest.Test(provider(idx));
            end
            test = addClassBoundaryMarker(test);
        end
        
    end
    
    methods(Access=private)
        function test = Test(testCaseProvider)
            if nargin > 0
                test.TestCaseProvider = testCaseProvider;                                
            end
        end
        
        function test = loadTestFromPrototype(test, prototype)
            % Set properties for Tests saved in R2014b-R2016b
            import matlab.unittest.internal.ObsoleteTestCaseProviderAdapter
            
            test.TestCaseProvider    = ObsoleteTestCaseProviderAdapter(prototype);
            test.ClassBoundaryMarker = prototype.ClassBoundaryMarker;
        end
    end
    
    methods        
        function name = get.Name(test)
            import matlab.unittest.internal.getTestName
            name = getTestName(test.TestParentName, test.ProcedureName, test.Parameterization);
        end
        
        function testClass = get.TestClass(test)
            testClass = test.TestCaseProvider.TestClass;
        end
        
        function testMethod = get.TestParentName(test)
            testMethod = test.TestCaseProvider.TestParentName;
        end
        
        function sharedTestClassName = get.SharedTestClassName(test)
            import matlab.unittest.internal.getParameterNameString
            
            classSetupParams = test.Parameterization.filterByClass( ...
                'matlab.unittest.parameters.ClassSetupParameter');    
            classSetupParamsStr = getParameterNameString(classSetupParams, '[', ']'); 
            sharedTestClassName = [test.TestParentName classSetupParamsStr];
        end   
        
        function testMethodName = get.TestMethodName(test)
            testMethodName = test.TestCaseProvider.TestMethodName;
        end
        
        function testMethod = get.ProcedureName(test)
            testMethod = test.TestCaseProvider.TestName;
        end 
        
        function testMethod = get.TestName(test)
            testMethod = test.ProcedureName;
        end
        
        function folder = get.BaseFolder(test)
            import matlab.unittest.internal.getBaseFolderFromParentName;
            
            % If a PathFixture is installed, its folder is the BaseFolder
            pathFixture = findFixture(test.InternalSharedTestFixtures, ...
                'matlab.unittest.fixtures.PathFixture');
            if ~isempty(pathFixture)
                folder = pathFixture.Folder;
                return;
            end
            
            folder = test.TestCaseProvider.getBaseFolder;
        end
        
        function parameterization = get.Parameterization(test)
           parameterization = test.TestCaseProvider.Parameterization; 
        end
        
        function sharedTestFixtures = get.SharedTestFixtures(test)
           sharedTestFixtures = test.TestCaseProvider.SharedTestFixtures; 
        end
        
        function tags = get.Tags(test)
            tags = test.TestCaseProvider.Tags;
        end
        
        function internalSharedTestFixtures = get.InternalSharedTestFixtures(test)
            providerFixtures = test.TestCaseProvider.InternalSharedTestFixtures;
            hiddenFixtures   = test.InternalHiddenFixtures;
            internalSharedTestFixtures = [providerFixtures, hiddenFixtures];
        end     
        
        function superClassList = get.Superclasses(test)
            superClassList = test.TestCaseProvider.getSuperclasses;
        end
        
        function numInputParameters = get.NumInputParameters(test)
            numInputParameters = test.TestCaseProvider.NumInputParameters;
        end
    end

    methods(Hidden)
        function testCase = provideClassTestCase(test)
            testCase = test.TestCaseProvider.provideClassTestCase;
        end
        
        function testCase = createTestCaseFromClassPrototype(test, classTestCase)
            testCase = test.TestCaseProvider.createTestCaseFromClassPrototype(classTestCase);
        end
        
        function idx = matchProviders(suite1, suite2)

            getProviderClass = @(a) class(a.TestCaseProvider);
            provider1Classes = arrayfun(getProviderClass, suite1, 'UniformOutput', false);
            provider2Classes = arrayfun(getProviderClass, suite2, 'UniformOutput', false);
            
            [~, idx] = ismember(provider2Classes, provider1Classes);            
            
        end
        
        function test = addInternalPathAndCurrentFolderFixtures(test, folder)
            import matlab.unittest.internal.fixtures.HiddenPathFixture;
            import matlab.unittest.internal.fixtures.HiddenCurrentFolderFixture;
            
            % Add a PathFixture and CurrentFolderFixture to ensure that this folder
            % is placed on the path at runtime and that the runner CDs to it.
            hiddenFixtures = [HiddenPathFixture(folder), HiddenCurrentFolderFixture(folder)];
            [test.InternalHiddenFixtures] = deal(hiddenFixtures);
        end        
    end
    
    methods(Hidden, Access=protected)
        function footerStr = getFooter(suite)
            % getFooter - Override of the matlab.mixin.CustomDisplay hook method
            %   Displays a summary of the test suite.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            testsIncludeHeader = getString(message('MATLAB:unittest:TestSuite:TestsInclude'));
            
            parameterizationFooter          = constructParameterizationFooter([suite.Parameterization]);
            sharedTestFixtureClassesFooter  = constructSharedTestFixtureClassesFooter([suite.SharedTestFixtures]);
            tagsFooter                      = constructTagsFooter([suite.Tags]);
            
            indention = '  ';
            separator = ' ';
            footerStr = sprintf('%s\n%s%s%s%s\n', testsIncludeHeader, ...
                indention, ...
                indent([parameterizationFooter ','], separator), ...
                indent([sharedTestFixtureClassesFooter ','], separator), ...
                indent([tagsFooter '.'] , separator));
        end
    end
    
    
    methods (Hidden)
        function testStruct = saveobj(test)
            % R2017a
            testStruct.V6.TestCaseProvider       = test.TestCaseProvider;
            testStruct.V6.InternalHiddenFixtures = test.InternalHiddenFixtures;
            testStruct.V6.ClassBoundaryMarker    = test.ClassBoundaryMarker; 
        end
    end
    
    methods (Hidden, Static)
        function test = loadobj(testStruct)
            import matlab.unittest.internal.TestCaseClassProvider;
            
            % Construct a new Test and assign properties.
            test = matlab.unittest.Test;
            
            if isfield(testStruct, 'V6') % R2017a, R2017b
                test.TestCaseProvider = testStruct.V6.TestCaseProvider;
                test.InternalHiddenFixtures = testStruct.V6.InternalHiddenFixtures;
                test.ClassBoundaryMarker = testStruct.V6.ClassBoundaryMarker;
            elseif isfield(testStruct, 'V5') % R2015a, R2015b, R2016a, R2016b
                testStruct.V5.Tags = reshape(testStruct.V5.Tags,1,[]);
                test = test.loadTestFromPrototype(testStruct.V5);
            end
        end
        
        function test = fromClassOverridingParameters(testClass, overriddenParameter)
            import matlab.unittest.Test;
            import matlab.unittest.internal.TestCaseClassProvider;            
            
            testMethods = rot90(testClass.MethodList.findobj('Test',true), 3);
            provider = TestCaseClassProvider.withAllParameterizations(testClass, testMethods, overriddenParameter);
            test = Test.fromProvider(provider);
        end
    end
end


function [status, msg] = validateClass(testClass)
status = false;

mcls = metaclass(testClass);

if mcls <= ?matlab.unittest.TestCase
    msg = message('MATLAB:unittest:TestSuite:NonMetaClass');
    return;
end
if ~(mcls <= ?meta.class)
    msg = message('MATLAB:unittest:TestSuite:NonMetaclass');
    return;
end
if isempty(testClass)
    msg = message('MATLAB:unittest:TestSuite:InvalidClass');
    return;
end
if ~(mcls <= ?matlab.unittest.meta.class)
    msg = message('MATLAB:unittest:TestSuite:NonTestCase');
    return;
end
if ~isscalar(testClass)
    msg = message('MATLAB:unittest:TestSuite:NonscalarClass');
    return;
end
if testClass.Abstract
    msg = message('MATLAB:unittest:TestSuite:AbstractTestCase', testClass.Name);
    return;
end

status = true;
msg = message.empty;
end

function [status, msg, metaMethod] = convertMethodNameToMetaMethod(testClass, methodName)
status = false;

metaMethod = findobj(testClass.MethodList, 'Name', methodName);
if isempty(metaMethod)
    msg = message('MATLAB:unittest:TestSuite:InvalidMethodName', methodName, testClass.Name);
    metaMethod = [];
    return;
end

if ~metaMethod.Test
    msg = message('MATLAB:unittest:Test:TestMethodAttributeNeeded');
    metaMethod = [];
    return;
end

status = true;
msg = message.empty;
end

function bool = selectorRejectsBaseFolderOrSharedTestFixtures(testClass, selector)
import matlab.unittest.internal.getBaseFolderFromParentName;
import matlab.unittest.internal.selectors.SelectionAttribute;
import matlab.unittest.internal.selectors.BaseFolderAttribute;
import matlab.unittest.internal.selectors.SharedTestFixtureAttribute;
import matlab.unittest.internal.determineSharedTestFixturesFor;
import matlab.unittest.internal.selectors.SuperclassAttribute;
import matlab.unittest.internal.getAllSuperclassNamesInHierarchy;

% Filter on base folder
if selector.uses(?matlab.unittest.internal.selectors.BaseFolderAttribute)
    folderAttribute = BaseFolderAttribute(getBaseFolderFromParentName(testClass.Name));
    
    % Check for possible early return if the selector rejects the folder
    if selector.reject(folderAttribute)
        bool = true;
        return;
    end
end

% Filter on superclass
if selector.uses(?matlab.unittest.internal.selectors.SuperclassAttribute)
    superclassAttribute = SuperclassAttribute(getAllSuperclassNamesInHierarchy(testClass));
    
    % Check for possible early return if the selector rejects the
    % superclass
    if selector.reject(superclassAttribute)
        bool = true;
        return;
    end
end


% Filter on shared test fixtures
if selector.uses(?matlab.unittest.internal.selectors.SharedTestFixtureAttribute)
    sharedTestFixtures = determineSharedTestFixturesFor(testClass);
    fixtureAttribute = SharedTestFixtureAttribute(sharedTestFixtures);
    
    % Check for possible early return if the selector rejects the fixtures
    if selector.reject(fixtureAttribute)
        bool = true;
        return;
    end
end

bool = false;
end

function test = selectUsingAllAttributes(test, testClass, selector)
% Perform selection with the knowledge that the base folder and shared test
% fixtures are homogeneous.

import matlab.unittest.internal.getBaseFolderFromParentName;
import matlab.unittest.internal.determineSharedTestFixturesFor;
import matlab.unittest.internal.selectors.SelectionAttribute;
import matlab.unittest.internal.selectors.BaseFolderAttribute;
import matlab.unittest.internal.selectors.SharedTestFixtureAttribute;
import matlab.unittest.internal.selectors.NameAttribute;
import matlab.unittest.internal.selectors.ParameterAttribute;
import matlab.unittest.internal.selectors.TagAttribute;
import matlab.unittest.internal.selectors.ProcedureNameAttribute;

% Determine which attributes the selector uses
usesBaseFolder = selector.uses(?matlab.unittest.internal.selectors.BaseFolderAttribute);
usesName = selector.uses(?matlab.unittest.internal.selectors.NameAttribute);
usesParameter = selector.uses(?matlab.unittest.internal.selectors.ParameterAttribute);
usesSharedTestFixture = selector.uses(?matlab.unittest.internal.selectors.SharedTestFixtureAttribute);
usesTag = selector.uses(?matlab.unittest.internal.selectors.TagAttribute);
usesProcedureName = selector.uses(?matlab.unittest.internal.selectors.ProcedureNameAttribute);

emptySelectionAttribute = SelectionAttribute.empty;

folderAttribute = emptySelectionAttribute;
if usesBaseFolder
    folderAttribute = BaseFolderAttribute(getBaseFolderFromParentName(testClass.Name));
end

sharedTestFixtures = determineSharedTestFixturesFor(testClass);
fixtureAttribute = emptySelectionAttribute;
if usesSharedTestFixture
    fixtureAttribute = SharedTestFixtureAttribute(sharedTestFixtures);
end

mask = true(size(test));

for idx = 1:numel(test)
    nameAttribute = emptySelectionAttribute;
    if usesName
        nameAttribute = NameAttribute(test(idx).Name);
    end
    
    parameterAttribute = emptySelectionAttribute;
    if usesParameter
        parameterAttribute = ParameterAttribute(test(idx).Parameterization);
    end
    
    tagAttribute = emptySelectionAttribute;
    if usesTag
        tagAttribute = TagAttribute(test(idx).Tags);
    end
    
    procedureNameAttribute = emptySelectionAttribute;
    if usesProcedureName
        procedureNameAttribute = ProcedureNameAttribute(test(idx).ProcedureName);
    end
    
    % Determine the result of filtering using all attributes
    attributes = [folderAttribute, nameAttribute, parameterAttribute, fixtureAttribute, tagAttribute, procedureNameAttribute];
    mask(idx) = selector.select(attributes);
end

if ~all(mask)
    % Logical indexing may reshape; only perform if needed
    test = test(mask);
end
end

function parameters = constructParameters(paramInfo, allParamPropNames, name, paramType, fromNameMethod)
import matlab.unittest.parameters.EmptyParameter;

% Make sure the correct set of parameters was specified
if ~isempty(setxor(allParamPropNames, {paramInfo.Property}))
    if isempty(allParamPropNames)
        error(message('MATLAB:unittest:TestSuite:NoParametersNeeded', ...
            paramType));
    else
        error(message('MATLAB:unittest:TestSuite:IncorrectParameters', ...
            paramType, name, strjoin(allParamPropNames,', ')));
    end
end

numParameters = numel(paramInfo);
parameters(1:numParameters) = EmptyParameter;
for idx = 1:numParameters
    parameters(idx) = fromNameMethod(paramInfo(idx).Property, paramInfo(idx).Name);
end
end

function fixture = findFixture(fixtureArray, className)
fixture = fixtureArray(find(arrayfun(@(f)isa(f,className), fixtureArray), 1, 'first'));
end

function suite = addClassBoundaryMarker(suite)
if ~isempty(suite)
    [suite.ClassBoundaryMarker] = deal(matlab.unittest.internal.ClassBoundaryMarker);
end
end

function footer = constructParameterizationFooter(parameterization)
import matlab.unittest.internal.richFormattingSupported;

parameters = getUniqueParameters(parameterization);
footer = constructFooter(size(parameters, 1), ...
    'ZeroParameterizationsFooter', ...
    'SingleParameterizationFooter', ...
    'MultipleParameterizationsFooter');

% Early return if hyperlinking is not necessary                                    
if isempty(parameters) || ~richFormattingSupported
    return;
end

% Construct hyperlinked footer string
footer = sprintf('<a href="matlab:matlab.unittest.internal.diagnostics.displayCellArrayAsTable([{%s}, {%s}], {''%s'' ''%s''})">%s</a>', ...
    sprintf('''%s'';',parameters{:, 1}), ...    % First column (Parameter Property)
    sprintf('''%s'';',parameters{:, 2}), ...    % Second column (Parameter Name)
    'Property', ...                             % First column name
    'Name', ...                                 % Second column name
    footer);

end

function footer = constructSharedTestFixtureClassesFooter(fixtures)
import matlab.unittest.internal.richFormattingSupported;

fixtureNames = arrayfun(@class, fixtures, 'UniformOutput', false)';
fixtureNames = unique(fixtureNames);
footer = constructFooter(numel(fixtureNames), ...
            'ZeroSharedTestFixturesFooter', ...
            'SingleSharedTestFixtureFooter', ...
            'MultipleSharedTestFixturesFooter');

% Early return if hyperlinking is not necessary                                    
if isempty(fixtureNames) || ~richFormattingSupported
    return;
end

footer = sprintf('<a href="matlab:matlab.unittest.internal.diagnostics.displayCellArrayAsTable({%s}, {''%s''})">%s</a>', ...
    sprintf('''%s'';',fixtureNames{:}), ...    
    'FixtureName', ...                      
    footer);

end

function footer = constructTagsFooter(tags)
import matlab.unittest.internal.richFormattingSupported;

tags = unique(tags);
footer = constructFooter(numel(tags), ...
            'ZeroTagsFooter', ...
            'SingleTagFooter', ...
            'MultipleTagsFooter');

% Early return if hyperlinking is not necessary                                    
if isempty(tags) || ~richFormattingSupported
    return;
end

encodedTags = cellfun(@mat2str, cellfun(@double, tags, 'UniformOutput', false), 'UniformOutput', false);
footer = sprintf('<a href="matlab:matlab.unittest.internal.diagnostics.displayCellArrayAsTable({%s}, {''%s''})">%s</a>', ...
    sprintf('%s;', encodedTags{:}), ...
    'Tag', ...                      
    footer);

end

function footer = constructFooter(numAttributes, zeroElementsHeader, singleElementHeader, multipleElementsHeader)

switch numAttributes
    case 0
        footer = getString(message(sprintf('MATLAB:unittest:TestSuite:%s', zeroElementsHeader)));
    case 1
        footer = getString(message(sprintf('MATLAB:unittest:TestSuite:%s', singleElementHeader)));
    otherwise
        footer = getString(message(sprintf('MATLAB:unittest:TestSuite:%s', multipleElementsHeader), numAttributes));
end

end

function parameters = getUniqueParameters(parameterization)
% Determine unique parameters.

if isempty(parameterization)
    parameters = {};
    return;
end

% Parameter property/names have to be valid MATLAB identifiers. Therefore,
% we use non identifiers to join/separate parameter combinations to
% determine uniqueness. 
PROPERTY_NAME_PAIR_DELIMITER  = '#';
PROPERTY_NAME_COMBO_SEPARATOR = '$';

parameters = [{parameterization.Property}' {parameterization.Name}'];

% Join cell array of parameters in this form:
% param1#loop1$param2#loop2
% # joins parameter property/name combination
% $ separates property/name combinations
delimiter = cell(1, numel(parameters)-1);
delimiter(1:2:end) = {PROPERTY_NAME_PAIR_DELIMITER};
delimiter(2:2:end) = {PROPERTY_NAME_COMBO_SEPARATOR};
joinedString = strjoin(parameters', delimiter);

% Split the string into parameter property/name combinations
parameters = strsplit(joinedString, PROPERTY_NAME_COMBO_SEPARATOR);

% Get unique parameters
parameters = unique(parameters);

% Split parameter combinations into property/name pairs (N x 2 cell array)
parameters = cellfun(@(s) strsplit(s, PROPERTY_NAME_PAIR_DELIMITER), parameters, 'UniformOutput', false);
parameters = reshape([parameters{:}], 2, numel(parameters))';
end

% LocalWords:  c'tor Teardownable isscript namingconvention Parameterizations
% LocalWords:  CDs isstring mcls
