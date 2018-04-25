classdef PeerUITableArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
                                     matlab.ui.internal.controller.uitable.UITableArrayViewModel & ...
                                     matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin

%   Copyright 2014-2017 The MathWorks, Inc.
    

    
    properties(SetAccess='protected')
        % cell array of column-level formats
        formats    
        isNumericFormated = false;
    end
    
    methods
        % constructor
        function this = PeerUITableArrayViewModel(parentNode, variable)
            % Before calling base class, register uitable widgets in VE WidgetRegistry
            peerClass = 'matlab.ui.internal.controller.uitable.PeerUITableArrayViewModel';  
            viewClass = 'variableeditor/views/UITableArrayView';
            matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.registerUITableWidgets(peerClass, viewClass);
            
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
            this@matlab.ui.internal.controller.uitable.UITableArrayViewModel(variable.DataModel);  
                        
            this.init(variable, this);
            
            % Build the ArrayEditorHandler for the new Document
            % create DataGrid view for data types (array) directly derived from PeerArrayViewModel. 
            import com.mathworks.datatools.variableeditor.web.*;
            if ~isempty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end  
            
            % array specific set - renderer types on the table
            this.setTableModelProperties(...
                'renderer', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.CellRenderer,...
                'editor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.Editor,...
                'inplaceeditor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.text_widget.InPlaceEditor,...
                'class','double');             
        end
        
        function setColumnFormat(this, formats) 
            if isequal(this.formats, formats)
                return;
            end
            
            if isempty(formats)
                this.formats = {};
            else
                this.formats = formats;
            end
            
            % Cases of Numeric FORMAT change
            if this.hasValidNumericFormat(formats)
                % have new MATLAB numeric formats.
                % Re-send all table data with new formats.                
                this.DataModel.updateData(this.DataModel.Data);
                this.isNumericFormated = true;    
                
            elseif this.isNumericFormated
                % No new MATLAB numeric formats but data was formated to a new MATLAB format.
                % need to re-format back to defaul MATLAB format.
                this.DataModel.updateData(this.DataModel.Data);
                this.isNumericFormated = false;
            end            
            
            % update renderers for number, string, checkbox and popupmenu 
            this.updatePagedColumnFormat(true);      
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
                updateColumnModelInformation@internal.matlab.variableeditor.peer.PeerArrayViewModel(this, startColumn, endColumn);
            else
                % Override the base class and send all
                % ColumnModelProperties to the view.
                endColumn = size(this.ColumnModelProperties, 2);
                this.updateColumnModelInformation@internal.matlab.variableeditor.peer.PeerArrayViewModel(0,endColumn);
            end
                
        end
        
        function updatePagedColumnFormat(this, doUpdate)
            % get actual rendering size on the current page.
            data = this.DataModel.Data;
            [startRow, endRow, startColumn, endColumn] = this.getPagedSize(size(data));
           
            % disable JS refresh to allow a bulk update.
            oldStatus = this.disableCellModelUpdate();
            
            % Format styling.
            for column=startColumn:endColumn
                columnData = data(:, column);  
                if column > length(this.formats)
                    % empty ColumnFormat
                    this.setPagedFormatOnCellByColumn(column, startRow, endRow, columnData, '');
                else
                    this.setPagedFormatOnCellByColumn(column, startRow, endRow, columnData, this.formats{column});
                end
            end
            
            % enable JS refresh
            this.resumeCellModelUpdate(oldStatus);
            
            if nargin<2
                doUpdate = true;
            end 
            
            if doUpdate
                this.refreshCurrentCells();
            end
        end
        
        function varargout = handleClientSetData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
            data = this.getStructValue(varargin{1}, 'data');
            row = this.getStructValue(varargin{1}, 'row');
            column = this.getStructValue(varargin{1}, 'column');

            try
                if ~isempty(row)    % in which case is row empty?
                    % convert row number from string to number
                    if ischar(row)
                        row = str2double(row);
                    end
                    % convert column number from string to number
                    if ischar(column)
                        column = str2double(column);
                    end
                    % Convert string-type editing value if necessary.
                    % When editing the cell via checkbox, 
                    % convert editing value from string true/false to logical one. 
                    if this.isCheckbox(row, column)                        
                        if isequal(data, 'true')
                            data = true;
                        else
                            data = false;
                        end
                    end
                    
                    this.setData(data, row, column);
                end                
            catch e
                %noop
            end
            varargout{1} = '';
        end
        
        function setCurrentPage(this, startRow, endRow, startColumn, endColumn, doUpdate)
            this.setCurrentPage@internal.matlab.variableeditor.peer.PeerArrayViewModel(startRow, endRow, startColumn, endColumn, false);
            
            this.updatePagedBackgroundColor(false);    
            this.updatePagedColumnFormat(false);

            %update if needed
            if nargin<6
                doUpdate = true;
            end
            if doUpdate
                this.refreshCurrentPage();
            end
        end
        
        
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getRenderedDataWithNumericFormat(startRow,endRow,startColumn,endColumn, this.formats);

            renderedData = cell(size(data));
            
            % setCurrentPage will be called from java every time the view is refreshed. 
            % Comment out here to improve the performance.
            %this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);

            rowStrs = strtrim(cellstr(num2str([startRow-1:endRow-1]'))');
            colStrs = strtrim(cellstr(num2str([startColumn-1:endColumn-1]'))');

            for row=1:min(size(renderedData,1),size(data,1))
                for col=1:min(size(renderedData,2),size(data,2))
                   jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct('value',data{row,col},...
                                    'editValue',data{row,col},'row',rowStrs{row},'col',colStrs{col}));

                   renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);            
        end
        
        % set cell-level Styling by column.

        %   'numeric' means right alignment.
        %   'char' means left alignment.    
        function setPagedFormatOnCellByColumn(this, column, startRow, endRow, columnData, columnFormat)  
            
            oldStatus = this.disableCellModelUpdate();
            
            for row = startRow:endRow
                
                % Not popup menu case
                if iscell(columnData)
                    value = columnData{row, 1};
                else
                    value = columnData(row, 1);
                end
                
                if iscell(columnFormat) %drop-down list
                    this.applyPopupMenuOnCell(row, column, columnFormat);   
                elseif isempty(columnFormat) % default format with Data type  
                    if ischar(value) 
                        this.applyCharOnCell(row, column, value);
                    elseif islogical(value) %CheckBox
                        this.applyCheckBoxOnCell(row, column);
                    else 
                        this.applyNumericOnCell(row, column);
                    end 
                else
                    switch columnFormat                        
                        case 'numeric'  
                            this.applyNumericOnCell(row, column);
                        case 'char' 
                            this.applyCharOnCell(row, column, value);
                        case 'logical'
                            this.applyCheckBoxOnCell(row, column);
                        case this.getMATLABNumericFormats()
                            % for all MATLAB numeric formats
                            this.applyNumericOnCell(row, column);
                    end
                end
            end
            
            this.resumeCellModelUpdate(oldStatus);

        end
        
    end
    
    % private util methods
    methods (Access='protected')            
        % set Popup menu on cell
        function applyPopupMenuOnCell(this, row, column, items)
            this.setCellModelProperties(row, column, ...
                                        'inplaceeditor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.combobox_widget.InPlaceEditor, ...
                                        'renderer', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.combobox_widget.CellRenderer, ...
                                        'isProtected', true, ...
                                        'categories', items, ...
                                        'showUndefined', false);            
        end
        
        % set CheckBox on cell
        function applyCheckBoxOnCell(this, row, column)
            this.setCellModelProperties(row, column, ... 
				'class', 'logical',...
                'editor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.Editor,...
                'inplaceeditor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.InPlaceEditor, ...
                'renderer', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.CellRenderer);     
        end
        
        % set 'numeric' ColumnFormat on cell - right alignment
        function applyNumericOnCell(this, row, column)
            this.clearCellModelProperty(row, column); 
            
            % Set 'Class' to 'double' on client for a right alignment
            this.setCellModelProperty(row,column,'class', 'double', false);
        end
        
        % set 'char' ColumnFormat on cell - left alignment
        function applyCharOnCell(this, row, column, value)
            this.clearCellModelProperty(row, column); 
            
            % Set 'Class' to 'char' on client for a left alignment
            this.setCellModelProperty(row,column,'class', 'char', false);
            
            % use charLogical widget for a logical cell
            % to show true/false string rather than 1/0
            if islogical(value)
                this.setCellModelProperties(row, column, ...
                'editor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.charLogical_widget.Editor,...
                'inplaceeditor', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.charLogical_widget.InPlaceEditor, ...
                'renderer', matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.charLogical_widget.CellRenderer);
            end
        end  

        % empty cell-level model property for 'editor', 'renderer' and
        % 'inplaceeditor' to clear combobox or checkbox format.
        function clearCellModelProperty(this, row, column)
            this.setCellModelProperties(row, column, ...
                'editor', '', ...
                'renderer', '', ...
                'inplaceeditor', '');
        end
        
        % Indicate if a checkbox is shown in the view for the cell.
        function cb = isCheckbox(this, row, column)
            cb = isequal(this.getCellModelProperties(row, column, 'renderer'), ...
                    {matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.CellRenderer}) && ...
                 isequal(this.getCellModelProperties(row, column, 'inplaceeditor'), ...
                    {matlab.ui.internal.controller.uitable.PeerUITableViewModelMixin.checkbox_widget.InPlaceEditor}) ;  
        end
                
    end     
end
