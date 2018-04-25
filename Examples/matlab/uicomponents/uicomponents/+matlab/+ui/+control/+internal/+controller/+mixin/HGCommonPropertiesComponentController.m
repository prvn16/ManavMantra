classdef (Hidden) HGCommonPropertiesComponentController < appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % Mixin Controller Class for components with Tag, Text, UserData
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function excludedProperties = getExcludedHGCommonPropertyNamesForView(obj)
            % Common HG Properties
            
            excludedProperties = {...
                'Tag'; ...           % GraphicsBaseFunctions
                'Type'; ...          % GraphicsBaseFunctions
                'UserData'; ...      % GraphicsBaseFunctions
                'CreateFcn'; ...      % GraphicsCoreProperties
                'DeleteFcn'; ...     % GraphicsCoreProperties
                'BeingDeleted'; ...  % GraphicsCoreProperties
                };
        end
        
    end
end
