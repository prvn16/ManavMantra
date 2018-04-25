classdef PeerStructureViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & internal.matlab.variableeditor.StructureViewModel
    %PEERTableVIEWMODEL Peer Model Table View Model for scalar structures
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Access='protected')
        SortAscendingListener;
        ValueColumnName;
        SizeColumnName;
        ClassColumnName;
        defaultColumnWidth = 180;
    end
    
    methods
        function this = PeerStructureViewModel(parentNode, variable, fieldColumnNameTag, valueColumnName)
            if nargin<3 || isempty(fieldColumnNameTag)
                fieldColumnNameTag = 'Field';  
            end
            fieldColumnName = getString(message(...
                sprintf('MATLAB:codetools:variableeditor:%s', fieldColumnNameTag)));
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode, variable, 'SortableColumn', fieldColumnName);
            this@internal.matlab.variableeditor.StructureViewModel(variable.DataModel);

            if nargin<4 || isempty(valueColumnName)
                valueColumnName = 'Value';
            end
            valueColumnName = getString(message(...
                sprintf('MATLAB:codetools:variableeditor:%s', valueColumnName)));
            this.ValueColumnName = valueColumnName;
            this.SizeColumnName = getString(message(...
                'MATLAB:codetools:variableeditor:Size'));
            this.ClassColumnName = getString(message(...
                'MATLAB:codetools:variableeditor:Class'));

            this.StartRow = 1;
            this.EndRow = 80;
            this.StartColumn = 1;
            this.EndColumn = 30;            
            
            % TODO: turn off listener before setting model properties for
            % performance
            % this.ColumnModelChangeListener.Enabled = false;
            % this.TableModelChangeListener.Enabled = false;
            
            % Set Default Structure Column Names (This is set up front for
            % the client side because we the client side detection of the
            % sortable column needs to know the column names in order to
            % add the sort icon
            this.setColumnModelProperty(1,'HeaderName',fieldColumnName);
            this.setColumnModelProperty(2,'HeaderName',this.ValueColumnName);
            this.setColumnModelProperty(3,'HeaderName',this.SizeColumnName );
            this.setColumnModelProperty(4,'HeaderName',this.ClassColumnName);

            this.setupPagedDataHandler(variable);
            
            % We need to set this up again after calling the
            % ArrayEditorHandler constructor because the column names will
            % be reset to 1,2 by default
            this.setColumnModelProperties(1,'HeaderName',fieldColumnName);
            this.setColumnModelProperty(2,'HeaderName',this.ValueColumnName);
            this.setColumnModelProperty(3,'HeaderName',this.SizeColumnName );
            this.setColumnModelProperty(4,'HeaderName',this.ClassColumnName);
            
            % Setting columnWidth of first column of Structures alone to a higher value.
            this.setColumnModelProperty(1, 'ColumnWidth', this.defaultColumnWidth);
            
            % Set the column name list and associated properties
            % for the context menu
            this.setTableModelProperty('ColumnHeaderList', {...
                fieldColumnName,...
                this.ValueColumnName,...
                this.SizeColumnName,...
                this.ClassColumnName...
                });
            % For the first field alone, set it to the column name of the untranslated field.
            this.setTableModelProperty('ColumnHeaderListPropertyName', {...
                fieldColumnNameTag,...
                'ShowValueColumn',...
                'ShowSizeColumn',...
                'ShowClassColumn'...
                });
            
            % We add these classes to column header nodes so that 
            % QA team can write integration tests that are not dependent
            % on dom structure
            this.addClassesToColumn(1, 'structNameColumn');
            this.addClassesToColumn(2, 'structValueColumn');
            this.addClassesToColumn(3, 'structSizeColumn');
            this.addClassesToColumn(4, 'structClassColumn');

            textWidgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('', 'char');

            % Set class for columns
            this.setTableModelProperty('class','char');

            % Set renderer for columns
            this.setTableModelProperty('renderer',textWidgets.CellRenderer);

            this.setTableModelProperties(...
                'ShowColumnHeaders', true,...
                'ShowColumnHeaderNumbers', false,...
                'ShowColumnHeaderLabels', true,...
                'ShowRowHeaders', false,...
                'ShowValueColumn', true,...
                'ShowSizeColumn', true,...
                'ShowClassColumn', true);
            
            % TODO: turn off listener before setting model properties for
            % performance
            % this.ColumnModelChangeListener.Enabled = true;
            % this.TableModelChangeListener.Enabled = true;
            
            if ~isempty(this.PagedDataHandler)
                this.PagedDataHandler.getGridNode.setProperty('showRowHeaders', false);
            end
        
            % Peer node SortAscending property should be consistently set
            % to an object/map with SortAscending and source keys
            this.setProperty('SortAscending',struct('SortAscending',true,'source','server'));
            
            % Add Listener to Set Peer Node Property
            this.SortAscendingListener = event.proplistener(this, this.findprop('SortAscending'), 'PostSet', @(es, ed) this.handleSortAscending());
        end
        
        % This is to force refresh and update the column headers when
        % some of them are turned on/off via context menu
        function handleTableModelUpdate(this, ~, ed)
            this.logDebug('PeerStructurViewModel','handleTableModelUpdate','');
            this.handleTableModelUpdate@internal.matlab.variableeditor.peer.PeerArrayViewModel([],[]);
            if strcmp(ed.Key,'ShowValueColumn') ||...
                    strcmp(ed.Key,'ShowSizeColumn') ||...
                    strcmp(ed.Key,'ShowClassColumn')

                this.removeClassesFromColumn(2:4,... % reset classes before adding them
                    {'structValueColumn',...
                    'structSizeColumn',...
                    'structClassColumn'});
                [~, showValueColumn, showSizeColumn, showClassColumn] = this.getOutputColumns();
                currentColumn = 1;
                                
                if showValueColumn
                    currentColumn = currentColumn+1;
                    this.EndColumn = currentColumn;
                    this.setColumnModelProperty(currentColumn,'HeaderName',this.ValueColumnName);
                    this.addClassesToColumn(currentColumn, 'structValueColumn');
                end
                if showSizeColumn
                    currentColumn = currentColumn+1;
                    this.EndColumn = currentColumn;
                    this.setColumnModelProperty(currentColumn,'HeaderName',this.SizeColumnName);
                    this.addClassesToColumn(currentColumn, 'structSizeColumn');
                end
                if showClassColumn
                    currentColumn = currentColumn+1;
                    this.EndColumn = currentColumn;
                    this.setColumnModelProperty(currentColumn,'HeaderName',this.ClassColumnName);
                    this.addClassesToColumn(currentColumn, 'structClassColumn');
                end
                
                this.EndColumn = currentColumn;
            end
            this.forceRefresh();
        end
        
       function forceRefresh(this)
            this.updateColumnModelInformation(this.StartColumn, this.EndColumn);
            
            % Force client to redraw
            eventdata = internal.matlab.variableeditor.DataChangeEventData;
            [I,J] = meshgrid(this.StartRow:this.EndRow,1:4);
            I = I(:)';
            J = J(:)';
            eventdata.Range = [I;J];
            eventdata.Values = [];
            this.notify('DataChange',eventdata);
            
       end
        
		% overriding this method in order to update the page models on the updated column count by calling the getOutputColumns method. 
		% When the GridEditorHandler calls this method, due to timing issues, the column count reflects the old value
       function setCurrentPage(this, startRow, endRow, startColumn, endColumn, doUpdate)
            this.logDebug('PeerArrayView','setCurrentPage','','startRow',startRow,'endRow',endRow,'startColumn',startColumn,'endColumn',endColumn);

            if nargin<6
                doUpdate = true;
            end

            % Converts client
            s = this.getSize();
            this.StartRow = max(1, startRow);
            this.EndRow = min(s(1), endRow);
            this.StartColumn = max(1, startColumn);
            this.EndColumn = this.getOutputColumns();

            if doUpdate
                this.updateCurrentPageModels();
            end
        end
    end
    
    methods(Access='protected')
        function setupPagedDataHandler(this, variable)
            % Build the StructEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            if ~internal.matlab.variableeditor.FormatDataUtils.isVarEmpty(variable.DataModel.Data)
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,80,1,30));
            else
                this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
            end
        end
        
        function handleSortAscending(this)
            if isempty(this.getFields(this.DataModel.Data))
                % Short circuit for empty struts
                return;
            end
            sortObj.SortAscending = this.SortAscending;
            sortObj.source = 'server';
            
            this.setProperty('SortAscending',sortObj);
            
            this.updateSelectedFields();
            this.updateSelectedRowIntervals();
            this.setSelection(this.SelectedRowIntervals, this.SelectedColumnIntervals);
        end
    
        function [numOutputColumns, showValueColumn, showSizeColumn, showClassColumn] = getOutputColumns(this)
            showValueColumn = this.getTableModelProperty('ShowValueColumn');
            if isempty(showValueColumn);showValueColumn = true; end;
            showSizeColumn = this.getTableModelProperty('ShowSizeColumn');
            if isempty(showSizeColumn);showSizeColumn = true; end;
            showClassColumn = this.getTableModelProperty('ShowClassColumn');
            if isempty(showClassColumn);showClassColumn = true; end;
            numOutputColumns = 1 + showValueColumn + showSizeColumn + showClassColumn;
        end
        
        function [renderedData, renderedDims] = renderData(this, data, ...
                startRow, endRow, startColumn, endColumn)
            
            widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
            textWidgets = widgetRegistry.getWidgets('','char');
            logicalWidgets = widgetRegistry.getWidgets('','logical');
            viewClass = class(this);
            
            this.StartRow = startRow;
            this.EndRow = endRow;
            this.StartColumn = startColumn;
            this.EndColumn = endColumn;
            rawData = this.getData();
            [numOutputColumns, showValueColumn, showSizeColumn, showClassColumn] = this.getOutputColumns();
            renderedData = cell(size(data,1), numOutputColumns);

            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');

            % For each of the rows of rendered data, create the json object
            % string for each column's data.
            for row=1:size(renderedData, 1)
                varName = data{row,1};
                varValue = data{row,2};
                dataValue = this.getFieldData(rawData, varName);
                sizeValue = data{row,3};
                classValue = data{row,4};

                editValue = varValue;
                
                % If we have a numeric value, that isn't a value summary create the full-precision representation of it.
                if ~this.MetaData(row) &&...
                    isnumeric(dataValue)
                
                    editValue = this.getEditValue(dataValue);
                end
                actualRow = row;
                if ~this.SortAscending
                    s = this.getSize();
                    actualRow = s(1)-row+1;
                end
                widgets = widgetRegistry.getWidgets(viewClass,data{row,4});
                if isempty(widgets.CellRenderer) && isobject(this.getData(actualRow,actualRow,4,4))
                    widgets = widgetRegistry.getWidgets(viewClass,'object');
                elseif isempty(widgets.CellRenderer)
                    widgets = widgetRegistry.getWidgets(viewClass,'char');
                end
				
                % workspacefunc return a Java logical in the case of scalar
                % logicals so we need to correct for that here G1154075
                if strcmp(data{row,4}, 'logical') && isscalar(dataValue)
                    valueWidgets = logicalWidgets;
                    
                    if strcmp(varValue, 'true') ||...
                        strcmp(varValue, '1') ||...
                        strcmp(varValue, 'on')
                        varValue = 1;
                    else
                        varValue = 0;
                    end
                    
                    editValue = varValue;
                else
                    valueWidgets = textWidgets;
                end
                
                % Pass down label string for tooltip in Workspace Browser
                 tooltip = sprintf('%s %s', data{row,3}, data{row,4});
                 this.setRowModelProperty(row, 'tooltip', tooltip);
                 
                % Get the editors to use for the field
                [cellEditor, cellInPlaceEditor] = this.getEditors(data, ...
                    row, widgets.Editor, valueWidgets.InPlaceEditor);
                rowString = rowStrs{row};
                
                clsVal = classValue;
                if strcmp(classValue, 'tall')
                    % Special handling for tall variables.  The editValue
                    % will be something like 'tall duration' or 'tall
                    % duration (unevaluated)'.  Set the clsVal (which is
                    % used for the icon), so 'tall_duration'.
                    tallComponents = strsplit(editValue);
                    if strfind(tallComponents{end}, '(') == 1
                        underlyingCls = tallComponents{end-1};
                    else
                        underlyingCls = tallComponents{end};
                    end
                    if ~isempty(underlyingCls) && ~strcmp(underlyingCls, 'tall')
                        clsVal = ['tall_' underlyingCls];
                    end
                end
                % Name column, no in place editor for the name column
                renderedData{row,1} = ...
                    internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct(...
                    'value', char(varName),...
                    'editValue', char(varName),...
                    'renderer', widgets.CellRenderer,...
                    'class', clsVal,... 
                    'editor', cellEditor,...
                    'inplaceeditor', '',...
                    'editorValue', this.getSubVarName(this.DataModel.Name,varName), ...
                    'row', rowString, ...
                    'col', '0', ...
                    'Editable', '0' ...
                ));
                
                currentColumn = 1;

                if showValueColumn
                    currentColumn = currentColumn + 1;
                    
                    % Char arrays have already been escaped.  Don't escape
                    % them twice. (But other datatypes need to be properly converted to
                    % JSON and escaped).
                    escapeVal = ~ischar(varValue);
                    if isnumeric(varValue) 
                        varValue = num2str(varValue);
                        editValue = num2str(editValue);
                    end
                    
                    % Pass in valid classInfo for strings alone to aid inline editing of tabs and newlines in strings,
                    % For other datatypes, pass in '' to set Css to the default 'char' type in clientside. 
                    if ~strcmp(clsVal,'string')
                       clsVal ='';
                    end                    
                    valueForJSON = struct('value', varValue,...
                        'editValue', editValue,...
                        'renderer', valueWidgets.CellRenderer,...
                        'editor', cellEditor,...
                        'inplaceeditor', cellInPlaceEditor,...
                        'editorValue', this.getSubVarName(this.DataModel.Name,varName),...
                        'isMetaData', int2str(~this.isEditable(row,2)),...
                        'row', rowString, ...
                        'col', num2str(currentColumn-1), ...
                        'Editable', int2str(~isempty(cellInPlaceEditor)), ...
                        'class', clsVal);
                        
                    
                    % Value Column
                    renderedData{row,currentColumn} = ...
                        internal.matlab.variableeditor.peer.PeerUtils.toJSON(escapeVal, valueForJSON);
                end

                if showSizeColumn
                    currentColumn = currentColumn + 1;
                    % Size Column
                    renderedData{row,currentColumn} = ...
                        internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct(...
                        'value', sizeValue,...
                        'row', rowString, ...
                        'col', num2str(currentColumn-1), ...
                        'Editable', '0' ...
                        ));
                end

                if showClassColumn
                    currentColumn = currentColumn + 1;
                    % Class Column
                    renderedData{row,currentColumn} = ...
                        internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, struct(...
                        'value', classValue,...
                        'row', rowString, ...
                        'col', num2str(currentColumn-1), ...
                        'Editable', '0' ...
                        ));
                end

            end
            
            renderedDims = size(renderedData);
        end
        
        function [cellEditor, cellInPlaceEditor] = getEditors(~, ~, ~, ...
                editor, inPlaceEditor)
            % Returns the editors to use for the cell.  This gives
            % inherited classes a way to make a field value read-only.
            cellEditor = editor;
            cellInPlaceEditor = inPlaceEditor;
        end
        
        function editValue = getEditValue(~, dataValue)
            editValue = ...
                internal.matlab.variableeditor.peer.PeerStructureViewModel.getDisplayEditValue(...
                dataValue);
        end
    end
    
    methods(Static = true)
        function editValue = getDisplayEditValue(dataValue)
            if ischar(dataValue) && size(dataValue, 1) == 1
                editValue = ['''' dataValue ''''];
                return;
            end

            % Capture the current display format
            oldFormat = get(0,'format');
            format('long');
            if ~isscalar(dataValue)
                if iscell(dataValue)
                    editValue = '{';
                else
                    editValue = '[';
                end
            else
                editValue = '';
            end
            
            % Loop through all the cells and get the disp values
            for drow=1:size(dataValue, 1)
                if drow > 1
                    editValue = [editValue ';']; %#ok<AGROW>
                end
                for dcol=1:size(dataValue, 2)
                    if dcol > 1
                        editValue = [editValue ',']; %#ok<AGROW>
                    end
                    
                    if iscell(dataValue) && isempty(dataValue{drow, dcol})
                        editValue = [editValue '''''']; %#ok<AGROW>
                    elseif isa(dataValue, 'function_handle')
                        editValue = char(dataValue);
                        if ~isempty(editValue) && ~startsWith(editValue, "@")
                            editValue = ['@' editValue];
                        end
                    else
                        editValue = [editValue strtrim(evalc('disp(dataValue(drow,dcol))'))]; %#ok<AGROW>
                    end
                end
            end
            if ~isscalar(dataValue)
                if iscell(dataValue)
                    editValue = [editValue '}']; 
                else
                    editValue = [editValue ']']; 
                end
            end
            
            % Restore the previous display format
            format(oldFormat);
        end
    end
    
    methods(Access = public)
        function [renderedData, renderedDims] = getRenderedData(this, ...
                startRow, endRow, startColumn, endColumn)
            % Get the rendered data from the StructureViewModel, and
            % reformat it for display in JS.
            data = this.getRenderedData@internal.matlab.variableeditor.StructureViewModel(...
                startRow, endRow, startColumn, endColumn);
            

            [renderedData, renderedDims] = this.renderData(data, startRow, ...
                endRow, startColumn, endColumn);
        end
                
        function subVarName = getSubVarName(~, Name, varName)
            subVarName = sprintf('%s.%s', Name, varName);
        end
        
        function editable = isEditable(this, row, col)
            % Return whether the cell specified by row, col is editable.
            editable = this.isEditable@internal.matlab.variableeditor.StructureViewModel(...
                row,col);
        end

        % getSize
        function s = getSize(this)
            s = this.DataModel.getSize();
            numOutputColumns = this.getOutputColumns();
            s = [s(1) numOutputColumns];
        end
        
        function status = handlePropertySet(this, ~, ed)
            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success,
            % an error message otherwise.
            status = '';
            if strcmpi('server',this.getStructValue(ed.EventData,'source')) || ...
                    (~isempty(this.getStructValue(ed.EventData,'newValue')) && ...
                    strcmpi('server', this.getStructValue(this.getStructValue(ed.EventData,'newValue'),'source')))
                return;
            end
            
            if strcmpi(ed.EventData.key, 'SortAscending')
                this.handleClientSortAscending(ed.EventData);
            elseif strcmpi(ed.EventData.key, 'TableModelProperty')
                this.handlePropertySet@internal.matlab.variableeditor.peer.PeerArrayViewModel([], ed);
                property = this.getStructValue(ed.EventData.newValue,'property');
                % force refresh the view when client side updates them
                % so that the header column selection context menu works
                if strcmp(property, 'ShowValueColumn') ||...
                    strcmp(property, 'ShowSizeColumn') ||...
                    strcmp(property, 'ShowClassColumn')
                    this.handleTableModelUpdate([], struct('Key', property));
                end
            else
                this.handlePropertySet@internal.matlab.variableeditor.peer.PeerArrayViewModel([], ed);
            end
        end

        function varargout = setSelection(this, varargin)
            this.setSelectedFields(varargin{1});
            varargout{1} = this.setSelection@internal.matlab.variableeditor.peer.PeerArrayViewModel(varargin{:});  

            %Set the list of selected variables/fieldnames here
            selection = strjoin(strsplit(this.getFormattedSelection(), {[this.DataModel.Name '.'], ';'}), ',');
            %Remove leading ','
            selection = selection(:, 2:end);
            
            % updates the selected fields property which is used in drag
            % and drop
            if (nargin > 3 && strcmp(varargin{3},'client'))
                this.setTableModelProperty('SelectedFields', selection);
            end 
        end
    end
    
    methods(Access='protected')
        function [renderedData, renderedDims] = refresh(this, ~, eventData)
            % Override PeerArrayViewModel's refresh function because it is
            % calling disp on the changed value, which is not what we want
            % for structures.  Structures need to use the value from the
            % rendered data instead.  (This way we get 1x100 double instead
            % of 1,2,3,4...            
            numOutputColumns = this.getOutputColumns();
            
            if size(eventData.Range, 2) == 1
                % Refresh data for single cell
                if this.SortAscending
                    startRow = eventData.Range(1,1)-1;
                    endRow = eventData.Range(1,1)-1;
                else
                    numFields = this.getSize();
                    numFields = numFields(1);
                    startRow = numFields-eventData.Range(1,1);
                    endRow = numFields-eventData.Range(1,1);
                end
                
                dataBounds = struct('startRow', startRow, ...
                    'endRow', endRow, ...
                    'startColumn', eventData.Range(2,1)-1, ...
                    'endColumn', eventData.Range(2,1)-1);
            else
                % Refresh data for the current block
                dataBounds = struct('startRow', max(0,this.StartRow-1-this.WindowBlockRows), ...
                    'endRow', this.EndRow-1+this.WindowBlockRows, ...
                    'startColumn', 0, ...
                    'endColumn', numOutputColumns-1);
            end

           [renderedData, renderedDims] = this.refreshRenderedData(dataBounds);
            
            % Need to call DataChange with the rendered data (like the
            % ViewModel class does for the values from disp).  Updates need
            % to be made for the value, as well as the size and class which
            % may also have changed.
            
            if size(eventData.Range, 2) == 1 ...
                    && ~isequal(this.getSize(), [0, numOutputColumns])
                dataChangeEvent = internal.matlab.variableeditor.DataChangeEventData;
                if this.SortAscending
                    startRow = eventData.Range(1,1);
                else
                    numFields = this.getSize();
                    numFields = numFields(1);
                    startRow = numFields-eventData.Range(1,1)+1;
                end
                for col=1:numOutputColumns
                    dataChangeEvent.Range = [startRow; col];
                    dataChangeEvent.Values = renderedData{1, col};
                    this.notify('DataChange', dataChangeEvent);
                end
            else
                dataChangeEvent = internal.matlab.variableeditor.DataChangeEventData;
                dataChangeEvent.Range = [dataBounds.startRow:dataBounds.endRow,dataBounds.startRow:dataBounds.endRow;...
                    ones(dataBounds.endRow-dataBounds.startRow+1),2*ones(dataBounds.endRow-dataBounds.startRow+1)];
                % assuming the only case where it goes to else is when the
                % variable is cleared using 'clearvar'
                %dataChangeEvent.Range = '';
                dataChangeEvent.Values = '';
                this.notify('DataChange', dataChangeEvent);
            end
            
            this.updateSelectedFields();
            this.updateSelectedRowIntervals();
            this.setSelection(this.SelectedRowIntervals, this.SelectedColumnIntervals);
        end        
      
        function classType = getClassType(~, ~, ~)
            % Return container class type (struct), not the individual
            % field from the specified struct.  Decisions made on the class
            % type returned here only depend on the container type.
            classType = 'struct';
        end
        
        function handleClientSortAscending(this, eventData)
            if isempty(this.getFields(this.DataModel.Data))
                % Short circuit for empty struts
                return;
            end

            sortObj = this.getStructValue(eventData, 'newValue');    
            this.SortAscending = this.getStructValue(sortObj,'SortAscending');
        end
        
        function updateSelectedFields(this)
          % update the selected fields property 
            updatedData = this.getData();
            newFields = this.getFields(updatedData);
                     
            if ~this.SortAscending
                newFields = newFields(end:-1:1);
            end
            
            tempArray = {};
            countSelectedFields = 1;
            if ~isempty(this.SelectedFields)
                % iterate through the updated fields and correspondingly
                % change the selectedFields attribute
                for i=1:length(this.SelectedFields)
                    for j=1:size(newFields, 1)
                        if strcmp(this.SelectedFields{i},newFields{j})
                            tempArray{countSelectedFields} = this.SelectedFields{i}; %#ok<AGROW>
                            countSelectedFields = countSelectedFields + 1;
                            break;
                        end
                    end
                end
            end
            
            this.SelectedFields = tempArray;
        end
        
        %change the selectedRowIntervals property accordingly
        function updateSelectedRowIntervals(this)            
            updatedData = this.getData();
            newFields = this.getFields(updatedData);
                     
            if ~this.SortAscending
                newFields = newFields(end:-1:1);
            end
            
            this.SelectedRowIntervals = [];
            
            % counter to increment the selectedRowIntervals property
            countSelectedRowIntervals = 0;
            
            % keeps tracks of the prev Index to preserve ranges for block
            % selection
            prevIndex = -1;
            for l=1:length(this.SelectedFields)
                for currIndex=1:size(newFields,1)
                    if strcmp(this.SelectedFields{l},newFields{currIndex})
                        % case where consecutive rows are selected. They
                        % can be combined to a block
                        if prevIndex > 0 && currIndex-prevIndex == 1
                            this.SelectedRowIntervals(countSelectedRowIntervals,2) = currIndex;
                        % case where disjoint rows are selected
                        else
                            countSelectedRowIntervals = countSelectedRowIntervals + 1;
                            this.SelectedRowIntervals(countSelectedRowIntervals,1) = currIndex;
                            this.SelectedRowIntervals(countSelectedRowIntervals,2) = currIndex;                            
                        end                        
                    end
                end
            end
        end
    end
end
