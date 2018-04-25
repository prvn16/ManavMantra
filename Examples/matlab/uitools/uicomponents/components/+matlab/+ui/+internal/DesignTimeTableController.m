classdef DesignTimeTableController < ...
        matlab.ui.internal.controller.uitable.WebTableController & ...
        matlab.ui.internal.DesignTimeGBTComponentController
    % DesignTimePanelController A table controller class which encapsulates
    % the design-time specific dta and behaviour and establishes the
    % gateway between the Model and the View
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    methods
        
        function obj = DesignTimeTableController( model, parentController, proxyView)
            %CONSTRUCTURE
            
            %Input verification
            narginchk( 3, 3 );
            
            % Construct the run-time controller first
            obj = obj@matlab.ui.internal.controller.uitable.WebTableController( model, parentController, proxyView );
            
            % Construct the DesignTimeGBTComponentController last to ensure
            % controller injection, and view attaching finished from
            % run-time WebComponentController
            obj = obj@matlab.ui.internal.DesignTimeGBTComponentController(model, parentController, proxyView);
            
            % create design-time table view implementation.
            if ~isempty(obj.ProxyView)
                obj.createDesignTimeTableViewWithPeerNode();                
            end
            
        end
        
        function createDesignTimeTableViewWithPeerNode (this)
            this.createTableServer();
            % Once we have server side ready,
            % propagate all properties from mode to view
            this.triggerUpdatesOnDependentViewProperties();
            this.fireServerReadyEvent();
        end
        
        % Override MCF's update method ONLY for design time table for its
        % Server-driven properties like Data.
        % Unlike run time, updating property in design time will only call update methods,
        % but not erase values in PeerNode.
        function triggerUpdateOnDependentViewProperty( obj, property )
            feval( eval( [ '@obj.update' property ] ) );
        end
    end
    
    methods (Access=protected)
        function handleDesignTimePropertyChanged(obj, peerNode, data)
            
            % handleDesignTimePropertyChanged( obj, peerNode, data ) 
            % Controller method which handles property updates in design time. For 
            % property updates that are common between run time and design time, 
            % this method delegates to the corresponding run time controller.
        
            % Handle property updates from the client
                
            updatedProperty = data.key;
            updatedValue = data.newValue;
            
            switch ( updatedProperty )
                
                case 'ColumnName'
                    % Set ColumnName
                    obj.Model.ColumnName = updatedValue;
                    % TODO for Zhengwen: Add comments for the next line
                    if obj.ServerReady
                        obj.setProperty('ColumnName_I');
                    end
                    
                case 'ColumnWidth'
                    if(strcmp(updatedValue, 'auto'))
                        obj.Model.ColumnWidth = updatedValue;
                    elseif(isa(updatedValue , 'double'))
                        % g1383730
                        % When all values are numeric,
                        % it comes in as a 1* n double array but
                        % this is not an allowed input for ColumnWidth
                        % Transform this value into a 1* n cell array
                        obj.Model.ColumnWidth = num2cell(updatedValue);
                    else
                        obj.Model.ColumnWidth = updatedValue;
                    end
                    
                    if obj.ServerReady
                        obj.setProperty('ColumnWidth_I');
                    end
                
                case 'RowName'
                    if isempty(updatedValue)
                        % Not support RowName, and this is for the case of
                        % dragging or pasting a uitable in the Canvas
                        obj.Model.RowName = {};
                    end
                     
                case 'RowStriping'
                    obj.Model.RowStriping = updatedValue;
                    if obj.ServerReady
                        obj.setProperty('RowStriping');
                    end
                    
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
            
            additionalPropertyNamesForView = { 
                'RowStriping'; ...
                'CellEditCallback'; ...
                'CellSelectionCallback'; ...
                'FontUnits'; ...
                };
            
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
            
            excludedPropertyNames = {'BackgroundColor'; 'ColumnFormat';};
            
            excludedPropertyNames = [excludedPropertyNames; ...
                getExcludedPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj); ...
                ];
            
        end
    end
end