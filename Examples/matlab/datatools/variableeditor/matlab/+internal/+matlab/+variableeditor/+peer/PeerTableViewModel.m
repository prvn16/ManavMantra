classdef PeerTableViewModel < internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.TableViewModel & ...
        internal.matlab.variableeditor.VEColumnConstants
    %PEERTableVIEWMODEL Peer Model Table View Model

    % Copyright 2013-2017 The MathWorks, Inc.

    properties
        metaDataChangedListener;
        % These properties used to indicate if the UI should use the table
        % meta data for VariableNames and RowNames to set those HeaderName
        % and RowNames in the UI.  If set to false the UI will not be
        % updated from the Table's meta data.
        UseTableRowNamesForView = true;
        UseTableColumnNamesForView = true;
    end

	properties
        perfSubscription;
        usercontext;
    end

    methods
        function this = PeerTableViewModel(parentNode, variable, usercontext)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode,variable);
			this@internal.matlab.variableeditor.TableViewModel(variable.DataModel);
            % Instantiates the Table Sort Handler
            this.sortHandler = internal.matlab.variableeditor.peer.PeerTableSortHandler(this, variable);            
            isRowHeaderEditable = true;

            if nargin <=2
                this.usercontext = '';
            else
                this.usercontext = usercontext;
            end

            if size(this.DataModel.Data, 2) > 0
                s = this.getSize();
                this.StartRow = 1;
                this.StartColumn = 1;
                this.EndColumn = min(30, s(2));
                this.EndRow = min(80,s(1));

                if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                  this.updateColumMetaInfo();
                  this.updateRowMetaInfo();
                  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerTableViewModel','', 'variableeditor/views/TableArrayView','','')
                  this.perfSubscription = message.subscribe('/VELogChannel', @(es) internal.matlab.variableeditor.FormatDataUtils.loadPerformance(es));
                else
                  % Fetch 10 rows and 30 columns initially.
                  this.EndColumn = min(30, s(2));
                  this.EndRow = min(10, s(1));
				  w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                  w.registerWidgets('internal.matlab.variableeditor.peer.PeerTableViewModel','', 'variableeditor_peer/PeerTableViewModel','','')
                end

                currentData = this.DataModel.Data;
                this.setDefaultColumnWidth(currentData);

                % Adding this as a temporary fix to disable row header
                % editing in MATLAB Online for timetables. (timetables have
                % RowTimes, while tables have RowNames).
                if isfield(currentData.Properties, 'RowTimes')
                    isRowHeaderEditable = false;
                end
            end

            this.setTableModelProperties('ShowColumnHeaderNumbers', true);

            this.setTableModelProperties('ShowColumnHeaderLabels', true);
            this.setTableModelProperties('EditableColumnHeaderLabels', true);

            this.setTableModelProperties('EditableRowHeaderLabels', isRowHeaderEditable);

            % Build the ArrayEditorHandler for the new Document if not in
            % the live editor context
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                import com.mathworks.datatools.variableeditor.web.*;
                if ~isempty(variable.DataModel.Data)
                    this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(this.StartRow,this.EndRow,this.StartColumn,this.EndColumn));
                else
                    this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this);
                end
            end

            this.metaDataChangedListener = event.listener(variable.DataModel,'MetaDataChanged',@(es,ed) this.handleMetaDataChanged(es,ed));
            this.updateCurrentPageModels();
        end

        function setDefaultColumnWidth(this, data)
            this.ColumnModelChangeListener.Enabled = false;
            startCol = max(1, this.StartColumn);
            endCol = min(this.EndColumn, size(data,2));

            startColumnIndexes = internal.matlab.variableeditor.TableViewModel.getColumnStartIndicies(data, startCol, endCol);
            for col=startCol:endCol
                % Column widths defined in the VEColumnConstants file
                width = internal.matlab.variableeditor.VEColumnConstants.defaultColumnWidth;
                classType = this.getClassType(':',col);
                startIndex=col-startCol+1;
                groupColumnSize = startColumnIndexes(startIndex+1) - startColumnIndexes(startIndex);
                % If coumns are manually resized in client, Do not set defaults.
                isColumnManuallyResized = this.getColumnModelProperty(col, 'ColumnResized');
                if ~(islogical(isColumnManuallyResized{1}) && isColumnManuallyResized{1}==true)
                    if strcmp(classType, 'datetime')
                        % Set datetime column width wider than default
                       width = internal.matlab.variableeditor.VEColumnConstants.datetimeColumnWidth;
                    elseif internal.matlab.variableeditor.peer.PeerUtils.isNumericType(classType)
                        colData = table2array(data(:, col));
                        if ~isreal(colData)
                            % Set complex number column width wider than
                            % default
                            width = internal.matlab.variableeditor.VEColumnConstants.complexNumDefaultWidth;
                        end
                    end
                    % Compare default width with it's existing width from
                    % columnModelProperty
                    nameWidth = width;
                    columnWidth = this.getColumnModelProperty(col,'ColumnWidth');
                    if this.UseTableColumnNamesForView
                        nameWidth = this.computeHeaderWidthUsingLabels(data.Properties.VariableNames{col});
                        if (nameWidth > width)
                            width = nameWidth;
                        end
                    end

                    % Also update when current width is > default width and the
                    % namewidth is lesser, this means the columns should shrink
                    % back to it's default width
                    if (width > internal.matlab.variableeditor.VEColumnConstants.defaultColumnWidth || groupColumnSize > 1 || ...
                            (nameWidth < width && ~isempty(columnWidth{1}) && (columnWidth{1} > width)))
                        % Need to set the column width property for any which
                        % are off default, or if they are grouped
                        this.setColumnModelProperty(col, 'ColumnWidth', width, false);
                    end
                end
            end
            this.ColumnModelChangeListener.Enabled = true;
         end

        function handleMetaDataChanged(this, ~, ed)
            data = this.DataModel.Data;
            if strcmp(ed.Property, 'VariableNames')
                metaData = '';
                editedHeaderIndex = find(~cellfun(@strcmp, ed.OldValue, ed.NewValue));
                if length(editedHeaderIndex) == 1
                   [~, ~, metaData] = this.formatDataBlock(1,size(data,1),editedHeaderIndex,editedHeaderIndex,data);
                end
                % if the column contains any valueSummaries then the editor
                % for those cells needs to be updated. So a DataChange
                % event is forced
                if ~isempty(metaData) && any(any(metaData))
                    eventdata = internal.matlab.variableeditor.DataChangeEventData;
                    eventdata.Range = [];
                    eventdata.Values = [];
                    this.notify('DataChange',eventdata);
                else
                    this.updateCurrentPageModels();
                end
            else
                this.updateCurrentPageModels();
            end
            % fires a selection changed event in case the metadata changed
            % is selected
            this.setSelection(this.SelectedRowIntervals, this.SelectedColumnIntervals);
        end

        function updateCurrentPageModels(this)
            this.updateColumMetaInfo();
            this.updateRowMetaInfo();
            this.updateCurrentPageModels@internal.matlab.variableeditor.peer.PeerArrayViewModel();
        end

        function [renderedData, renderedDims] = getRenderedData(this, startRow, endRow, ...
                startColumn, endColumn)
            % Get the rendered data from the StructureViewModel, and
            % reformat it for display in JS.
            [data, ~, startRow, endRow, startColumn, endColumn] = this.getRenderedData@internal.matlab.variableeditor.TableViewModel(...
                startRow, endRow, startColumn, endColumn);
            longData = data;
            rawData = this.DataModel.Data;
            isMetaData = this.MetaData;
            renderedData = {};

            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');
            % Gets the starting index of each column, if a column is
            % grouped the adjoining columns will not be listed
            startColumnIndexes = internal.matlab.variableeditor.TableViewModel.getColumnStartIndicies(rawData, startColumn, endColumn);

            previousFormat=get(0,'format');
            format('long');

            sRow = max(1,startRow);
            eRow = min(size(rawData,1),endRow);
            sCol = max(startColumn,1);
            eCol = min(endColumn,size(rawData,2));

            subData = rawData(sRow:eRow,sCol:eCol);
            numericIndicies = false(1,(size(startColumnIndexes,2)-1));
            for col=1:(size(startColumnIndexes,2)-1)
                actualColumn = startColumn+col-1;
                columnClass = this.getColumnModelProperties(actualColumn,'class');
                if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(columnClass)
                    numericIndicies(col) = true;
                elseif strcmp(columnClass, 'cell')
                    cellData = subData.(col);
                    if any(cellfun(@isnumeric,cellData))
                        numericIndicies(col) = true;
                    end
                end
            end

            numericData = subData(:,numericIndicies);
            if ~isempty(numericData)
                longNumericData = this.formatDataBlock(1,size(data,1),1,size(data,2),numericData);
            else
                longNumericData = numericData;
            end
            numericIndexCounter = 1;

            for col=1:(size(startColumnIndexes,2)-1)
                actualColumn = startColumn+col-1;
                varName = this.DataModel.Data.Properties.VariableNames{actualColumn};

                % Set escape values to false since it's not needed for numeric
                % strings, but capture the old value so that we can restore it
                columnClass = this.getColumnModelProperties(actualColumn,'class');
                doEscapeValues = ~(internal.matlab.variableeditor.peer.PeerUtils.isNumericType(columnClass) ||...
                                strcmp(columnClass,'logical'));

                for dataIndex=startColumnIndexes(col):startColumnIndexes(col+1)-1
                    if numericIndicies(col)==1
                        ld = longNumericData(:,numericIndexCounter);
                        if ~isempty(ld)
                            longData(:,dataIndex) = ld(:,1);
                        end
                        numericIndexCounter = numericIndexCounter+1;
                    end
                end

                colStr = colStrs{col};
                for row=1:size(data,1)
                    rowStr = rowStrs{row};
                    rowValue = '[';
                    % Loop through the inner columns
                    for dataIndex=startColumnIndexes(col):startColumnIndexes(col+1)-1
                        if dataIndex>startColumnIndexes(col)
                            rowValue = [rowValue ','];
                        end
                        editorValue = '';
                        currData = rawData{row+startRow-1,col+startColumn-1};
                        if isMetaData(row,dataIndex)
                            colIndex = (dataIndex-startColumnIndexes(col)+1);
                            % Treat nD data as its own data type.
                            if numel(size(rawData.(col))) > 2
                                editorValue = this.getNDEditorValue(this.DataModel.Name, varName, row, size(rawData.(col)));
                            % For objects that are of UDD type, set
                            % editorValue for indexing appropriately. 
                            elseif isempty(meta.class.fromName(class(currData)))
                                editorValue = sprintf('%s.%s(%d,%d)', this.DataModel.Name,varName,row+sRow-1,colIndex);
                            elseif ~isa(currData,'dataset') && ~matlab.internal.datatypes.istabular(currData) && ...
                                    ~isa(currData,'struct') && ~isnumeric(currData) && ...
                                    ~isobject(currData)
                                editorValue = sprintf('%s.%s{%d,%d}', this.DataModel.Name,varName,row+sRow-1,colIndex);
                            elseif isa(currData,'struct') || ...
                                    (isobject(currData) && ~matlab.internal.datatypes.istabular(currData))
                                editorValue = sprintf('%s.%s(%d,%d)', this.DataModel.Name,varName,row+sRow-1,colIndex);
                                isUnsupportedColumn = false;
                            else
                                editorValue = sprintf('%s.%s(%d,:)', this.DataModel.Name,varName,row+sRow-1);
                                isUnsupportedColumn = false;
                            end
                        end
                        cellValue = this.getJSONforCell(doEscapeValues, data{row,dataIndex}, longData{row,dataIndex}, this.MetaData(row,dataIndex), editorValue, row, col);

                        rowValue = [rowValue cellValue];
                    end
                    rowValue = [rowValue ']'];

                    renderedData{row,col} = internal.matlab.variableeditor.peer.PeerUtils.toJSON(doEscapeValues,...
                        struct('value', rowValue,...
                        'row',rowStr,...
                        'col',colStr...
                    ));
                end

            end

            format(previousFormat);

            renderedDims = size(renderedData);
        end

        function jsonData = getJSONforCell(this, doEscapeValues, data, longData, isMeta, editorValue, row, col)
            if ~isMeta %~this.MetaData(row,col)
                jsonData = ...
                    internal.matlab.variableeditor.peer.PeerUtils.toJSON(doEscapeValues,...
                    struct('value', data,...
                    'editValue', longData,...
                    'isMetaData', '0')...
                );
            else
                editor = 'variableeditor/views/editors/OpenvarEditor';
                % For strings with metaData , the value is <missing>, this
                % should not have a different editor.
                if strcmp(this.getClassType(row,col), 'string')
                    editor = ' ';
                end
                jsonData = ...
                    internal.matlab.variableeditor.peer.PeerUtils.toJSON(doEscapeValues,...
                    struct('value', data,...
                    'editValue', longData,...
                    'isMetaData', '1',...
                    'inplaceeditor','variableeditor/views/editors/TextBoxEditor',...
                    'editor', editor,...
                    'editorValue', editorValue) ...
                );
            end
        end

        function varargout = handlePeerEvents(this, es, ed)
            % Handles peer events from the client
            if isfield(ed.EventData, 'source') && strcmp('server', ed.EventData.source)
                % Ignore any events generated by the server
                varargout{1} = 'noop';
                return;
            end

            if isfield(ed.EventData,'type')
                switch ed.EventData.type
                    case 'groupedColumnSetData'
                        varargout{1} = this.handleClientSetGroupedData(ed.EventData);
                    otherwise
                        varargout{1} = this.handlePeerEvents@internal.matlab.variableeditor.peer.PeerArrayViewModel(es, ed);
                end
            end
        end

        % getData
        % Gets a block of data.
        % If optional input parameters are startRow, endRow, startCol,
        % endCol then only a block of data will be fetched otherwise all of
        % the data will be returned.
        function varargout = getData(this,varargin)
            % Superclass getData will return a table representation of the
            % data.
            t = this.getData@internal.matlab.variableeditor.ArrayViewModel(varargin{:});
            v = table2cell(t);
            varargout{1} = v;
        end
        
        % Calling into just getData for tables converts tables to
        % cellarray. Directly call into the dataModel's getData to get the
        % actual data
        function value = getDataForStringDisplay(this, varargin)
            value = this.DataModel.getData(varargin{:});
        end       

        function varargout = handleClientSetGroupedData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
            data = this.getStructValue(varargin{1}, 'data');
            
            % add logic for handling checkbox
            if islogical(data)
                if data
                    data = '1';
                else
                    data = '0';
                end
            end
            
            
            row = this.getStructValue(varargin{1}, 'row');
            column = this.getStructValue(varargin{1}, 'column');
            columnIndex = this.getStructValue(varargin{1}, 'columnIndex');
            varargout{1} = '';
            try
                if ~isempty(row)
                    if ischar(row)
                        row = str2double(row);
                    end
                    row = row+1;
                    if ischar(column)
                        column = str2double(column);
                    end
                    column = column+1;
                    if ischar(columnIndex)
                        columnIndex = str2double(columnIndex);
                    end
                    columnIndex = columnIndex+1;

                    removeQuotes = this.getCellPropertyValue(row, column, 'RemoveQuotedStrings');
                    if ~isempty(removeQuotes) && iscell(removeQuotes)
                        removeQuotes = removeQuotes{1};
                    end
                    if ~isempty(removeQuotes) && ~isempty(data) && ((islogical(removeQuotes) && removeQuotes==true) || strcmp(removeQuotes,'true') || strcmp(removeQuotes,'on'))
                            data = strrep(data,'''','''''');
                            data = ['''' data ''''];
                    end

                    % Check for empty value passed from user and replace
                    % with valid "empty" value
                    if isempty(data)
                        data = this.getEmptyValueReplacement(row,column);
                    else
                        % For strings, parse such that inputValidation takes place
                        classType = this.getClassType(row, column);
                        data = internal.matlab.variableeditor.peer.PeerUtils.parseStringQuotes(data, classType);
                        isStr = strcmp(classType,'string');

                        if (isStr)
                            origData = this.getStructValue(varargin{1}, 'data');
                            if ~isequal(origData, '''') && ~isequal(origData, '"')
                                % Escape /n and /t if the input data contains these characters
                                data = internal.matlab.variableeditor.peer.PeerUtils.escapeSpecialCharsForStrings(data);

                                if startsWith(data, '""') && ...
                                        endsWith(data, '""') && ...
                                        strlength(data) > 2 && isStr
                                    if ~startsWith(data, '"" +')
                                        data = ['"' data];
                                    end
                                    if ~endsWith(data, '+ ""')
                                        data = [data '"'];
                                    end
                                end
                            else
                                data = origData;
                            end
                        end

                        % TODO: Code below does not test for expressions in terms
                        % of variables in the current workspace (e.g. "x(2)") and
                        % it allows expression in terms of local variables in this
                        % workspace. We need a better method for testing validity.
                        % LXE may provide this capability.
                        [result] = evalin(this.DataModel.Workspace, data); % Test for a valid expression.
                        if ~this.validateInput(result,row,column)
                            error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                        end
                    end

                    % Send data change event for equal data
                    eValue = evalin(this.DataModel.Workspace, data);
                    dispValue = strtrim(evalc('evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
                    currentValue = this.getData(row, row, column, column);
                    if iscell(currentValue) && columnIndex>0
                        currentValue = currentValue{:}(columnIndex);
                    end
                    
                    % disable warning for datetime isequal.
                    savedWarning = internal.matlab.variableeditor.peer.PeerUtils.disableWarning();
                    if isequal(eValue, currentValue)
                        this.sendPeerEvent('dataChangeStatus','status', 'noChange', 'dispValue', dispValue, 'row', row-1, 'column', column-1);
                        % Even though the data has not changed we will fir
                        % a data changed event to take care of the case
                        % that the user has typed in a value that was to be
                        % evaluated in order to clear the expression and
                        % replace it with the value (e.g. pi with 3.1416)
                        eventdata = internal.matlab.variableeditor.DataChangeEventData;
                        eventdata.Range = [row,column];
                        eventdata.Values = this.getRenderedData(row,row,column,column);
                        if ~isempty(eventdata.Values)
                            eventdata.Values = eventdata.Values{1,1};
                        end
                        this.notify('DataChange',eventdata);
                    end
                    % enable warning
                    internal.matlab.variableeditor.peer.PeerUtils.resumeWarning(savedWarning);

                    lhs = this.DataModel.getLHSGrouped(sprintf('%d,%d',row,column),columnIndex);
                    setCommand = sprintf('%s = %s;',lhs,this.DataModel.getRHS(data));
                    varargout{1} = this.DataModel.executeSetCommand(setCommand, dispValue, row, column, columnIndex);
                    this.sendPeerEvent('dataChangeStatus','status', 'success', 'dispValue', dispValue, 'row', row-1, 'column', column-1);
                else
                    error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                end
            catch e
                % Send data change event.
                this.sendPeerEvent('dataChangeStatus','status', 'error','message', e.message, 'row', row-1, 'column', column-1);

                varargout{1} = e;
            end

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

            if strcmpi(ed.EventData.key, 'ColumnModelProperty') || strcmpi(ed.EventData.key, 'RowModelProperty')
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');

                % if the column header names are set by the user
                if strcmp(property,'HeaderName')
                    columnNames = this.DataModel.Data.Properties.VariableNames;
                    column = this.getStructValue(ed.EventData.newValue,'column');

                    % if the header value is unchanged then do nothing
                    if isequal(columnNames{column+1}, value)
                        return;
                    end

                    try
                        % if the column header name is not a duplicate
                        if ~any(ismember(columnNames, value))
                            % Execute table update command
                            cmd = sprintf('%s.Properties.VariableNames{%d} = ''%s'';',...
                                this.DataModel.Name,...
                                column+1,...
                                value);
                            if ischar(this.DataModel.Workspace)
                                % Requires a row/column, even though row
                                % will be unused.
                                this.executeSetTablePropertyCommand(cmd, 1, column);
                            else
                                this.DataModel.Workspace.evalin(cmd);
                            end
                            return
                        else
                            % throw an error if the column header name is
                            % a duplicate
                            error(message('MATLAB:codetools:variableeditor:DuplicateColumnHeaderTables', value));
                        end
                    catch e
                        % if the column header name is a duplicate then the
                        % error thrown is caught here and published to the
                        % client
                        this.sendPeerEvent('ErrorDuplicateColumnHeader', 'status', 'error', 'message', e.message, 'index',  this.getStructValue(ed.EventData.newValue,'column'));
                    end
                % if the row header names are set by the user
                elseif strcmp(property, 'RowName')
                    % Using cellstr for converting rowNames incase of
                    % timeTables where they have different formats.
                    rowNames = cellstr(this.DataModel.Data.Properties.RowNames);
                    row = this.getStructValue(ed.EventData.newValue,'row');

                    % if the header value is unchanged then do nothing
                    if isequal(rowNames{row+1}, value)
                        return;
                    end

                    try
                        % if the row header name is not a duplicate
                        if ~ismember(rowNames, value)
                            % escape apostrophes ("'")
                            value = strrep(value,'''','''''');

                            % Execute table update command
                            cmd = sprintf('%s.Properties.RowNames{%d} = ''%s'';',...
                            this.DataModel.Name,...
                            row+1,...
                            value);
                            if ischar(this.DataModel.Workspace)
                                % Execute the command to set the header name
                                c = internal.matlab.datatoolsservices.CodePublishingService.getInstance;
                                channel = ['VariableEditor/' this.DataModel.Name];
                                c.publishCode(channel, cmd);
                            else
                                this.DataModel.Workspace.evalin(cmd);
                            end
                            return
                        else
                            % if the row header name is a duplicate then
                            % throw an error message
                            error(message('MATLAB:codetools:variableeditor:DuplicateRowHeader', value));
                        end
                    catch e
                        % if the row header name is a duplicate then the
                        % error thrown is a caught and published to the
                        % client
                        this.sendPeerEvent('ErrorDuplicateRowHeader', 'status', 'error', 'message', e.message, 'index',  this.getStructValue(ed.EventData.newValue,'row'));
                    end

                end
            end
       end
       
       function delete(this)
            if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                message.unsubscribe(this.perfSubscription);
            end
        end
    end

    methods(Access='protected')       
        function isValid = validateInput(this,value,row,column)
            % The only valid input types are 1x1 doubles
            classType = this.getClassType(row,column);
            if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(classType)
                isValid = isnumeric(value) && size(value, 1) == 1 && size(value, 2) == 1;
            else
                switch classType
                    case 'char'
                        isValid = ischar(value) && size(value, 1) == 1;
                    case 'string'
                        isValid = internal.matlab.variableeditor.FormatDataUtils.checkIsString(value) && size(value, 1) == 1;
                    case 'logical'
                        isValid = (islogical(value) || isnumeric(value)) && size(value, 1) == 1 && size(value, 2) == 1;
                    case 'datetime'
                        % Since the client is sending characters we need to try to
                        % convert them to a valid datetime object. This requires
                        % getting a copy of the actual datetime data in the table and trying an
                        % assignment of the form data(row, column) = value. If the
                        % result is a datetime, then the value is valid. If an
                        % exception occurs, throw a datetime specific error instead
                        % of the error sent from handleClientSetData. (g1239590)
                        if ischar(value) && size(value, 1) == 1
                            try
                                dt = this.getData();
                                dt = dt{row, column};
                                dt(1) = value;
                                isValid = isdatetime(dt);
                            catch
                                error(message('MATLAB:datetime:InvalidFromVE'));
                            end
                        else
                            isValid = false;
                        end
                    otherwise
                        isValid = true;
                end
            end
        end

        function result = evaluateClientSetData(this, data, row, column)
            % In case of numeric or logival columns, if the user types a single character
            % in single quotes, it is converted to its equivalent ascii value
            result = [];
            classType = this.getClassType(row,column);
            if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(classType) || isequal(classType, 'logical')
                if (isequal(length(data), 3) && isequal(data(1),data(3),''''))
                    result = double(data(2));
                end
            end
        end

        function varName = getVariableName(this, ~, column) %#ok<INUSL>
            varName = eval(sprintf('this.DataModel.Data.Properties.VariableNames{%d}',column));
        end

        function classType = getClassType(this, row, column)
            classType = eval(sprintf('class(this.DataModel.Data.%s)',this.getVariableName(row,column)));
        end

        function replacementValue = getEmptyValueReplacement(this,row,column)
            classType = this.getClassType(row,column);
            if internal.matlab.variableeditor.peer.PeerUtils.isNumericType(classType)
                replacementValue = '0';
            else
                switch classType
                    case 'logical'
                        replacementValue = '0';
                    case 'datetime'
                        replacementValue = 'NaT';
                    case 'duration'
                        replacementValue = 'NaN';
                    case 'calendarDuration'
                        replacementValue = 'NaN';
                    case 'string'
                        replacementValue = 'string('''')';
                    otherwise
                        replacementValue = '[]';
                end
            end
        end

        function varargout = refresh(this, es ,ed)
            this.updateCurrentPageModels();
            varargout = this.refresh@internal.matlab.variableeditor.peer.PeerArrayViewModel(es,ed);
        end

        function updateColumMetaInfo(this)
            this.ColumnModelChangeListener.Enabled = false;
            currentData = this.DataModel.Data;
            widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();

            startCol = max(1, this.StartColumn);
            if ~isempty(currentData)
                endCol = min(this.EndColumn, size(currentData,2));
            else
                endCol = size(currentData, 2);
            end

            startColumnIndexes = internal.matlab.variableeditor.TableViewModel.getColumnStartIndicies(currentData, startCol, endCol);

            for col=startCol:endCol
                % Set Header Name
                if this.UseTableColumnNamesForView
                    name = currentData.Properties.VariableNames{col};
                    this.setColumnModelProperty(col,'HeaderName',name);
                end
                
                % Set the sortable flag
                isSortable = internal.matlab.variableeditor.peer.PeerUtils.checkIsSortable(currentData(:,col), false);
                this.setColumnModelProperty(col,'IsSortable',isSortable);

                % Set the Group Column Sizes
                startIndex=col-startCol+1;
                this.setColumnModelProperty(col,'GroupColumnSize',num2str(startColumnIndexes(startIndex+1)-startColumnIndexes(startIndex)));

                classType = this.getClassType(':',col);
                switch classType
                    case {'categorical' 'nominal' 'ordinal'}
                        % Get the list of categories and whether it is a
                        % protected categorical or not.  Treat categorical,
                        % nominal and ordinal all the same.
                        cats = categories(currentData.(this.getVariableName(':',col)));
                        % Limit the number of categories displayed, otherwise we
                        % hit OutOfMemory errors
                        cats(internal.matlab.variableeditor.FormatDataUtils.MAX_CATEGORICALS:end) = [];

                        this.setColumnModelProperties(col,...
                            'categories', cats,...
                            'isProtected', num2str(isprotected(currentData.(this.getVariableName(':',col)))),...
                            'EditorConverter', 'addSingleQuotesConverter');
                    case {'datetime'}
                        % Datetime columns require a converter
                        this.setColumnModelProperties(col, 'EditorConverter', 'datetimeConverter');
                end

                % Set Renderers and Editors
                varName = currentData.Properties.VariableNames(col);
                val = currentData.(char(varName));
                className = class(val);
                [widgets,~,matchedVariableClass] = widgetRegistry.getWidgets(class(this),className);
                if (isobject(val) || isempty(meta.class.fromName(class(val)))) && isempty(matchedVariableClass)
                    className = 'object';
                    [widgets, ~, matchedVariableClass] = widgetRegistry.getWidgets(class(this), className);
                end

                [groupedColumnWidgets, ~, ~] = widgetRegistry.getWidgets('', className);

                % if className is different from matchedVariableClass then
                % it means that the current data type is unsupported. In
                % this case, the metadata of the unsupported object should
                % be displayed in the table column.
                if ~strcmp(className,matchedVariableClass)
                    widgets = widgetRegistry.getWidgets(class(this),'default');
                    className = matchedVariableClass;
                end
                
                % check if derived classes need to customize widgets.
                [widgets, groupedColumnWidgets] = this.getCustomizedWidgets(widgets, groupedColumnWidgets, currentData, col);               
                
                if ~internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(this.usercontext)
                    this.setColumnModelProperties(col,...
                        'renderer', widgets.CellRenderer,...
                        'editor', groupedColumnWidgets.Editor,...
                        'inplaceeditor', groupedColumnWidgets.InPlaceEditor,...
                        'groupedcolumnrenderer', groupedColumnWidgets.CellRenderer,...
                        'groupedcolumneditor', groupedColumnWidgets.Editor,...
                        'groupedcolumninplaceeditor', groupedColumnWidgets.InPlaceEditor,...
                        'class', className);
                else
                    this.setColumnModelProperties(col, ...
                        'class', className);
                end

            end
            this.setDefaultColumnWidth(currentData);
            this.ColumnModelChangeListener.Enabled = true;
        end

        function updateRowMetaInfo(this)
            this.RowModelChangeListener.Enabled = false;
            currentData = this.DataModel.Data;

            if this.UseTableRowNamesForView
                % currentData could either be a regular table or
                % timetable.Using cellstr to handle both these types.
                if isfield(currentData.Properties, 'RowNames')
                    rowNames = currentData.Properties.RowNames;
                elseif isfield(currentData.Properties, 'RowTimes')
                    rowNames = currentData.Properties.RowTimes;
                else
                    rowNames = {};
                end
                rowName = cellstr(rowNames);
                for row=this.StartRow:this.EndRow
                    % Set Header Name
                    if ~isempty(rowNames) && row<=size(rowNames,1) && ...
                            ~isempty(rowName{row})
                        this.setRowModelProperty(row,'RowName',rowName{row});
                    else
                        this.setRowModelProperty(row,'RowName','');
                    end
                end
            end
            this.RowModelChangeListener.Enabled = true;
        end

        % nD data in a table is accessed using parentheses and an
        % appropriate number of colons.
        %
        % For example, a 4-by-2-by-7 cell array would have a name of
        % <table>.<cellName>(<row>, :, :).
        %
        % A 4-by-2-by-7-by-3 struct array would have a name of
        % <table>.<structArrayName>(<row>, :, :, :).
        function editorValue = getNDEditorValue(~, name, varName, row, sz)
            editorValue = sprintf('%s.%s(%d', name, varName, row);
            for idx = 2:numel(sz)
                editorValue = [editorValue, ',:']; %#ok<AGROW>
            end
            editorValue = [editorValue, ')'];
        end

        function executeSetTablePropertyCommand(this, cmd, row, column)
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
    
    methods (Access='protected')
        
        % give derived classes a chance to customize widgets
        function [widgets, groupedColumnWidgets] = getCustomizedWidgets(this, widgets, groupedColumnWidgets, value, col)
            % no op
        end
        
    end  
end
