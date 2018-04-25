classdef MethodSetupParameter < matlab.unittest.parameters.Parameter
    % MethodSetupParameter - Specification of a Method Setup Parameter.
    %
    %   The matlab.unittest.parameters.MethodSetupParameter class holds
    %   information about a single value of a Method Setup Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Method Setup Parameter
    %       Name     - Name of the Method Setup Parameter
    %       Value    - Value of the Method Setup Parameter
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    methods (Access=private)
        function methodParam = MethodSetupParameter(varargin)
            methodParam = methodParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function params = getParameters(testClass, overriddenParams)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            
            overriddenParameters = {MethodSetupParameter.empty(1, 0)};
            
            if nargin == 2
                classSetupParameters = arrayfun(@getMethodSetupParamsFromOverriddenParam, ...
                    overriddenParams, 'UniformOutput', false);
                overriddenParameters = [overriddenParameters classSetupParameters];
            end
            
            uplevelParameters = SetupParameter.getAllParameterProperties(testClass, 'TestClassSetup', {});
            params = SetupParameter.getSetupParameters(testClass, @MethodSetupParameter, ...
                'TestMethodSetup', 'MethodSetupParameter', uplevelParameters, overriddenParameters);
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            
            param = SetupParameter.fromName(testClass, propName, name, ...
                @MethodSetupParameter, 'MethodSetupParameter');
        end
        
        function names = getAllParameterProperties(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            
            uplevelParameters = SetupParameter.getAllParameterProperties(testClass, 'TestClassSetup', {});
            names = SetupParameter.getAllParameterProperties(testClass, ...
                'TestMethodSetup', uplevelParameters);
        end
        
        function param = fromData(prop, name, value)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            
            param = Parameter.fromData(@MethodSetupParameter, prop, name, value);
        end
    end
end

function params = getMethodSetupParamsFromOverriddenParam(overriddenParam)
import matlab.unittest.internal.parameters.getParameterNames;
import matlab.unittest.parameters.MethodSetupParameter;
names = getParameterNames(overriddenParam.Value);
params = cellfun(@(x, y)MethodSetupParameter.fromData(overriddenParam.Name, x, y), names, overriddenParam.Value, 'UniformOutput', false);
params = [params{:}];
end

% LocalWords:  unittest uplevel
