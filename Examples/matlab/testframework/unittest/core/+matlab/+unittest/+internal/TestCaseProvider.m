classdef(Hidden) TestCaseProvider
    % Class to help abstract different ways to provide testCases. This is
    % used when constructing TestSuite, some of which have a TestCase
    % prototype and some of which only have the TestCase meta classes.
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    
    properties(Abstract, SetAccess=immutable)
        TestClass
        TestParentName
        TestMethodName
        TestName
    end
    
    properties(Abstract, SetAccess=private)
        SharedTestFixtures
        Parameterization
        Tags
    end

    properties (SetAccess=protected)
        InternalSharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        NumInputParameters = 0;
    end
    
    methods(Abstract)
        testCase = provideClassTestCase(provider);
        testCase = createTestCaseFromClassPrototype(provider, classTestCase);
    end
        
    methods
        function baseFolder = getBaseFolder(provider)
            import matlab.unittest.internal.getBaseFolderFromParentName;
            baseFolder = getBaseFolderFromParentName(provider.TestParentName);
        end

        function superClasses = getSuperclasses(~)
            superClasses = string.empty;
        end
        
    end
    
    methods (Access = protected)
        function testClass = getDefaultTestClass(~)
            testClass = string.empty;
        end
    end
end
