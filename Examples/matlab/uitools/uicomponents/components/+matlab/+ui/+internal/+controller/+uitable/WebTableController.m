classdef WebTableController < matlab.ui.internal.componentframework.WebComponentController & ...
        matlab.ui.internal.controller.uitable.WebControllerViewInterface
    %WEBTABLECONTROLLER Web-based controller for UITable.

%   Copyright 2014-2017 The MathWorks, Inc.
    
    properties (SetAccess='protected', GetAccess='public')
        view
    end
    
    properties(Access = 'protected')
        positionBehavior
        cellEditingHandler
        ServerReady = false;
    end
    
    properties (Access='private')
        cachedDataWidth = 0;
    end
    
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = WebTableController( model, varargin )
            
            % Super constructor
            this = this@matlab.ui.internal.componentframework.WebComponentController( model, varargin{:});
            this.positionBehavior = matlab.ui.internal.componentframework.services.optional.PositionBehaviorAddOn(this.PropertyManagementService);
            this.cellEditingHandler = matlab.ui.internal.controller.uitable.UITableCellEditingHandler(model);
        end 
        
        function add( obj, ~, parentController )
            
            %Create server side
            obj.createTableServer();   
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Call add method in base class
            %
            % Copy and paste the add method in base class to empty
            % table-related properties (Data, ColumnName etc) in PV
            % pairs for PeerNode construction - g1428989. 
            % TODO: create another geck g1430203 for MCF to have a better
            % way to redirect table-related properties not to PeerNode but
            % to DataTools VariableEditor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve the peer node of the parent
            obj.ParentController = parentController;
            parentView = obj.getParentView( parentController );

            % Create property/value (PV) pairs and convert them to java map
            pvPairs = obj.PropertyManagementService.definePvPairs( obj.Model );
            
            % empty VariableEditor properties in pv pairs - g1428989
            ve_props = {'Data', 'ColumnEditable', 'ColumnName', 'RowName', 'ColumnFormat', ...
                    'BackgroundColor', 'ForegroundColor', 'FontAngle', 'FontName', ...
                    'FontSize', 'FontWeight', 'ColumnWidth'};
            for i = 1:2:length(pvPairs)
                prop_name = pvPairs{i};
                if ismember(prop_name, ve_props)
                    %empty this property from pvPairs
                    pvPairs{i+1} = '';
                end
            end
            
            map = obj.EventHandlingService.convertPvPairsToJavaMap( pvPairs ); 

            % Add this web component as a child to the peer node hierarchy
            obj.createView( parentController, parentView, map );

            % Have the EHS attach to the view
            obj.EventHandlingService.attachView( obj.ProxyView );

            % For applicable view properties which participate in dependencies with
            % model properties, trigger the customized update methods.  
            obj.triggerUpdatesOnDependentViewProperties;

            % Post add operation
            obj.postAdd();
            %%%%%%%%%%%%%%%% End of Copy %%%%%%%%%%%%%%%
            
            
            % send table ServerReady to client side.
            obj.fireServerReadyEvent();
        end        
        
        function fireServerReadyEvent(this)
            % tell client side 'ServerReady' with DocumentID and ChannelID
            % for Data tools table creation.
            if this.ServerReady
                documentID = this.view.getDocument().DocID;
                channelID = this.view.getChannel();

                payload = this.EventHandlingService.convertPvPairsToJavaMap({'DocumentID', documentID, 'ChannelID', channelID});
                this.EventHandlingService.dispatchEvent('ServerReady', payload);
            end
        end
        
        function delete(this)
            delete(this.view); 
            this.ServerReady = false;
        end
    end
    
    % interface methods that are called from view implementation.
    methods
        % update all view properties from model to view.
        function updateViewProperties (this, varargin)
            this.triggerUpdatesOnDependentViewProperties(varargin{:});
        end        
        
        % check if ColumnNameMode is auto
        function isAuto = isColumnNameModeAuto(this)
            isAuto = isequal(this.Model.ColumnNameMode, 'auto');
        end
        
        % check if RowNameMode is auto
        function isAuto = isRowNameModeAuto(this)
            isAuto = isequal(this.Model.RowNameMode, 'auto');
        end
        
        % check if Model is deleted
        function isDeleted = isModelDeleted(this)
            isDeleted = ~isvalid(this.Model);
        end
        
        % set model ColumnName
        function setModelColumnName(this, name)
            if ~isempty(name) 
                this.Model.ColumnName_I = name; % avoid mode change.
            else 
                this.Model.ColumnName_I = {};
            end
            this.updateColumnName();
        end
        
        % set model RowName
        function setModelRowName(this, name)
            if ~isempty(name) 
                this.Model.RowName_I = name; % avoid mode change.
            else 
                this.Model.RowName_I = {};
            end
            this.updateRowName();
        end        
    end
        
        
    methods
        function newData = updateData(this)
            
            % @ToDo: There is no way to update single cell.
            newData = '';
            this.view.setData(this.Model.Data); 
            
            % cache Data size here.
            % Only when the number of columns changes,
            % Column width are reset and re-calculated in the view.
            newDataWidth = size(this.Model.Data, 2);
            if ~isequal(this.cachedDataWidth, newDataWidth)
                this.updateColumnWidth();
            end
            
            this.cachedDataWidth = newDataWidth;
        end 
        
        function newColumnEditable = updateColumnEditable(this)
            newColumnEditable = '';
            %Set the data from Model to the View
            this.view.setColumnEditable(this.Model.ColumnEditable);    
        end 

        function newColumnFormat = updateColumnFormat(this)
            newColumnFormat = '';
            % set ColumnFormat to the TableView
            this.view.setColumnFormat(this.Model.ColumnFormat);
        end
        
        function newColumnWidth = updateColumnWidth(this)
            newColumnWidth = '';
            this.view.setColumnWidth(this.Model.ColumnWidth);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateColumnName
        %
        %  Description: Custome method to set ColumnName.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newColumnName = updateColumnName(this)
            newColumnName = '';
            % when there is no Data, we can still set columnName property
            % to just show column headers. g1393590.
            this.view.setColumnName(this.Model.ColumnName);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateRowName
        %
        %  Description: Custome method to set RowName.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newRowName = updateRowName(this)
            newRowName = '';    
            this.view.setRowName(this.Model.RowName);   
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateBackgroundColor
        %
        %  Description: Custom method to set backgroundcolor.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newBackgroundColor = updateBackgroundColor(this)
            newBackgroundColor = '';
            backgroundColor = this.Model.BackgroundColor;
            if (isequal(this.Model.RowStriping, 'off'))
                backgroundColor = backgroundColor(1,:);
            end
            this.view.setBackgroundColor(backgroundColor);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateFontWeight
        %
        %  Description: Custom method to set FontWeight.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newFontWeight = updateFontWeight(this)
            newFontWeight = '';
            this.view.setFontWeight(this.Model.FontWeight);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateFontAngle
        %
        %  Description: Custom method to set FontAngle.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newFontAngle = updateFontAngle(this)
            newFontAngle = '';
            this.view.setFontAngle(this.Model.FontAngle);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateFontSize
        %
        %  Description: Custom method to set FontSize.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newFontSize = updateFontSize(this)
            newFontSize = '';
            value = struct('FontSize', this.Model.FontSize, 'FontUnits', this.Model.FontUnits);            
            this.view.setFontSize(value);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateFontName
        %
        %  Description: Custom method to set FontName.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newFontName = updateFontName(this)
            newFontName = this.Model.FontName;
            this.view.setFontName(newFontName);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateForegroundColor
        %
        %  Description: Custom method to set foregroundcolor.                       
        %               
        %  Inputs :     this
        %  Outputs:     empty string-> as not need to set on the Web Table peernode 
        %               as handled by the variable editor peernode.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newForegroundColor = updateForegroundColor(this)
            newForegroundColor = '';
            this.view.setForegroundColor(this.Model.ForegroundColor);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updatePosition
        %
        %  Description: Method invoked when table position changes. 
        %
        %  Inputs :     None.
        %  Outputs:     
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newPosValue = updatePosition(this)
            oneOriginPosValue = this.Model.Position;
            newPosValue = this.positionBehavior.updatePositionInPixels(oneOriginPosValue);
        end        
        
    end

    % Implement abstract APIs defined in WebControllerViewInterface interface
    % so that view implementation will can access model property via these
    % APIs.
    methods
        function data = getModelData(this)
            data = this.Model.Data;
        end 
        
        function name = getModelColumnName(this)
            name = this.Model.ColumnName;
        end
        
        function width = getModelColumnWidth(this)
            width = this.Model.ColumnWidth;
        end
        
        function setModelCellData(this, newValue, row, col, varargin)   
            this.cellEditingHandler.handleCellEditFromClient(newValue, row, col, varargin{:});
        end
        
        function setModelCellSelectionEvent(this, eventData)
            this.Model.setCellSelectionFromClient(eventData);
        end
        
        function setModelColumnWidth(this, newColumnWidth)
            this.Model.ColumnWidth = newColumnWidth;
        end
    end
    
    methods( Access = 'protected')
        
        function createTableServer(this)
            %Create the VariableEditorTableView 
            this.view = matlab.ui.internal.controller.uitable.VariableEditorView(this);

            this.ServerReady = true;
        end    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      postAdd
        %
        %  Description: Custom method for controllers which gets invoked after the
        %               addition of the web component into the view hierarchy.
        %
        %  Inputs :     None.
        %  Outputs:     None.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function postAdd( this )

            % Attach a listener for events
            this.EventHandlingService.attachEventListener( @this.handleEvent );

        end        
               
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineViewProperties( this )
            
            % Add view properties specific to the table, then call super
            this.PropertyManagementService.defineViewProperty( 'Data' );
            this.PropertyManagementService.defineViewProperty( 'ColumnEditable' );
            this.PropertyManagementService.defineViewProperty( 'ColumnName' );
            this.PropertyManagementService.defineViewProperty( 'RowName' );
            this.PropertyManagementService.defineViewProperty( 'Visible' );
            this.PropertyManagementService.defineViewProperty( 'Enable' );
            this.PropertyManagementService.defineViewProperty( 'ColumnFormat' );
            this.PropertyManagementService.defineViewProperty( 'BackgroundColor' );
            this.PropertyManagementService.defineViewProperty( 'ForegroundColor' );
            this.PropertyManagementService.defineViewProperty( 'FontAngle' );
            this.PropertyManagementService.defineViewProperty( 'FontName' );
            this.PropertyManagementService.defineViewProperty( 'FontSize' );
            this.PropertyManagementService.defineViewProperty( 'FontWeight' );
            this.PropertyManagementService.defineViewProperty( 'ColumnWidth' );
            defineViewProperties@matlab.ui.internal.componentframework.WebComponentController(this);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineRenamedProperties( this )
            % Define renamed properties specific to the table, then call super
            defineRenamedProperties@matlab.ui.internal.componentframework.WebComponentController(this);                                             
        end
        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %
         %  Method:      defineRenamedProperties                     
         %  Description: Within the context of MVC ( Model-View-Controller )   
         %               software paradigm, this is the method the "Controller"
         %               layer uses to establish property dependencies between 
         %               a property (or set of properties) defined by the "Model"
         %               layer and dependent "View" layer property.
         %  Inputs:      None 
         %  Outputs:     None 
         %
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         function definePropertyDependencies( this )
             % Define dependency properties specific to the table, then call super
             this.PropertyManagementService.definePropertyDependency('Data_I','Data');
             this.PropertyManagementService.definePropertyDependency('Data_I','ColumnEditable');
             this.PropertyManagementService.definePropertyDependency('Data_I','RowName');
             this.PropertyManagementService.definePropertyDependency('Data_I','ColumnName');
             this.PropertyManagementService.definePropertyDependency('Data_I','BackgroundColor');
             this.PropertyManagementService.definePropertyDependency('ColumnEditable','ColumnEditable');
             this.PropertyManagementService.definePropertyDependency('ColumnName_I','ColumnName');
             this.PropertyManagementService.definePropertyDependency('Data_I','ColumnFormat');
            % Need to recalculate 'auto' column width with new column names. 
             this.PropertyManagementService.definePropertyDependency('ColumnName_I','ColumnWidth');             
             this.PropertyManagementService.definePropertyDependency('RowName_I','RowName');
             this.PropertyManagementService.definePropertyDependency('ColumnFormat','ColumnFormat');
             this.PropertyManagementService.definePropertyDependency('BackgroundColor_I','BackgroundColor');
             this.PropertyManagementService.definePropertyDependency('RowStriping','BackgroundColor');
             this.PropertyManagementService.definePropertyDependency('ForegroundColor','ForegroundColor');
             this.PropertyManagementService.definePropertyDependency('FontWeight_I','FontWeight');
             this.PropertyManagementService.definePropertyDependency('FontAngle_I','FontAngle');
             this.PropertyManagementService.definePropertyDependency('FontSize', 'FontSize');
             this.PropertyManagementService.definePropertyDependency('FontSize_I', 'FontSize');
             this.PropertyManagementService.definePropertyDependency('FontName_I','FontName');
             this.PropertyManagementService.definePropertyDependency('ColumnWidth_I','ColumnWidth');
             definePropertyDependencies@matlab.ui.internal.componentframework.WebComponentController(this);
            
         end
         
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      handleEvent
        %
        %  Description: Custom handler for events.
        %
        %  Inputs :     event -> Event payload.
        %  Outputs:     None.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function handleEvent( this, src, event )

          % Handle events
          if( this.EventHandlingService.isClientEvent( event ) )

              eventStructure = this.EventHandlingService.getEventStructure( event );
              
              % handle Position events
              handled = this.positionBehavior.handleClientPositionEvent( src, eventStructure, this.Model );
              if (~handled)
                  % handle other events
                  switch (eventStructure.Name)
                      case 'CreateClientTable'
                          % Client is asking server to create client view 
                          % it may happen during initialization or client
                          % refresh (g1497011)
                          this.fireServerReadyEvent();

                      otherwise
                          % Now, defer to the base class for common event processing
                          handleEvent@matlab.ui.internal.componentframework.WebComponentController( this, src, event );
                  end
              end
              

          end

        end       
    end   
end

