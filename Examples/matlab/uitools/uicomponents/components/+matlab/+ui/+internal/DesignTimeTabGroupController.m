classdef DesignTimeTabGroupController < ...
        matlab.ui.internal.WebTabGroupController & ...
        matlab.ui.internal.DesignTimeGbtParentingController

    % DesignTimeTabGroupController A tab group controller class which encapsulates
    % the design-time specific data and behavior and establishes the gateway
    % between the Model and the View.

    % Copyright 2014-2016 The MathWorks, Inc.		
    methods

        function obj = DesignTimeTabGroupController( model, parentController, proxyView )
            % CONSTRUCTOR

            % Input verification
            narginchk( 3, 3 );		
			
            % Construct the run-time controller first
            obj = obj@matlab.ui.internal.WebTabGroupController( model, ...
                parentController, ...
                proxyView );

            % Now, construct the client-driven controller
            obj = obj@matlab.ui.internal.DesignTimeGbtParentingController(model, parentController, proxyView);
			
        end
        
        function isChildOrderReversed = isChildOrderReversed(obj)
           isChildOrderReversed = false; 
        end
       
    end

    methods ( Access=protected )        
        function handleDesignTimePropertyChanged(obj, peerNode, data)
            
            % handleDesignTimePropertyChanged( obj, peerNode, data ) 
            % Controller method which handles property updates in design time. For 
            % property updates that are common between run time and design time, 
            % this method delegates to the corresponding run time controller.
        
            % Handle property updates from the client
                
            updatedProperty = data.key;
            updatedValue = data.newValue;
            
            switch ( updatedProperty )

                case 'SelectedTab'
                    % No operation, preventing default behavior at design time.
                    
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
            
            additionalPropertyNamesForView = {'SelectionChangedFcn'};
            
            additionalPropertyNamesForView = [additionalPropertyNamesForView; ...
                getAdditionalPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj); ...
                ];
            
        end
        
        function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be excluded from the properties to sent to the view
            % 
            % Examples:
            % - Children, Parent, are not needed by the view
            % - Position, InnerPosition, OuterPosition are not updated by
            % the view and are excluded so their peer node values don't
            % become stale
            
            excludedPropertyNames = {'Enable'; 'SelectedTab'; 'SizeChangedFcn';};
            
            excludedPropertyNames = [excludedPropertyNames; ...
                getExcludedPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj); ...
                ];
        end
    end
end
