classdef TestParameter < matlab.unittest.parameters.Parameter
    % TestParameter - Specification of a Test Parameter.
    %
    %   The matlab.unittest.parameters.TestParameter class holds
    %   information about a single value of a Test Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Test Parameter
    %       Name     - Name of the Test Parameter
    %       Value    - Value of the Test Parameter
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Access=private)
        function testParam = TestParameter(varargin)
            testParam = testParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function parameterMap = getParameters(testClass, testMethods, overriddenParams)
            import matlab.unittest.parameters.TestParameter;
            
            % Construct a map of all the TestParameters in the class so
            % that we only have to construct the TestParameter array once
            % for each property.
            testParameterProperties = rot90(testClass.PropertyList.findobj('TestParameter',true));
            parameterPropMap = containers.Map('KeyType','char', 'ValueType','any');

            for prop = testParameterProperties
                if nargin == 3 && isParameterOverridden(prop, overriddenParams)
                    parameterPropMap(prop.Name) = createTestParameterFromOverriddenParams(prop, overriddenParams);                    
                else
                    parameterPropMap(prop.Name) = TestParameter(prop);
                end
            end
            
            parameterMap = getParameterCombinationForEachMethod(testClass, testMethods, parameterPropMap);
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.parameters.TestParameter;
            
            prop = testClass.PropertyList.findobj('Name',propName, 'TestParameter',true);
            if isempty(prop)
                error(message('MATLAB:unittest:Parameter:PropertyNotFound', ...
                    testClass.Name, 'TestParameter', propName));
            end
            
            param = TestParameter(prop, name);
        end
        
        function names = getAllParameterProperties(testClass, methodName)
            import matlab.unittest.parameters.Parameter;
            
            method = testClass.MethodList.findobj('Name',methodName);
            names = Parameter.getParameterNamesFor(method);
            names = setdiff(names, getUplevelParameters(testClass));
        end
        
        function param = fromData(prop, name, value)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.TestParameter;
            
            param = Parameter.fromData(@TestParameter, prop, name, value);
        end
    end    
end

function bool = isParameterOverridden(prop, overriddenParams)
bool = any(strcmp(prop.Name, {overriddenParams.Name}));
end

function param = createTestParameterFromOverriddenParams(prop, overriddenParams)
import matlab.unittest.parameters.TestParameter;
import matlab.unittest.internal.parameters.getParameterNames;

thisParameter = overriddenParams(strcmp(prop.Name, {overriddenParams.Name}));
names = getParameterNames(thisParameter(end).Value);
overriddenTestParameters = cellfun(@(x, y)TestParameter.fromData(thisParameter(end).Name, x, y), ...
                                   names, thisParameter(end).Value, 'UniformOutput', false);
param = [overriddenTestParameters{:}];
end

function parameterMap = getParameterCombinationForEachMethod(testClass, testMethods, parameterPropMap)
import matlab.unittest.parameters.Parameter;

uplevelParameters = getUplevelParameters(testClass);
emptyParameter = {matlab.unittest.parameters.EmptyParameter.empty};

% Initialize a map of parameter arrays to return
parameterMap = containers.Map('KeyType','char', 'ValueType','any');
for methodIdx = 1:numel(testMethods)
    method = testMethods(methodIdx);
    methodName = method.Name;
    
    testParameterNames = Parameter.getParameterNamesFor(method);
    testParameterNames = setdiff(testParameterNames, uplevelParameters, 'stable');
    
    numParams = numel(testParameterNames);
    if numParams == 0
        % Method is not parameterized
        parameterMap(methodName) = emptyParameter;
        continue;
    end
    
    % Look up values of the Test Parameters and store in a cell array.
    parameters = cell(1, numParams);
    for paramIdx = 1:numParams
        paramName = testParameterNames{paramIdx};
        parameters{paramIdx} = parameterPropMap(paramName);
    end
    
    % Create the combinations according to the ParameterCombination attribute.
    parameterMap(methodName) = Parameter.combineParameters( ...
        parameters, method.ParameterCombination);
end
end

function uplevelParameters = getUplevelParameters(testClass)
import matlab.unittest.internal.parameters.SetupParameter;

classSetupParameters = SetupParameter.getAllParameterProperties(testClass, 'TestClassSetup', {});
methodSetupParameters = SetupParameter.getAllParameterProperties(testClass, 'TestMethodSetup', classSetupParameters);
uplevelParameters = [classSetupParameters, methodSetupParameters];
end

% LocalWords:  unittest uplevel
