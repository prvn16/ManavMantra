classdef VariableEditorView < matlab.ui.internal.controller.uitable.UITableView 
     
    %VARIABLEEDITORVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    %   Copyright 2017 The MathWorks, Inc.    
    
    properties (Access = 'protected')
        controllerInterface;
        manager;
        document;
        channel;
        viewStrategy;
        
        % table configuration
        TABLE_COLUMN_DEFAULT_WIDTH = 75;
    end
        
    
    
    
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = VariableEditorView(controllerViewInterface)
            
            this.controllerInterface = controllerViewInterface;
           
            % generate ChannelID
            this.channel = createChannelId(this);
            
            % Create factory 
            factory = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
            
            % Create manager - set IgonoreUpdates to be true.
            this.manager = factory.createManager(this.channel, true);
            
            % create the view for a given data type. 
            this.viewStrategy = this.createViewStrategy();
        end
      
        function strategy = createViewStrategy (this)
            % delete previous strategy first.
            this.viewStrategy = [];
            
            data = this.controllerInterface.getModelData();
            
            switch class(data)
                case 'table'
                    strategy = this.createTableStrategy(); 
                case {'cell', 'double', 'logical'}
                    strategy = this.createArrayStrategy();
            end
            
            % create the document if empty.
            if isempty(this.document) && ~isempty(strategy)
                this.document = this.manager.openvar('UITable', '', strategy.getAdapter(), '');
                
                % Save the new DataModel and ViewModel (from document) to strategy.
                strategy.setDataModelAndViewModel(this.document.DataModel, this.document.ViewModel);     
            end
        end 
        
        function strategy = createTableStrategy(this)
            strategy = matlab.ui.internal.controller.uitable.VariableEditorTableStrategy(this.controllerInterface, this.document);
        end
        
        function strategy = createArrayStrategy(this)
            strategy = matlab.ui.internal.controller.uitable.VariableEditorArrayStrategy(this.controllerInterface, this.document);
        end        
        
        
        function delete (this)
            % VariableEditor cleanup
            delete(this.manager);
        end    
         
    end
    
    % methods for controller to query document and channel
    methods
        function document = getDocument(this)
            document = this.document;
        end
        
        function channel = getChannel(this)
            channel = this.channel;
        end
    end
    
    methods 
        
        function setData (this, value)
            % check if a new strategy is needed.
            if ~ismember(class(value), this.viewStrategy.dataTypes)
                this.viewStrategy = this.createViewStrategy();
                
                % need to re-propagate all properties (except Data property) for the new view.
                this.controllerInterface.updateViewProperties({'Data'});
            end
            
            if ~isempty(this.viewStrategy)
                this.viewStrategy.setViewData(value);
            end
        end
        
        function setColumnName (this, columnName)
            if ~isempty(this.viewStrategy)
                this.viewStrategy.setViewColumnName(columnName);
            end
        end
        
        
         function setRowName (this, rowName)
            if ~isempty(this.viewStrategy)
                this.viewStrategy.setViewRowName(rowName);
            end
         end
        

        
        function setColumnEditable (this, edit)
            this.viewStrategy.setViewColumnEditable(edit);
        end
        
        function setColumnFormat(this, formats)
            this.viewStrategy.setViewColumnFormat(formats);
        end    
        
        % Width of table columns, specified as a 1-by-n cell array or 'auto'.
        % 'auto' means:
        %   - Default minimum size in pixel (75). 
        %   - If column header has a longer text, the width should automatically fit to show all content of this header. 
            
        % @ToDo currently 'auto' ColumnWidth only supports the 1st and 2nd feature.
        % 17a we will have a full design and implementation of AUTO column width.
        function setColumnWidth(this, columnWidth)
            if ~isempty(this.viewStrategy)
                this.viewStrategy.setViewColumnWidth(columnWidth);
            end
        end        
        
        function setBackgroundColor(this, value)
          % set backgroundcolor to the view model.
          this.viewStrategy.setViewBackgroundColor(value);
        end
        
        function setForegroundColor(this, value)
          this.viewStrategy.setViewForegroundColor(value);
        end
        
        function setFontWeight(this, value)
            % set fontWeight to the view model.
            this.viewStrategy.setViewFontWeight(value);
        end 
        
        function setFontAngle(this, value)
            % set fontAngle to the view model.
            this.viewStrategy.setViewFontAngle(value);
        end
        
        function setFontSize(this, value)
            this.viewStrategy.setViewFontSize(value);
        end
        
        function setFontName(this, value)
            this.viewStrategy.setViewFontName(value);
        end 
    end
    
    methods ( Access = 'private' )
        
        function id = createChannelId(this) 
            id = strcat('/UITable_', char(java.util.UUID.randomUUID()));
        end

    end    
    
end

