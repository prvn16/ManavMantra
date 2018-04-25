classdef ClassSetupParameter < matlab.unittest.parameters.Parameter
    % ClassSetupParameter - Specification of a Class Setup Parameter.
    %
    %   The matlab.unittest.parameters.ClassSetupParameter class holds
    %   information about a single value of a Class Setup Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Class Setup Parameter
    %       Name     - Name of the Class Setup Parameter
    %       Value    - Value of the Class Setup Parameter
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    methods (Access=private)
        function classParam = ClassSetupParameter(varargin)
            classParam = classParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function params = getParameters(testClass, overriddenParams)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.ClassSetupParameter;
            
            overriddenParameters = {ClassSetupParameter.empty(1, 0)};
            
            if nargin == 2
                classSetupParameters = arrayfun(@getClassSetupParamsFromOverriddenParam, ...
                    overriddenParams, 'UniformOutput', false);
                overriddenParameters = [overriddenParameters classSetupParameters];
            end
            
            params = SetupParameter.getSetupParameters(testClass, @ClassSetupParameter, ...
                'TestClassSetup', 'ClassSetupParameter', {}, overriddenParameters);
            
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.ClassSetupParameter;
            
            param = SetupParameter.fromName(testClass, propName, name, ...
                @ClassSetupParameter, 'ClassSetupParameter');
        end
        
        function names = getAllParameterProperties(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            
            names = SetupParameter.getAllParameterProperties(testClass, ...
                'TestClassSetup', {});
        end
        
        function param = fromData(prop, name, value)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.ClassSetupParameter;
            
            param = Parameter.fromData(@ClassSetupParameter, prop, name, value);
        end
    end
end

function params = getClassSetupParamsFromOverriddenParam(overriddenParam)
import matlab.unittest.internal.parameters.getParameterNames;
import matlab.unittest.parameters.ClassSetupParameter;
names = getParameterNames(overriddenParam.Value);
params = cellfun(@(x, y)ClassSetupParameter.fromData(overriddenParam.Name, x, y), names, overriddenParam.Value, 'UniformOutput', false);
params = [params{:}];
end

% LocalWords:  unittest
