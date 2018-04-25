classdef DesignTimeButtonGroupController < ...
        matlab.ui.internal.WebButtonGroupController & ...
        matlab.ui.internal.DesignTimeGbtParentingController
    % DESIGNTIMEBUTTONGROUPCONTROLLER is Buttongroup Controller class which
    % encapsulates the design-time specific data, behaviour  and establishes
    % the gateway between Model and the View 
   
    %  Copyright 2015-2016 The MathWorks, Inc.
    
    methods
        
        function obj = DesignTimeButtonGroupController( model, parentController, proxyView)
            %CONSTRUCTURE
            
            %Input arguments verification
            narginchk(3, 3);
            
            %Construct the run-time controller
            obj = obj@matlab.ui.internal.WebButtonGroupController( model, parentController, proxyView);
            
            % Construct the other appdesigner base class controller
            obj = obj@matlab.ui.internal.DesignTimeGbtParentingController(model, parentController, proxyView);            
        end
    end
    
    methods (Access = protected)
        function handleDesignTimePropertyChanged(obj, peerNode, data)
            
            % handleDesignTimePropertyChanged( obj, peerNode, data ) 
            % Controller method which handles property updates in design time. For 
            % property updates that are common between run time and design time, 
            % this method delegates to the corresponding run time controller.
        
            % Handle property updates from the client
                
            updatedProperty = data.key;
            updatedValue = data.newValue;
            
            switch ( updatedProperty )
                
                case 'BorderVisibility'
                    if(updatedValue)
                        obj.Model.BorderType = 'line';
                    else
                        obj.Model.BorderType = 'none';
                    end
                    
                    obj.EventHandlingService.setProperty( 'BorderType', obj.Model.BorderType );
                    
                case 'BorderType'
                    obj.Model.BorderType = updatedValue;
                    
                    obj.EventHandlingService.setProperty( 'BorderVisibility', strcmp(obj.Model.BorderType, 'line'))
                    
                otherwise
                    % call base class to handle it
                    handleDesignTimePropertyChanged@matlab.ui.internal.DesignTimeGBTComponentController(obj, peerNode, data);                    
            end
        end
    
        function additionalPropertyNamesForView = getAdditionalPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be sent to the view for loading in addition to the 
            % ones pushed to the view defined by PropertyManagementService
            %
            % Example:
            % 1) Callback function properties
            % 2) FontUnits required by client side
            
            additionalPropertyNamesForView = {'BorderType'; 'SelectionChangedFcn'; 'FontUnits';};
            
            additionalPropertyNamesForView = [additionalPropertyNamesForView; ...
                getAdditionalPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj);
                ];
        end
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
            % properties, given the PROPERTYNAMES
            %
            % Inputs:
            %
            %   propertyNames - list of properties that changed in the
            %                   component model.
            %
            % Outputs:
            %
            %   viewPvPairs   - list of {name, value, name, value} pairs
            %                   that should be given to the view.
            
            viewPvPairs = {};
            
            % Base class
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.internal.DesignTimeGbtParentingController(obj, propertyNames)];            

            % Set the Border visibility
            value = obj.Model.BorderType;
            if(isequal(value, 'none'))
                value = false;
            else
                value = true;
            end
            viewPvPairs = [viewPvPairs, ...
                {'BorderVisibility', value}, ...
                ];            
        end
    end 
    
end

