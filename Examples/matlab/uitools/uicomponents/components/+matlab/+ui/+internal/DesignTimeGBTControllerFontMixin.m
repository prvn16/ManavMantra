classdef DesignTimeGBTControllerFontMixin < handle
    % DESIGNTIMEGBTCONTROLLERFONTMIXIN A Font mixin class for
    % design time GBT controllers, which encapsulates design-time font
    % behaviors.
    
    % Copyright 2015-2016 The MathWorks, Inc. 
    
    properties (Access='private')
        Model;
        EventHandlingService;
    end
    
    methods
        %Constructor
        function obj = DesignTimeGBTControllerFontMixin(model, view)
            obj.Model = model;
            obj.EventHandlingService = matlab.ui.internal.componentframework.services.core.eventhandling.WebEventHandlingService;
            obj.EventHandlingService.attachView(view); % link model and ehs
        end
    end      

    methods
        
        % HANDLEFONTUPDATE
        % Controller mixin which handles Font properties updates in design time.
        % Gets called in controller's handleDesignTimePropertiesChanged(obj, peernode, data)

        % Handle Font properties updates from the client
        function handleFontUpdate (obj, updatedProperty, updatedValue)
            
            switch ( updatedProperty)
            
                case 'FontSize'
                    obj.Model.FontSize = updatedValue;
                                        
                case 'FontName'
                    obj.Model.FontName = updatedValue;
                                                     
                case 'FontAngle'
                     obj.Model.FontAngle = updatedValue;
                                                     
                case 'FontWeight'
                     obj.Model.FontWeight = updatedValue;
                     
                case 'FontUnits'
                    obj.Model.FontUnits = updatedValue;                
            end
            
        end
    end
end