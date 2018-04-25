classdef SetupParameter < matlab.unittest.parameters.Parameter
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static)
        function params = getSetupParameters(testClass, paramConstructor, setupType, paramType, uplevelParameters, varargin)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.EmptyParameter;
            
            % Get a mapping from parameter names to the method(s) which use that parameter.
            paramNameToMethodsMap = getSetupParameterMap(testClass, setupType, uplevelParameters);
            
            if isempty(paramNameToMethodsMap)
                % No setup level parameterization.
                params = {EmptyParameter.empty};
                return;
            end
            
            % Construct Parameter arrays for each parameter used.
            setupParameterArrays = getSetupLevelParameters(paramNameToMethodsMap, ...
                                    paramConstructor, paramType, testClass, varargin{:});                
                        
            % Determine how the setup methods combine the parameters.
            setupLevelCombinationAttribute = getCombinationAttribute( ...
                paramNameToMethodsMap);
            
            params = Parameter.combineParameters( ...
                setupParameterArrays, setupLevelCombinationAttribute);
        end
        
        function param = fromName(testClass, propName, name, paramConstructor, paramType)
            
            prop = testClass.PropertyList.findobj('Name',propName, paramType,true);
            if isempty(prop)
                error(message('MATLAB:unittest:Parameter:PropertyNotFound', ...
                    testClass.Name, paramType, propName));
            end
            
            param = paramConstructor(prop, name);
        end
        
        function names = getAllParameterProperties(testClass, setupType, uplevelParameters)
            paramNameToMethodsMap = getSetupParameterMap(testClass, setupType, uplevelParameters);
            names = sort(paramNameToMethodsMap.keys);
        end
    end
end


function paramNameToMethodsMap = getSetupParameterMap(testClass, setupType, uplevelParameters)
% getSetupParameterMap - Return a mapping from parameter names to the
%   method(s) which use that parameter.

import matlab.unittest.parameters.Parameter;

setupMethods = rot90(testClass.MethodList.findobj(setupType,true));
paramNameToMethodsMap = containers.Map('KeyType','char', 'ValueType','any');

for method = setupMethods
    paramNames = Parameter.getParameterNamesFor(method);
    paramNames = setdiff(paramNames, uplevelParameters);
    
    for parameterIdx = 1:numel(paramNames)
        parameterName = paramNames{parameterIdx};
        
        % Add the method to the map, appending to the list of other methods
        % that also use the parameter.
        if paramNameToMethodsMap.isKey(parameterName)
            paramNameToMethodsMap(parameterName) = [paramNameToMethodsMap(parameterName), method];
        else
            paramNameToMethodsMap(parameterName) = method;
        end
    end
end
end


function parameterArrays = getSetupLevelParameters(parameterMap, parameterConstructor, paramType, testClass, overriddenParameters)
% getSetupLevelParameters - Construct arrays of setup-level Parameters.

parameterNames = sort(parameterMap.keys);
numSetupParameters = numel(parameterNames);
parameterArrays = {};

setupParameterProperties = testClass.PropertyList.findobj(paramType,true);

for paramIdx = 1:numSetupParameters
    paramName = parameterNames{paramIdx};
    
    mask = getOverriddenParameterMask(paramName, overriddenParameters);
    if any(mask)
        overriddenSetupParameters = overriddenParameters(mask);
        parameterArrays{end+1} = overriddenSetupParameters{end}; %#ok<AGROW>
    else
        prop = setupParameterProperties.findobj('Name',paramName);
        parameterArrays{end+1} = parameterConstructor(prop); %#ok<AGROW>
    end
end
end

function mask = getOverriddenParameterMask(paramName, overriddenParameters)
mask = cellfun(@(x)any(strcmp(paramName, {x.Property})), overriddenParameters);
end


function combinationAttribute = getCombinationAttribute(paramNameToMethodMap)
% getCombinationAttribute - Determine how setup method parameters are combined.

import matlab.unittest.parameters.Parameter;

parameterizedMethods = values(paramNameToMethodMap);
combinationAttribute = parameterizedMethods{1}.ParameterCombination;
if strcmp(combinationAttribute, '')
    combinationAttribute = Parameter.DefaultCombinationAttribute;
end
end

% LocalWords:  unittest uplevel
