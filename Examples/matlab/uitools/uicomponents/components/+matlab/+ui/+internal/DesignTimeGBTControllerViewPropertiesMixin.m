classdef DesignTimeGBTControllerViewPropertiesMixin < appdesservices.internal.interfaces.controller.mixin.ViewPropertiesHandler
        
    % DESIGNTIMEGBTCONTROLLERVIEWPROPERTIESMIXIN A position mixin class for
    % design time GBT controllers, which encapsulates design-time position
    % behaviors.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access='private')
        Model;
    end
    
    methods
        %Constructor
        function obj = DesignTimeGBTControllerViewPropertiesMixin(model)
            obj.Model = model;
        end
    end    

    methods(Access = protected, Sealed = true)
        function propertiesForView = getPropertyNamesForView(obj)
            % Get the properties to be sent to the view. 
            % By default, all the public properties of the component are
            % sent.
            % If more or less properties are to be sent, subclasses should
            % use the methods:
            % -- getAdditionalPropertyNamesForView to add properties
            % -- getExcludedPropertyNamesForView to exclude properties
            % 
            % An example of such information is the aspect ratio limits:
            % the information needs to be sent to the view but is not a
            % public property
            propertyManagementService = obj.getPropertyManagementService();
            propertiesForView = propertyManagementService.getViewProperties();
            
            % Add common properties
            commonProperties = getCommonPropertyNamesForView(obj);
            propertiesForView = union(propertiesForView, commonProperties);
            
            % Additional propertyies
            additionalProperties = getAdditionalPropertyNamesForView(obj);
            propertiesForView = union(propertiesForView, additionalProperties);
                        
            % Add DesignTimeProperties
            propertiesForView = union(propertiesForView, {'DesignTimeProperties'});
        end
    end
    
    methods(Access = protected)
        function commonPropertyNamesForView = getCommonPropertyNamesForView(obj)
            % Common properties for view of GBT components
            %
            
            commonPropertyNamesForView = {'HandleVisibility','BusyAction','Interruptible'};
        end
    end
end
