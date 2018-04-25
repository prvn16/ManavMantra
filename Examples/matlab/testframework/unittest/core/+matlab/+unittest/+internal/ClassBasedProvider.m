classdef (Hidden) ClassBasedProvider < matlab.unittest.internal.TestCaseProvider
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        Parameterization = matlab.unittest.parameters.EmptyParameter.empty;
        SharedTestFixtures = matlab.unittest.fixtures.EmptyFixture.empty;
        Tags = cell(1,0);
    end
    
    properties (Access = private)
        Superclasses = string.empty
    end
    
    properties (Dependent, SetAccess = immutable)
        TestClass
    end
    
    methods (Access=protected)
        function provider = assignTags(provider, testClass, methods)
            import matlab.unittest.internal.determineTagsFor;
            
            tagMap = determineTagsFor(testClass, methods);
            for methodIdx = 1:numel(methods)
                provider(methodIdx).Tags = tagMap(methods(methodIdx).Name);
            end
        end
        
        function provider = assignSharedTestFixtures(provider, testClass)
            import matlab.unittest.internal.determineSharedTestFixturesFor;
            
            [provider.SharedTestFixtures] = deal(determineSharedTestFixturesFor(testClass));
        end
        
        function provider = assignNumInputParameters(provider, methods)
            numInputParameters = arrayfun(@(x)max(0, numel(x.InputNames) - 1), ...
                methods, 'UniformOutput', false);
            [provider.NumInputParameters] = numInputParameters{:};
        end
        
        function provider = setParameterization(provider, parameterization)
            provider.Parameterization = parameterization;
        end
        
        function expansion = expandBasedOnParameterization(provider, testClass, methods, varargin)
            import matlab.unittest.parameters.ClassSetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            import matlab.unittest.parameters.TestParameter;
            
            classSetupParameters = ClassSetupParameter.getParameters(testClass, varargin{:});
            methodSetupParameters = MethodSetupParameter.getParameters(testClass, varargin{:});
            testParameterMap = TestParameter.getParameters(testClass, methods, varargin{:});
            
            expansion = cell(size(provider));
            expansion = repmat({expansion}, 1, numel(methodSetupParameters));
            expansion = repmat({expansion}, 1, numel(classSetupParameters));
            
            for classSetupParameterIdx = 1:numel(classSetupParameters)
                classParameter = classSetupParameters{classSetupParameterIdx};
                
                for methodSetupParameterIdx = 1:numel(methodSetupParameters)
                    methodParameter = methodSetupParameters{methodSetupParameterIdx};
                    
                    for methodIdx = 1:numel(methods)
                        currentMethod = methods(methodIdx);
                        currentProvider = provider(methodIdx);
                        testParameters = testParameterMap(currentMethod.Name);
                        
                        providersForCurrentMethod = repmat(currentProvider, 1, numel(testParameters));
                        for paramIdx = 1:numel(testParameters)
                            providersForCurrentMethod(paramIdx).Parameterization = ...
                                [classParameter, methodParameter, testParameters{paramIdx}];
                        end
                        
                        expansion{classSetupParameterIdx}{methodSetupParameterIdx}{methodIdx} = providersForCurrentMethod;
                    end
                end
            end
            
            % Flatten
            expansion = [expansion{:}];
            expansion = [expansion{:}];
            expansion = [provider.empty, expansion{:}];
            
            if numel(expansion) == numel(methods)
                expansion = reshape(expansion, size(methods));
            end
        end
        
        function provider = determineSuperclasses(provider,testClass)
            import matlab.unittest.internal.getAllSuperclassNamesInHierarchy;
            
            superClassNames = getAllSuperclassNamesInHierarchy(testClass);
            [provider.Superclasses] = deal(superClassNames);
        end
        
    end
    
    methods        
        function superClasses = getSuperclasses(provider)
            if isempty(provider.Superclasses)
                error(message('MATLAB:unittest:TestSuite:UnableToSelectBasedOnTestClass'));
            else
                superClasses = provider.Superclasses;
            end
        end
        
        function testClass = get.TestClass(provider)
            testClass = string(provider.TestParentName);
        end
    end
end

