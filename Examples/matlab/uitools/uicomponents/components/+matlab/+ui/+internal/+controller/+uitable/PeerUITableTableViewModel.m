classdef PeerUITableTableViewModel < internal.matlab.variableeditor.peer.PeerTableViewModel & ...
                                     matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin

%   Copyright 2017 The MathWorks, Inc.
    
    methods
        % constructor
        function this = PeerUITableTableViewModel(parentNode, variable)
            % Before calling base class, register uitable widgets in VE WidgetRegistry
            peerClass = 'matlab.ui.internal.controller.uitable.PeerUITableTableViewModel';  
            viewClass = 'variableeditor/views/UITableTableView';
            matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.registerUITableWidgets(peerClass, viewClass);
            
            this = this@internal.matlab.variableeditor.peer.PeerTableViewModel(parentNode,variable);
                        
            this.init(variable, this);
        end  
    end
    
    methods (Access='protected')
        function varargout = refresh(this, es ,ed)
            
            this.updateCurrentPageModels();
            
            [varargout{1:nargout}] = this.refresh@internal.matlab.variableeditor.peer.PeerTableViewModel(es,ed);
        end            
    end
    
    methods
        
        function setDefaultColumnWidth(this, data)
            % no need to set Variable Editor default column width.
        end
        
        
        % override the base in Data tools
        % so that UITable can show column names independent of Data property. 
        % g1393590
         % make this override only for case when column names are more than
        % column data since this override will not page ColumnModelPropery
        % For other cases, we decide to use the normal base class to page
        % ColumnModelProperties and improve some performance.
        % TODO: maybe need to refactor later along with UITable.js
        function updateColumnModelInformation(this, startColumn, endColumn)
            % get ColumnName property from view interface.
            names = this.DataModel.controllerInterface.getModelColumnName();
            data = this.DataModel.Data;
            if (isequal(names, 'numbered') || length(names)<=size(data, 2))
                % use the base class to page ColumnModelProperties
                updateColumnModelInformation@internal.matlab.variableeditor.peer.PeerTableViewModel(this, startColumn, endColumn);
            else
                % Override the base class and send all
                % ColumnModelProperties to the view.
                endColumn = size(this.ColumnModelProperties, 2);
                this.updateColumnModelInformation@internal.matlab.variableeditor.peer.PeerTableViewModel(0,endColumn);
            end
                
        end       
        
        function setCurrentPage(this, startRow, endRow, startColumn, endColumn, doUpdate)
            this.setCurrentPage@internal.matlab.variableeditor.peer.PeerTableViewModel(startRow, endRow, startColumn, endColumn, false);
            
            this.updatePagedBackgroundColor(false);    

            %update if needed
            if nargin<6
                doUpdate = true;
            end
            if doUpdate
                this.refreshCurrentPage();
            end
        end
        
        % Override method in Variable Editor's FormatDatautils so that the contents will not be rendered as a summary
        % value
        % Ex : c{1} = [1;2;3;4;5;6;7;8;9;1;2;3] will be displayed as 1x12
        % double instead of '[1;2;3;4;5;6;7;8;9;1;2;3]'
        function isSummary = isSummaryValue(this, data)
            isSummary = true;
        end         

    end
        
    methods (Access='protected')
        
        % give derived classes a chance to customize widgets
        function [widgets, groupedColumnWidgets] = getCustomizedWidgets(this, widgets, groupedColumnWidgets,  tData, col)
            
            registry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();

            % For table data, always use 'GroupedColumnRenderer' for cell renderer. See GroupedColumnRenderer.js 
            widgets.CellRenderer = 'variableeditor/views/renderers/GroupedColumnRenderer';            
            
            columnData = tData.(col);
            
            % Get uitable type of widget for the first cell every column.
            groupedColumnWidgets = this.getUITableWidget(registry, tData, 1, col);

            % If column is cell array of mixed data types,
            % do cell-level setting for cell arrays in table (except for char cell array).
            if iscell(columnData) && ~iscellstr(columnData)
                % remove column model properties
                groupedColumnWidgets.InPlaceEditor = '';
                groupedColumnWidgets.CellRenderer = '';
                
                % set cell model properties for paged cells.
                this.setPagedCellWidgets(registry, tData, col);
            else
                this.clearCellWidgets(tData, col);
            end
        end
    end
    
     methods(Access='protected')
            function isValid = validateInput(this,value,row,column)
                % No validation at this point.
                isValid = true;
            end

            function result = evaluateClientSetData(~, data, ~, ~)
                % For UITable, customize cell editing eval to keep the editing
                % value (no eval).
                result = data;
            end   
     end    
    

    % util 
    methods (Access='private')
        % for cell arrays (except char cell array),
        % we need to set widgets for every cell in the column 
        function setPagedCellWidgets(this, registry, tData, col)
            
            oldStatus = this.disableCellModelUpdate();
            
            % for cell data
            [sRow, eRow, ~, ~] = this.getPagedSize(size(tData));
            for row = sRow : eRow
                % get uitable widget
                [widget, className] = this.getUITableWidget(registry, tData, row, col);
                
                % set cell format
                this.setCellModelProperties(row, col, ...
                                            'class', className, ... %alignment
                                            'groupedcolumnrenderer', widget.CellRenderer, ... %display
                                            'InPlaceEditor', widget.InPlaceEditor... % editing
                                            );                             
            end
            
            
            this.resumeCellModelUpdate(oldStatus);
            
        end
        
        % Clear widgets of all cells in the column
        function clearCellWidgets(this, tData, col)
            if ~isempty(this.getCellModelProperty(1, col, 'groupedcolumnrenderer'))
           
                oldStatus = this.disableCellModelUpdate();
                for row = 1:size(tData, 1)
                    this.setCellModelProperties(row,col, ...
                            'class', '', ...
                            'groupedcolumnrenderer', '', ...
                            'InPlaceEditor', '');
                end
                this.resumeCellModelUpdate(oldStatus);  
            end
        end
    end
    

  
end
