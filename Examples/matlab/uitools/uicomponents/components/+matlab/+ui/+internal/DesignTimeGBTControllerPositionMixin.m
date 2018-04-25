classdef DesignTimeGBTControllerPositionMixin < ...
    matlab.ui.internal.DesignTimeControllerPositionMixin

    % DesignTimeGBTControllerPositionMixin A position mixin class for
    % design time GBT controllers, which encapsulates design-time position
    % behaviors.
    
    % Copyright 2015-2016 The MathWorks, Inc. 
    properties (Access='private')
        Model;
    end
    
    methods (Access='private')
        function viewPvPairs = getSizeLocationPropertiesForView(obj, propertyNames)
            viewPvPairs = {};
            
            if(any(ismember({'Position', 'Position_I'}, propertyNames)))
                % Currently, GBT components only send Position and
                % Position_I to the view (exception: uiaxes also sends
                % InnerPosition but the property is read-only).
                % Position for all GBT components now corresponds to the
                % outer art. 
                %
                % When we make the distinction between inner/outer for GBT
                % components, we can send Size/Loc for inner and
                % OuterSize/OuterLoc for outer (same as for the non-GBT
                % components, see PositionPropertiesComponentController)
                
                viewPvPairs = [viewPvPairs, ...
                    ... Send the size/location properties because the view only
                    ... knows how to work with those
                    {'Location', obj.Model.Position(1:2)},...
                    {'Size', obj.Model.Position(3:4)},...
                    {'OuterLocation', obj.Model.Position(1:2)},...
                    {'OuterSize', obj.Model.Position(3:4)},...
                    ];
            end
        end
    end
    
    methods
        %Constructor
        function obj = DesignTimeGBTControllerPositionMixin(model, view)
            obj = obj@matlab.ui.internal.DesignTimeControllerPositionMixin(model, view);
            obj.Model = model;
        end
        
        
        function additionalProperties = getAdditonalPositionPropertyNamesForView(obj)  
            additionalProperties = matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getAdditonalPositionPropertyNamesForView(obj.Model);
        end        
        
        function viewPvPairs = getPositionPropertiesForView(obj, propertyNames)
            viewPvPairs = {};

            viewPvPairs =  [viewPvPairs, ...
                obj.getSizeLocationPropertiesForView(propertyNames)];
            
            viewPvPairs =  [viewPvPairs, ...
                matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getPositionUnitsPropertiesForView(obj.Model, propertyNames)];
            
            viewPvPairs =  [viewPvPairs, ...
                matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getPositionRestrictionPropertiesForView(obj.Model, propertyNames)];
        end
        
        
    end    
    
end