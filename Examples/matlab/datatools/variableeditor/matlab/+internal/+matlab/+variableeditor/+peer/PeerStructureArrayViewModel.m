classdef PeerStructureArrayViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & internal.matlab.variableeditor.StructureArrayViewModel
    %PEERSTRUCTUREARRAYVIEWMODEL Peer Model Structure Array View Model for vector structures
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties
        datetimeColumnWidth = 100;
        complexNumDefaultWidth = 120;
        defaultColumnWidth = 80;
        charWidth = 8;
        headerBuffer = 25;
    end
    
    methods
        function this = PeerStructureArrayViewModel(parentNode, variable)
            
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode, variable);
            this@internal.matlab.variableeditor.StructureArrayViewModel(variable.DataModel);
            
            this.StartRow = 1;
            this.EndRow = 80;
            this.StartColumn = 1;
            this.EndColumn = 30;
            
            this.setTableModelProperties(...
                'ShowColumnHeaderNumbers',false,...
                'ShowHeaderIcons',true,...
                'CornerSpacerTitle', 'Fields');
            
            if ~isempty(this.DataModel.Data)
                this.updateCellMetaInfo();
                this.setDefaultColumnWidth(this.DataModel.Data);            
            end
            
            this.setTableModelProperties('EditableColumnHeaders', true);
            this.setTableModelProperties('EditableColumnHeaderLabels', true);
            
            % Build the StructEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            if ~isempty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end
        end
        
        function setDefaultColumnWidth(this, data)
            this.ColumnModelChangeListener.Enabled = false;
            startCol = max(1, this.StartColumn);
            endCol = min(this.EndColumn, length(fields(data)));
            dataFields = fields(data);
                
            for col=startCol:endCol
                colVal = eval(sprintf('data(1).%s', dataFields{col}));
                width = this.defaultColumnWidth;
                % If coumns are manually resized in client, Do not set defaults. 
                isColumnManuallyResized = this.getColumnModelProperty(col, 'ColumnResized');
                
                if ~(islogical(isColumnManuallyResized{1}) && isColumnManuallyResized{1}==true)
                    % if the column consists of complex nos.
                    if isnumeric(colVal) && ~isreal(colVal)
                        width = this.complexNumDefaultWidth;
                    end

                    name = dataFields{col};
                    nameWidth = size(name, 2) * this.charWidth + this.headerBuffer;
                    columnWidth = this.getColumnModelProperty(col,'ColumnWidth');
                    % If the header name is very long, dynamically adjust the
                    % header width
                    if (nameWidth > width)
                        width = nameWidth;
                    end

                    % Also update when current width is > default width and the
                    % namewidth is lesser, this means the columns should shrink
                    % back to it's default width
                    if (width > this.defaultColumnWidth) || ...
                            (nameWidth < width && ~isempty(columnWidth{1}) && (columnWidth{1} > width))
                        this.setColumnModelProperty(col,'ColumnWidth', width, false);
                    end  
                end
            end
            this.ColumnModelChangeListener.Enabled = true;
         end
        
        function [renderedData, renderedDims] = getRenderedData(this, startRow, endRow, ...
                startColumn, endColumn)
            
            data = this.getRenderedData@internal.matlab.variableeditor.StructureArrayViewModel(...
                startRow, endRow, startColumn, endColumn);
            rawData = this.DataModel.Data;
            rawDataAsCell = this.convertStructToCell(rawData);
            isMetaData = this.MetaData;
            
            sRow = max(1,startRow);
            eRow = min(size(rawDataAsCell,1),endRow);
            sCol = max(startColumn,1);
            eCol = min(endColumn,size(rawDataAsCell,2));
            
            rowStrs = strtrim(cellstr(num2str((sRow-1:eRow-1)'))');
            colStrs = strtrim(cellstr(num2str((sCol-1:eCol-1)'))');
            
            colStrsIndex = 1;
            renderedData = cell(size(data));
            field = fields(rawData);
            for col = 1:size(renderedData,2)
                colStr = colStrs{col};
                rowStrsIndex = 1;
                for row = 1:size(renderedData,1)
                    rowStr = rowStrs{row};
                    editorValue = '';
                    if isMetaData(row,col) || ...
                            ischar(rawDataAsCell{row+sRow-1,col+sCol-1}) && size(rawDataAsCell{row+sRow-1,col+sCol-1},1) > 1
                        editorValue = sprintf('%s(%d).%s', this.DataModel.Name,row+sRow-1,char(field(col+sCol-1)));
                    end
                    
                    % only numerics need to have an editvalue which is in
                    % long format
                    % other data types have their edit value same as data
                    % value
                    if isnumeric(rawDataAsCell{row+sRow-1,col+sCol-1}) && ~isMetaData(row,col) && isscalar(rawDataAsCell{row+sRow-1,col+sCol-1})
                        format('long');
                        cellVal = strtrim(evalc('disp(rawDataAsCell(row+sRow-1,col+sCol-1))'));
                        longData = strtrim(regexprep(cellVal, '(^[)|(^{)|(}$)|(]$)',''));
                        format;
                    else
                    % This does not take the toJSON path. Adding this logic in formatDataUtils affects other
                    % scalar structs as well.  % Escape \ and " , Handle \n
                    % and \t for strings alone
                        data{row,col} = internal.matlab.variableeditor.peer.PeerUtils.formatGetJSONforCell( rawDataAsCell{row+sRow-1,col+sCol-1}, data{row,col});                                                    
                        longData = data{row,col};
                    end
                    
                    renderedData{row,col} = this.getJSONforCell(data{row,col}, longData,...
                        this.MetaData(row,col), editorValue, rowStr, colStr);
                    rowStrsIndex = rowStrsIndex + 1;
                end
                colStrsIndex = colStrsIndex + 1;
            end
            renderedDims = size(renderedData);
        end
        
        function status = handlePropertySet(this, ~, ed)
            this.logDebug('PeerArrayView','handlePropertySet','');
            
            this.handlePropertySet@internal.matlab.variableeditor.peer.PeerArrayViewModel([], ed);

            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success,
            % an error message otherwise.
            status = '';
            if isfield(ed.EventData,'source') && strcmp('server',ed.EventData.source)
                return;
            end

            if strcmpi(ed.EventData.key, 'ColumnModelProperty')
                column = this.getStructValue(ed.EventData.newValue,'column');
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');
                
                currentData = this.DataModel.Data;
                dataFields = fields(currentData);
                numCols = length(dataFields);
                oldValue = dataFields(column+1);
                name = this.DataModel.Name;
                if strcmp(property,'HeaderName') && (~isequal(oldValue{1}, value))
                    
                    % if the header value is unchanged then do nothing
                    if isequal(dataFields{column+1}, value)        
                        return;
                    end
                    
                    try
                         % if the column header name is not a duplicate
                        if ~any(ismember(dataFields, value))                             
                            % Execute structure array update command
                            cmd = sprintf('[%s.%s] = %s.%s; %s = orderfields(%s, [1:%d, %d, %d:%d]); %s = rmfield(%s, ''%s'');',...
                                name,...
                                value,...
                                name, ...
                                oldValue{1},...
                                name, ...
                                name, ...
                                column, ...
                                numCols + 1, ...
                                column + 1, ...
                                numCols, ...
                                name, ...
                                name, ...
                                oldValue{1});
                            if ischar(this.DataModel.Workspace)
                                % Requires a row/column, even though row
                                % will be unused.
                                this.executeSetFieldsCommand(cmd, 1, column);
                            else
                                this.DataModel.Workspace.evalin(cmd);
                            end
                            return
                        else
                            % throw an error if the column header name is
                            % a duplicate
                            error(message('MATLAB:codetools:variableeditor:DuplicateColumnHeaderStructs', value));
                        end
                    catch e
                         % if the column header name is a duplicate then the
                        % error thrown is caught here and published to the
                        % client
                        this.sendPeerEvent('ErrorDuplicateColumnHeader', 'status', 'error', 'message', e.message, 'index',  this.getStructValue(ed.EventData.newValue,'column'));           
                    end                    
                end
            end
        end
        
        function updateCellMetaInfo(this)
            this.CellModelChangeListener.Enabled = false;
            this.ColumnModelChangeListener.Enabled = false;
            this.TableModelChangeListener.Enabled = false;
            
            currentData = this.DataModel.getData;
            currentDataAsCell = this.convertStructToCell(currentData);
            structureArrayFieldNames = fields(currentData);
            widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
            
            startRow = max(1,this.StartRow);
            endRow = min(size(currentDataAsCell,1),this.EndRow);
            startCol = max(this.StartColumn,1);
            endCol = min(this.EndColumn,size(currentDataAsCell,2));
            
            for col=endCol:-1:startCol
                % check if all the entries in the column are of the same
                % date type
                % returns true if all entries are of the same type
                % returns false if entries are if different types
                [~, colClassName] = this.uniformTypeData(currentDataAsCell(:,col));
                icon = colClassName;
                this.setColumnModelProperties(col, 'icon', icon, 'HeaderName', structureArrayFieldNames{col});
                for row = endRow:-1:startRow
                    % Set Renderers and Editors
                    val = currentDataAsCell{row,col};
                    className = class(val);
                    [widgetsLocal,~,matchedVariableClass] = widgetRegistry.getWidgets(class(this),className);
                    
                    % if className is different from matchedVariableClass then
                    % it means that the current data type is unsupported or it
                    % is a custom object. In this case, the metadata of the
                    % unsupported object should be displayed in the table column.
                    if ~strcmp(className,matchedVariableClass)
                        if isobject(val)
                            widgetsLocal = widgetRegistry.getWidgets(class(this),'object');
                        else
                            widgetsLocal = widgetRegistry.getWidgets(class(this),'default');
                        end
                        className = matchedVariableClass;
                    end
                    
                    if strcmp(icon,'mixed')
                        % each cell in the column has different data type
                        % so set model properties on the cell
                        this.setCellModelProperties(row, col,...
                            'renderer', widgetsLocal.CellRenderer,...
                            'editor', widgetsLocal.Editor,...
                            'inplaceeditor', widgetsLocal.InPlaceEditor,...
                            'class', icon);
                    else
                        % entire column has entries of the same data type
                        % so remove any previous cell properties
                        % set the model properties on the column
                        this.setCellModelProperties(startRow:endRow,col,...
                            'renderer', '',...
                            'editor', '',...
                            'inplaceeditor', '',...
                            'class', '');
                        this.setColumnModelProperties(col,...
                            'renderer', widgetsLocal.CellRenderer,...
                            'editor', widgetsLocal.Editor,...
                            'inplaceeditor', widgetsLocal.InPlaceEditor,...
                            'class', colClassName);
                        
                        break;
                    end
                    
                end
            end
            this.setDefaultColumnWidth(currentData);
            this.CellModelChangeListener.Enabled = true;
            this.ColumnModelChangeListener.Enabled = true;
            this.TableModelChangeListener.Enabled = true;
            
            this.updateCellModelInformation(startRow, endRow, startCol, endCol);
            this.updateTableModelInformation();
            this.updateColumnModelInformation(startCol, endCol);
        end
        
        function updateCurrentPageModels(this)
            this.updateCellMetaInfo();
            this.updateCurrentPageModels@internal.matlab.variableeditor.peer.PeerArrayViewModel();
        end
        
    end
    
    methods(Access = 'protected')
        function varargout = refresh(this, es ,ed)
            varargout = this.refresh@internal.matlab.variableeditor.peer.PeerArrayViewModel(es,ed);
            this.updateCurrentPageModels();
        end      
        
        function classType = getClassType(~, ~, ~)
            % Return container class type (struct), not the individual
            % field from the specified struct.  Decisions made on the class
            % type returned here only depend on the container type.
            classType = 'struct';
        end
        
        function executeSetFieldsCommand(this, cmd, row, column)
            % Get the message to use for handling errors from the property
            % set command
            msgOnError = this.getMsgOnError(row, column, 'ColumnHeaderError');
            
            % Append the index (column) to the error message
            msgOnError = strrep(msgOnError, ' );', ...
                [', ''index'', ' num2str(column) ');']);
            
            % Execute the command to set the header name
            c = internal.matlab.datatoolsservices.CodePublishingService.getInstance;
            channel = ['VariableEditor/' this.DataModel.Name];
            c.publishCode(channel, cmd, msgOnError);
        end
    end
end


