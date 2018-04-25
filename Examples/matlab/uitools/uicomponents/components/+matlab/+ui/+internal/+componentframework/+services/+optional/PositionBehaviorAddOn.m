% WEBCONTROLLER Web-based controller base class. 
classdef PositionBehaviorAddOn < matlab.ui.internal.componentframework.services.optional.BehaviorAddOn 

%   Copyright 2016-2017 The MathWorks, Inc.

    methods ( Access=protected )

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %
         %  Method:      defineViewProperties                     
         %
         %  Description: Within the context of MVC ( Model-View-Controller )   
         %               software paradigm, this is the method the "Controller"
         %               layer uses to define which properties will be consumed by
         %               the web-based user interface.
         %  Inputs:      None 
         %  Outputs:     None 
         %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         function defineViewProperties( ~, propManagementService )
             % The constructor of this class calls this method on the derived
             % class. This function needs to exist for correct binding.
             
            propManagementService.defineViewProperty( 'Position' );
            propManagementService.defineViewProperty( 'Units' );
             
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %
         %  Method:      defineRenamedProperties                     
         %
         %  Description: Within the context of MVC ( Model-View-Controller )   
         %               software paradigm, this is the method the "Controller"
         %               layer uses to rename properties, which has been defined
         %               by the "Model" layer.
         %  Inputs:      None 
         %  Outputs:     None 
         %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         function defineRenamedProperties( ~, ~ )
            % The constructor of this class calls this method on the derived
            % class. This function needs to exist for correct binding.
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %
         %  Method:      definePropertyDependencies                     
         %  Description: Within the context of MVC ( Model-View-Controller )   
         %               software paradigm, this is the method the "Controller"
         %               layer uses to establish property dependencies between 
         %               a property (or set of properties) defined by the "Model"
         %               layer and dependent "View" layer property.
         %  Inputs:      None 
         %  Outputs:     None 
         %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         function definePropertyDependencies( ~, propManagementService )
            % The constructor of this class calls this method on the derived
            % class. This function needs to exist for correct binding.
           propManagementService.definePropertyDependency( 'Position_I', ...
                                                                   'Position' );
            
         end
         
    end
    
    methods
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %
         %  Method:  Constructor                     
         %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         function this = PositionBehaviorAddOn( propManagementService )
           % Super constructor
           this = this@matlab.ui.internal.componentframework.services.optional.BehaviorAddOn( propManagementService );
         end
         
         function handled = handleClientPositionEvent( obj, ~, eventStructure, model )
            
            handled = false;
            switch ( eventStructure.Name )
                case {'insetsChangedEvent', 'positionChangedEvent'}
                    
                    % Ensure inner position was sent in pixels
                    innerValUnits = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getUnitsFromUnitsServiceClientEventData(...
                                                eventStructure, 'InnerPosition');
                    assert (strcmpi(innerValUnits, 'Pixels'));
                    
                    % Get inner position from the event structure
                    innerWithZeroOrigin = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getValueFromUnitsServiceClientEventData(...
                                                eventStructure, 'InnerPosition');
                    
                    % Ensure outer position was sent in pixels
                    outerValUnits = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getUnitsFromUnitsServiceClientEventData(...
                                                eventStructure, 'OuterPosition');
                    assert (strcmpi(outerValUnits, 'Pixels'));
                    
                    % Get outer position from the event structure
                    outerWithZeroOrigin = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getValueFromUnitsServiceClientEventData(...
                                                eventStructure, 'OuterPosition');
                                            
                    % Convert from (0,0) to (1,1) origin
                    innerWithOneOrigin = obj.convertPixelPositionFromZeroToOneOrigin(innerWithZeroOrigin);
                    outerWithOneOrigin = obj.convertPixelPositionFromZeroToOneOrigin(outerWithZeroOrigin);
                    
                    % update the model with the new values
                    model.setPositionFromClient(eventStructure.Name, ...
                                                   innerWithOneOrigin, ...
                                                   outerWithOneOrigin);            
                    
                    
                    handled = true;
                case 'default'
                    % should we do anything here?
            end    
             
         end
         
         function newPosValue = updatePosition(obj, model)
            newPosValue = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getUnitsValueDataForView(model, 'Position');
            
            unitsForView = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getUnits(newPosValue);
            if (strcmpi(unitsForView, "Pixels"))
                % If the value is in pixels, 
                % convert it from (1,1) to (0,0) origin
                pixValue = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.getValue(newPosValue);
                zeroOriginValue = obj.convertPixelPositionFromOneToZeroOrigin(pixValue);
                
                % Put the newly calculated value back into the struct
                newPosValue = matlab.ui.internal.componentframework.services.core.units.UnitsServiceController.setValueInUnitsValueDataForView(...
                                                newPosValue, zeroOriginValue);
            end
            
         end
         
         function zeroOriginValue = updatePositionInPixels(obj, oneOriginValue) 
            zeroOriginValue = obj.convertPixelPositionFromOneToZeroOrigin(oneOriginValue);
         end
         
    end
    
    methods (Static, Access = protected)

        function valZeroOrigin = convertPixelPositionFromOneToZeroOrigin(pixValue)
            valZeroOrigin = pixValue;
            valZeroOrigin(1) = valZeroOrigin(1) - 1;
            valZeroOrigin(2) = valZeroOrigin(2) - 1;
        end
        
        function valZeroOrigin = convertPixelPositionFromZeroToOneOrigin(pixValue)
            valZeroOrigin = pixValue;
            valZeroOrigin(1) = valZeroOrigin(1) + 1;
            valZeroOrigin(2) = valZeroOrigin(2) + 1;
        end
        
    end
end    
