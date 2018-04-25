classdef CallbackComponentData < handle
    
    %CallbackComponentData a class to hold component specifc data for the
    %callback
    
  % Copyright 2015 The MathWorks, Inc.
    properties (Access=public)
        % the Component's Code Name
        CodeName
        
        % the component's property for the callback.  e.g.  'ButtonPushedFcn'
        CallbackPropertyName
        
        % the component type  e.g. 'matlab.ui.control.Button'
        ComponentType
    end
    
    
    methods
        function obj = CallbackComponentData(codeName, callbackPropertyName, componentType)
            % constructor           
            obj.CodeName = codeName;
            obj.CallbackPropertyName = callbackPropertyName;
            obj.ComponentType = componentType;
        end
    end
    
end


