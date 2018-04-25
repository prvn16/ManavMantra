classdef PeerArrayViewModel < internal.matlab.variableeditor.ArrayViewModel & internal.matlab.variableeditor.peer.PeerVariableNode
    %PEERARRAYVIEWMODEL Peer Model Array View Model
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Constant)
        % PeerNodeType
        PeerNodeType = '_VariableEditorViewModel_';
        
        WindowBlockRows = 200;
        WindowBlockColumns = 200;
    end
    
    properties
        StartRow = 1;
        EndRow = 1;
        StartColumn = 1;
        EndColumn = 1;
        
        PagedDataHandler = [];
    end
    
    properties(SetAccess='protected',GetAccess='protected')
        CellModelChangeListener;
        TableModelChangeListener;
        RowModelChangeListener;
        ColumnModelChangeListener;
        sortHandler;
    end
    
    methods
        function this = PeerArrayViewModel(parentNode, variable, varargin)
            this@internal.matlab.variableeditor.ArrayViewModel(variable.DataModel);
            this = this@internal.matlab.variableeditor.peer.PeerVariableNode(...
                parentNode, ...
                internal.matlab.variableeditor.peer.PeerArrayViewModel.PeerNodeType, ...
                'name', variable.Name, varargin{:});
            
            this.setTableModelProperties(...
                'ShowColumnHeaders', true,...
                'ShowRowHeaders', true,...
                'ShowColumnHeaderNumbers', true,...
                'ShowRowHeaderNumbers', true,...
                'ShowColumnHeaderLabels', true,...
                'ShowRowHeaderLabels', true);
            this.CellModelChangeListener = event.listener(this, 'CellModelChanged', @(es,ed)this.handleCellModelUpdate(es,ed));
            this.TableModelChangeListener = event.listener(this, 'TableModelChanged', @(es,ed)this.handleTableModelUpdate(es,ed));
            this.RowModelChangeListener = event.listener(this, 'RowModelChanged', @(es,ed)this.handleRowModelUpdate(es,ed));
            this.ColumnModelChangeListener = event.listener(this, 'ColumnModelChanged', @(es,ed)this.handleColumnModelUpdate(es,ed));
        end
        
        function status = handlePropertySet(this, ~, ed)
            this.logDebug('PeerArrayView','handlePropertySet','');
            
            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success,
            % an error message otherwise.
            status = '';
            if isfield(ed.EventData,'source') && strcmp('server',ed.EventData.source)
                return;
            end
            
            if strcmpi(ed.EventData.key, 'Selection')
                this.handleClientSelection(ed.EventData);
            elseif strcmpi(ed.EventData.key, 'TableModelProperties')
            elseif strcmpi(ed.EventData.key, 'TableModelProperty')
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');
                this.TableModelChangeListener.Enabled = false;
                this.setTableModelProperty(property, value);
                % Update the JSON internal cache
                this.updateTableModelInformation();
                this.TableModelChangeListener.Enabled = true;
            elseif strcmpi(ed.EventData.key, 'CellModelProperties')
            elseif strcmpi(ed.EventData.key, 'CellModelProperty')
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');
                row = this.getStructValue(ed.EventData.newValue,'row');
                column = this.getStructValue(ed.EventData.newValue,'column');
                this.CellModelChangeListener.Enabled = false;
                this.setCellModelProperty(row, column, property, value);
                % Update the JSON internal cache
                this.updateCellModelInformation(this.StartRow, this.EndRow, this.StartColumn, this.EndColumn);
                this.CellModelChangeListener.Enabled = true;
            elseif strcmpi(ed.EventData.key, 'ColumnModelProperties')
            elseif strcmpi(ed.EventData.key, 'ColumnModelProperty')
                column = this.getStructValue(ed.EventData.newValue,'column');
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');
                this.ColumnModelChangeListener.Enabled = false;
                this.setColumnModelProperty(column+1, property, value);
                % Update the JSON internal cache
                [~, ~, startColumn, endColumn] = this.getCurrentPage();
                if any(column+1 >= startColumn) && any(column+1 <= endColumn)
                    this.updateColumnModelInformation(startColumn, endColumn);
                end
                this.ColumnModelChangeListener.Enabled = true;
            elseif strcmpi(ed.EventData.key, 'RowModelProperties')
            elseif strcmpi(ed.EventData.key, 'RowModelProperty')
                row = this.getStructValue(ed.EventData.newValue,'row');
                property = this.getStructValue(ed.EventData.newValue,'property');
                value = this.getStructValue(ed.EventData.newValue,'value');
                this.RowModelChangeListener.Enabled = false;
                this.setRowModelProperty(row+1, property, value);
                % Update the JSON internal cache
                [startRow, endRow, ~, ~] = this.getCurrentPage();
                if any(row+1 >= startRow) && any(row+1 <= endRow)
                    this.updateRowModelInformation(startRow, endRow);
                end
                this.RowModelChangeListener.Enabled = true;
            else
                this.sendErrorMessage(getString(message(...
                    'MATLAB:codetools:variableeditor:UnsupportedProperty', ...
                    ed.EventData.key)));
                status = 'error';
            end
        end
        
        function status = handlePropertyDeleted(this, ~, ed)
            this.logDebug('PeerArrayView','handlePropertyDeleted','');
            
            % Handles properties being deleted.  ed is the Event Data, and
            % it is expected that ed.EventData.key contains the property
            % which is being deleted.  Returns a status: empty string for
            % success, an error message otherwise.  Note - Currently there
            % are no properties which can be deleted.
            status = '';
            if strcmpi(ed.EventData.key, 'Selection')
                this.sendErrorMessage(getString(message(...
                    'MATLAB:codetools:variableeditor:RequiredPropertyDeleted', ...
                    ed.EventData.key)));
                status = 'error';
            end
        end
        
        % setSelection
        function varargout = setSelection(this,selectedRows,selectedColumns,varargin)
            this.logDebug('PeerArrayView','setSelection','');
            
            varargout{1} = this.setSelection@internal.matlab.variableeditor.ArrayViewModel(...
                selectedRows, selectedColumns);
            
            % This is an optional parameter to indicate the source of the
            % selection change.
            if nargin<=3
                selectionSource = 'server';
            else
                selectionSource = varargin{1};
            end
            
            % Send a Selection property change
            %TODO: Is there a way to eliminate the HashMap usage?  Would
            % require modifying the MCOS peer model API to allow a structure
            % for the setProperty method.
            
            
            selectedRowObjs = '[';
            for i=1:size(this.SelectedRowIntervals,1)
                if i>1
                    selectedRowObjs = [selectedRowObjs ',']; %#ok<AGROW>
                end
                selectedRowObjs = [selectedRowObjs '{"start" : ' num2str(this.SelectedRowIntervals(i,1)-1) ', "end" : ' num2str(this.SelectedRowIntervals(i,2)-1) '}']; %#ok<AGROW>
            end
            selectedRowObjs = [selectedRowObjs ']'];
            
            selectedColumnObjs = '[';
            for i=1:size(this.SelectedColumnIntervals,1)
                if i>1
                    selectedColumnObjs = [selectedColumnObjs ',']; %#ok<AGROW>
                end
                selectedColumnObjs = [selectedColumnObjs '{"start" : ' num2str(this.SelectedColumnIntervals(i,1)-1) ', "end" : ' num2str(this.SelectedColumnIntervals(i,2)-1) '}']; %#ok<AGROW>
            end
            selectedColumnObjs = [selectedColumnObjs ']'];
            
            
            props = struct('selectedRows', selectedRowObjs, ...
                'selectedColumns', selectedColumnObjs, ...
                'source','server', ...
                'selectionSource', selectionSource);
            this.setProperty('Selection', props);
        end
        
        function varargout = handlePeerEvents(this, ~, ed)
            this.logDebug('PeerArrayView','handlePeerEvents','');
            
            % Handles peer events from the client
            if isfield(ed.EventData, 'source') && strcmp('server', ed.EventData.source)
                % Ignore any events generated by the server
                varargout{1} = 'noop';
                return;
            end
            
            if isfield(ed.EventData,'type')
                switch ed.EventData.type
                    case 'getSize'
                        varargout{1} = this.handleClientGetSize(ed.EventData);
                    case 'getData'
                        varargout{1} = this.handleClientGetData(ed.EventData);
                    case 'getStringData'
                        varargout{1} = this.handleClientGetStringData(ed.EventData);
                    case 'setData'
                        varargout{1} = this.handleClientSetData(ed.EventData);
                    case 'sortEvent'
                        varargout{1} = this.handleClientSort(ed.EventData);
                    case 'undoSortEvent'
                        varargout{1} = this.handleClientSortUndo(ed.EventData);
                    case 'redoSortEvent'
                        varargout{1} = this.handleClientSortRedo(ed.EventData);
                    otherwise
                        this.sendErrorMessage(getString(message(...
                            'MATLAB:codetools:variableeditor:UnsupportedRequest', ...
                            ed.EventData.type)));
                        varargout{1} = 'error';
                end
            end
        end
        
        function data = handleClientGetStringData(this, varargin)
            % Converts client getData request to MCOS getData call
            % if rows less than 10 then show all
            startRow =  this.getStructValue(varargin{1}, 'startRow') + 1;
            endRow = min(this.getStructValue(varargin{1}, 'endRow') + 1, size(this.DataModel.Data,1));
            startColumn = min(this.getStructValue(varargin{1}, 'startColumn') + 1, size(this.DataModel.Data,2));
            endColumn = size(this.DataModel.Data,2);
            
            % adjust rows
            if size(this.DataModel.Data,1) > 10 
                startRow = endRow - 9;
            end

            data = this.getDataForStringDisplay(startRow, endRow, startColumn, endColumn);
            scalingFactor = strings(0,0);
            if isprop(this, 'scalingFactorString')
                scalingFactor = this.scalingFactorString;
            end
            stringData = internal.matlab.variableeditor.peer.PeerDataUtils.getStringData(this.getDataForStringDisplay(), data, endRow-startRow+1, size(this.DataModel.Data,2)-startColumn+1, scalingFactor);
            
            % Dispatch a peer event with the data
            this.PeerNode.dispatchEvent(struct('type', 'setStringData', ...
                'source', 'server', ...
                'startRow', startRow-1, ...
                'endRow', endRow-1, ...
                'startColumn', startColumn-1, ...
                'endColumn', endColumn-1, ...
                'data', {stringData} ));
        end
                
        % wrapper around getData. Required since getData for tables returns a cell array instead of table.
        % Wrapper function returns data in the form of table
        function value = getDataForStringDisplay(this, varargin)
            value = this.getData(varargin{:});
        end
        
        % handleClientSelection
        function varargout = handleClientSelection(this,eventData)
            this.logDebug('PeerArrayView','handleClientSelection','');
            % Converts client selection event into MCOS selection call
            if strcmpi('server',this.getStructValue(eventData,'source')) || ...
                    (~isempty(this.getStructValue(eventData,'newValue')) && ...
                    strcmpi('server', this.getStructValue(this.getStructValue(eventData,'newValue'),'source')))
                % Ignore any events generated by the server
                return;
            end
            
            selectedRowsMap = this.getStructValue(...
                this.getStructValue(eventData, 'newValue'), 'selectedRows');
            selectedColumnsMap = this.getStructValue(...
                this.getStructValue(eventData, 'newValue'), 'selectedColumns');
            selectedRows = zeros(length(selectedRowsMap),2);
            selectedColumns = zeros(length(selectedColumnsMap),2);
            
            % Get the selected rows from the map
            for i=1:length(selectedRowsMap)
                selectedRows(i,1) = this.getStructValue(...
                    selectedRowsMap(i), 'start') + 1;
                selectedRows(i,2) = this.getStructValue(...
                    selectedRowsMap(i), 'end') + 1;
            end
            
            % Get the selected columns from the map
            for i=1:length(selectedColumnsMap)
                selectedColumns(i,1) = this.getStructValue(...
                    selectedColumnsMap(i), 'start') + 1;
                selectedColumns(i,2) = this.getStructValue(...
                    selectedColumnsMap(i), 'end') + 1;
            end
            
            % Call setSelection with optional selection source parameter
            % set to client.
            varargout{:} = this.setSelection(selectedRows,selectedColumns,'client');
        end
        
        function data=handleClientGetData(this, varargin)
            % Converts client getData request to MCOS getData call
            startRow = this.getStructValue(varargin{1}, 'startRow') + 1;
            endRow = this.getStructValue(varargin{1}, 'endRow') + 1;
            startColumn = this.getStructValue(varargin{1}, 'startColumn') + 1;
            endColumn = this.getStructValue(varargin{1}, 'endColumn') + 1;
            this.setCurrentPage(startRow, endRow, startColumn, endColumn);
            
            this.logDebug('PeerArrayView','handleClientGetSize','','startRow',startRow,'endRow',endRow,'startColumn',startColumn,'endColumn',endColumn);
            
            data=this.refreshRenderedData(varargin{:});
        end
        
        function varargout = handleClientSort(this, varargin)
            % Performs sorting and code generation
            sortInfo = varargin{1};
            this.sortHandler.newSortCommand(sortInfo);
            varargout{1} = '';
        end
        
        function varargout = handleClientSortUndo(this, varargin)
            % Performs UNDO on last sort operation
            undoInfo = varargin{1};
            this.sortHandler.undo(undoInfo);
            varargout{1} = '';
        end
        
        function varargout = handleClientSortRedo(this, varargin)
            % Performs REDO on last sort undo operation
            redoInfo = varargin{1};
            this.sortHandler.redo(redoInfo);
            varargout{1} = '';
        end
        
        function [renderedData, renderedDims]=refreshRenderedData(this, varargin)
            % Fetches latest rendered data and sends an update to the
            % client with that data block.
            startRow = this.getStructValue(varargin{1}, 'startRow') + 1;
            endRow = this.getStructValue(varargin{1}, 'endRow') + 1;
            startColumn = this.getStructValue(varargin{1}, 'startColumn') + 1;
            endColumn = this.getStructValue(varargin{1}, 'endColumn') + 1;
            
            this.logDebug('PeerArrayView','refreshRenderedData','','startRow',startRow,'endRow',endRow,'startColumn',startColumn,'endColumn',endColumn);
            
            % Get the rendered data and dimensions
            [renderedData, renderedDims] = this.getRenderedData(...
                startRow, endRow, startColumn, endColumn);
            
            % Dispatch a peer event with the data
            this.PeerNode.dispatchEvent(struct('type', 'setData', ...
                'source', 'server', ...
                'startRow', startRow-1, ...
                'endRow', endRow-1, ...
                'startColumn', startColumn-1, ...
                'endColumn', endColumn-1, ...
                'data', {renderedData}, ...
                'rowCount',renderedDims(1), ...
                'columnCount',renderedDims(2)));
        end
        
        function data=handleClientGetSize(this, varargin)
            this.logDebug('PeerArrayView','handleClientGetSize','');
            
            % Handles getSize from the client and dispatches a setSize peer
            % event.
            data = this.getSize;
            this.setProperty('Size', struct('source', 'server', ...
                'rowCount', data(1), 'columnCount', data(2)));
        end
        
        function sendPeerEvent(this, eventType, varargin)
            % Check for paired values
            if nargin<4 || rem(nargin-2, 2)~=0
                error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
            end
            
            if ~isempty(this.PagedDataHandler)
                gridNode = this.PagedDataHandler.getGridNode;
            else
                gridNode = this.PeerNode;
            end
            hm = java.util.HashMap;
            hm.put('source', 'server');
            for i=1:2:nargin-2
                hm.put(varargin{i},varargin{i+1});
            end
            gridNode.dispatchPeerEvent(eventType,gridNode,hm);
        end
        
        function logDebug(this, class, method, message, varargin)
            if internal.matlab.variableeditor.peer.PeerUtils.isDebug && ...
                    ~isempty(this.PagedDataHandler)
                gridNode = this.PagedDataHandler.getGridNode;
                internal.matlab.variableeditor.peer.PeerUtils.logDebug(gridNode, class, method, message, varargin{:});
            end
        end
        
        function varargout = handleClientSetData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
            triplets = this.getStructValue(varargin{1}, 'triplets');
            data = this.getStructValue(varargin{1}, 'data');
            row = this.getStructValue(varargin{1}, 'row');
            column = this.getStructValue(varargin{1}, 'column');
            varargout{1} = '';
            try
                if ~isempty(row)
                    if ischar(row)
                        row = str2double(row);
                    end
                    if ischar(column)
                        column = str2double(column);
                    end
                    
                    this.logDebug('PeerArrayView','handleClientSetData','','row',row,'column',column,'data',data);
                    
                    isStr = strcmp(this.getClassType(row, column),'string');
                    removeQuotes = this.getCellPropertyValue(row, column, 'RemoveQuotedStrings');
                    if ~isempty(removeQuotes) && iscell(removeQuotes)
                        removeQuotes = removeQuotes{1};
                    end
                    if ~isempty(removeQuotes) && ~isempty(data) && ...
                            ((islogical(removeQuotes) && removeQuotes==true) || ...
                            strcmp(removeQuotes,'true') || ...
                            strcmp(removeQuotes,'on')) && ~isStr
                        data = strrep(data,'''','''''');
                        data = ['''' data ''''];
                    end
                    
                    % Check for empty value passed from user and replace
                    % with valid "empty" value
                    if isempty(data)
                        data = this.getEmptyValueReplacement(row,column);
                        if ~ischar(data)
                            data = mat2str(data);
                        end
                    else
                        % TODO: Code below does not test for expressions in terms
                        % of variables in the current workspace (e.g. "x(2)") and
                        % it allows expression in terms of local variables in this
                        % workspace. We need a better method for testing validity.
                        % LXE may provide this capability.
                        if ~ischar(data)
                            try
                                data = mat2str(data);
                            catch
                                % Ignore exceptions, try to continue.  Not
                                % all input needs to go through mat2str
                            end
                        end
                        
                        % Additional processing if the data is currently a
                        % string, or if the user is entering a string by
                        % wrapping the value in double-quotes
                        if isStr || (ischar(data) && startsWith(data, '"') && endsWith(data, '"'))
                            origData = this.getStructValue(varargin{1}, 'data');
                            if ~isequal(origData, '''') && ~isequal(origData, '"')
                                % Escape quotes if datatype is of type string
                                % to be able to evaluate in command line.
                                data = internal.matlab.variableeditor.peer.PeerUtils.parseStringQuotes(data, 'string');
                                % Escape /n and /t if the input data contains these characters, checking for chars
                                % as well to support inline editing of strings in struct arrays.
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
                        
                        % evaluates the expression typed by the user to any
                        % equivalent value for that data type
                        [result] = this.evaluateClientSetData(data, row, column);
                        % If the data type does not have any custom
                        % evaluation code then it evaluates the expression
                        % in the workspace
                        if isempty(result)
                            [result] = evalin(this.DataModel.Workspace, data);  % Test for a valid expression.
                        end
                        if ~this.validateInput(result,row,column)
                            error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                        end
                    end
                    
                    % Send data change event for equal data
                    if ~(ischar(data) && isempty(data)) && ~(isStr)
                        % Use the data from evaluateClientSetData if it is
                        % set
                        eValue = this.evaluateClientSetData(data, row, column);
                        if isempty(eValue)
                            eValue = evalin(this.DataModel.Workspace, data);
                        end
                    else
                        eValue = data;
                    end
                    
                    if ~ischar(eValue)
                        if ~ischar(this.DataModel.Workspace) && ...
                                ismethod(this.DataModel.Workspace, 'disp')
                            try
                                dispValue = this.DataModel.Workspace.disp(data);
                            catch
                                dispValue = strtrim(evalc('evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
                            end
                        else
                            try
                                % Use the data from evaluateClientSetData
                                % if it is set
                                dispValue = strtrim(evalc('disp(this.evaluateClientSetData(data, row, column))'));
                                if isempty(dispValue)
                                    dispValue = strtrim(evalc('evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
                                end
                            catch
                                dispValue = '';
                            end
                        end
                    else
                        dispValue = data;
                    end
                    
                    % When a table sets a single cell, it is possible that
                    % the data is a cell, in which case we need to get the
                    % value from the cell.
                    currentValue = this.getData(row, row, column, column);
                    if iscell(currentValue)
                        currentValue = currentValue{:};
                    end
                    
                    if ~this.didValuesChange(eValue, currentValue)
                        this.sendPeerEvent('dataChangeStatus','status', 'noChange', 'dispValue', dispValue, 'row', row-1, 'column', column-1);
                        % Even though the data has not changed we will fire
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
                    varargout{1} = this.executeCommandInWorkspace(data, row, column);
                    this.sendPeerEvent('dataChangeStatus','status', 'success', 'dispValue', dispValue, 'row', row-1, 'column', column-1);
                elseif ~isempty(triplets)
                    % Check for paired values
                    if rem(length(triplets), 3)~=0
                        error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                    end
                    
                    this.logDebug('PeerArrayView','handleClientSetData','','triplets');
                    
                    % Range(s) specified (value-range pairs)
                    for i=1:3:length(triplets)
                        % Check for empty value passed from user and replace
                        % with valid "empty" value
                        if isempty(triplets{i})
                            triplets{i} = this.getEmptyValueReplacement(row,column);
                        else
                            [result] = evalin(this.DataModel.Workspace, triplets{i}); % Test for a valid expression.
                            if ~this.validateInput(result,row,column)
                                error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                            end
                        end
                    end
                    varargout{1} = this.setData(triplets{:});
                else
                    error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                end
            catch e
                % Send data change event.
                this.sendPeerEvent('dataChangeStatus', 'status', 'error', 'message', e.message, 'row', row-1, 'column', column-1);
                varargout{1} = '';
            end
            
        end
        
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
            this.EndColumn = min(s(2), endColumn);
            
            if doUpdate
                this.updateCurrentPageModels();
            end
        end
        
        function [startRow, endRow, startColumn, endColumn] = getCurrentPage(this)
            startRow = this.StartRow;
            endRow = this.EndRow;
            startColumn = this.StartColumn;
            endColumn = this.EndColumn;
            if ~isempty(this.PagedDataHandler)
                gridNode = this.PagedDataHandler.getGridNode;
                if ~isempty(gridNode)
                    dataModel = gridNode.getProperty('dataModel');
                    if ~isempty(dataModel)
                        startRow = dataModel.getCurrentStartRow+1;
                        endRow = dataModel.getCurrentEndRow+1;
                        startColumn = dataModel.getCurrentStartCol+1;
                        endColumn = dataModel.getCurrentEndCol+1;
                        
                        % Constrain to the bounds of the data
                        s = this.getSize();
                        startRow = max(1, startRow);
                        endRow = min(s(1), endRow);
                        startColumn = max(1, startColumn);
                        endColumn = min(s(2), endColumn);
                    end
                end
            end
            
            this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);
        end
        
        function handleCellModelUpdate(this, ~, ~)
            this.logDebug('PeerArrayView','handleCellModelUpdate','');
            
            this.updateCellModelInformation(this.StartRow, this.EndRow, this.StartColumn, this.EndColumn);
        end
        
        function handleTableModelUpdate(this, ~, ~)
            this.logDebug('PeerArrayView','handleTableModelUpdate','');
            
            this.updateTableModelInformation();
        end
        
        function handleRowModelUpdate(this, ~, ed)
            this.logDebug('PeerArrayView','handleRowModelUpdate','');
            
            [startRow, endRow, ~, ~] = this.getCurrentPage();
            if any(ed.Row >= startRow) && any(ed.Row <= endRow)
                this.updateRowModelInformation(startRow, endRow);
            else
                this.logDebug('PeerArrayView','handleRowModelUpdate','Updating Row Out of Current Page', 'Row', ed.Row, 'Start Row', this.StartRow, 'End Row', this.EndRow);
            end
        end
        
        function handleColumnModelUpdate(this, ~, ed)
            this.logDebug('PeerArrayView','handleColumnModelUpdate','');
            
            [~, ~, startColumn, endColumn] = this.getCurrentPage();
            if any(ed.Column >= startColumn) && any(ed.Column <= endColumn)
                this.updateColumnModelInformation(startColumn, endColumn);
            else
                this.logDebug('PeerArrayView','handleColumnModelUpdate','Updating Column Out of Current Page', 'Column', ed.Column, 'Start Column', this.StartColumn, 'End Column', this.EndColumn);
            end
        end
        
        function updateCurrentPageModels(this)
            this.logDebug('PeerArrayView','updateCurrentPageModels','');
            
            this.updateCellModelInformation(this.StartRow, this.EndRow, this.StartColumn, this.EndColumn);
            this.updateTableModelInformation();
            this.updateRowModelInformation(this.StartRow, this.EndRow);
            this.updateColumnModelInformation(this.StartColumn, this.EndColumn);
        end
        
        function updateCellModelInformation(this, startRow, endRow, startColumn, endColumn)
            this.logDebug('PeerArrayView','updateCellModelInformation','','startRow',startRow,'endRow',endRow,'startColumn',startColumn,'endColumn',endColumn);
            
            cellProps = this.CellModelProperties;
            sRow = max(1,startRow);
            eRow = min(size(cellProps, 1),endRow);
            sCol = max(1,startColumn);
            eCol = min(size(cellProps, 2),endColumn);
            
            rmpca = cell(1,eRow-sRow+1);
            if ~isempty(cellProps)
                if eCol > size(cellProps, 2) || eRow > size(cellProps, 1)
                    this.CellModelProperties{eRow, eCol} = struct();
                end
                for r=sRow:eRow
                    cmpca = cell(1,eCol-sCol+1);
                    for c=sCol:eCol
                        map = cellProps{r,c};
                        if ~isstruct(map)
                            map = struct();
                        end
                        map.RowNumber = r;
                        map.ColumnNumber = c;
                        cmpca{c-sCol+1} = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, map);
                    end
                    
                    rmpca{r-sRow+1} = '[';
                    if ~isempty(cmpca)
                        rmpca{r-sRow+1} = [rmpca{r-sRow+1} strjoin(cmpca,',')];
                    end
                    rmpca{r-sRow+1} = [rmpca{r-sRow+1} ']'];
                    
                end
            end
            
            cellModelProps = '[';
            if ~isempty(rmpca)
                cellModelProps = [cellModelProps strjoin(rmpca,',')];
            end
            cellModelProps = [cellModelProps ']'];
            this.setProperty('CellModelProperties', cellModelProps);
        end
        
        function updateTableModelInformation(this)
            this.logDebug('PeerArrayView','updateTableModelInformation','');
            
            tableModelProps = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, this.TableModelProperties);
            this.setProperty('TableModelProperties', tableModelProps);
        end
        
        function updateRowModelInformation(this, startRow, endRow)
            this.logDebug('PeerArrayView','updateRowModelInformation','','startRow',startRow,'endRow',endRow);
            
            rmpa = this.RowModelProperties;
            sRow = max(1,startRow);
            eRow = min(length(rmpa),endRow);
            rmpca = cell(1,eRow-sRow+1);
            if ~isempty(rmpa)
                for i=sRow:eRow
                    map = rmpa{i};
                    if ~isstruct(map)
                        map = struct();
                    end
                    map.RowNumber = i;
                    rmpca{i-sRow+1} = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, map);
                end
            end
            rowModelProps = '[';
            if ~isempty(rmpca)
                rowModelProps = [rowModelProps strjoin(rmpca,',')];
            end
            rowModelProps = [rowModelProps ']'];
            this.setProperty('RowModelProperties', rowModelProps);
        end
        
        function updateColumnModelInformation(this, startColumn, endColumn)
            this.logDebug('PeerArrayView','updateColumnModelInformation','','startColumn',startColumn,'endColumn',endColumn);
            
            cmpa = this.ColumnModelProperties;
            sCol = max(1,startColumn);
            eCol = min(length(cmpa),endColumn);
            cmpca = cell(1,eCol-sCol+1);
            if ~isempty(cmpa)
                for i=sCol:eCol
                    map = cmpa{i};
                    if ~isstruct(map)
                        map = struct();
                    end
                    map.ColumnNumber = i;
                    cmpca{i-sCol+1} = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, map);
                end
            end
            columnModelProps = '[';
            if ~isempty(cmpca)
                columnModelProps = [columnModelProps strjoin(cmpca,',')];
            end
            columnModelProps = [columnModelProps ']'];
            this.setProperty('ColumnModelProperties', columnModelProps);
        end
        
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getRenderedData@internal.matlab.variableeditor.ArrayViewModel(startRow,endRow,startColumn,endColumn);
            renderedData = cell(size(data));
            this.setCurrentPage(startRow, endRow, startColumn, endColumn, false);
            
            rowStrs = strtrim(cellstr(num2str((startRow-1:endRow-1)'))');
            colStrs = strtrim(cellstr(num2str((startColumn-1:endColumn-1)'))');
            
            for row=1:min(size(renderedData,1),size(data,1))
                for col=1:min(size(renderedData,2),size(data,2))
                    jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, 'value',data{row,col},...
                        'editValue',data{row,col},'row',rowStrs{row},'col',colStrs{col});
                    
                    renderedData{row,col} = jsonData;
                end
            end
            renderedDims = size(renderedData);
        end
        
        function addClassesToTable(this, newClassList)
            existingClasses = this.getTableModelProperty('classList');
            
            % ensure existingClasses is a cell array of class names
            existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
            
            updatedClassList = this.prepareNewClassList(existingClasses,...
                newClassList, 'add');
            
            % check isequal to save firing unnecessary events
            if ~isempty(updatedClassList) && ...
                    (~isequal(existingClasses, updatedClassList))
                this.setTableModelProperty('classList', updatedClassList);
            end
        end
        
        function removeClassesFromTable(this, classListToRemove)
            existingClasses = this.getTableModelProperty('classList');
            existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
            
            updatedClassList = this.prepareNewClassList(existingClasses,...
                classListToRemove, 'remove');
            
            % if lists are not equal, classes should be updated
            if (~isequal(existingClasses, updatedClassList))
                this.setTableModelProperty('classList', updatedClassList);
            end
        end
        
        function addClassesToRow(this, row, newClassList)
            for r = row
                existingClasses = this.getRowModelProperty(r, 'classList');
                existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                
                updatedClassList = this.prepareNewClassList(existingClasses,...
                    newClassList, 'add');
                
                % checking isequal to save firing unnecessary events
                if ~isempty(updatedClassList) && ...
                        (~isequal(existingClasses, updatedClassList))
                    this.setRowModelProperty(r, 'classList', updatedClassList);
                end
            end
        end
        
        function removeClassesFromRow(this, row, classListToRemove)
            for r = row
                existingClasses = this.getRowModelProperty(r, 'classList');
                existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                
                updatedClassList = this.prepareNewClassList(existingClasses,...
                    classListToRemove, 'remove');
                
                if (~isequal(existingClasses, updatedClassList))
                    this.setRowModelProperty(r, 'classList', updatedClassList);
                end
            end
        end
        
        function addClassesToColumn(this, column, newClassList)
            for c = column
                existingClasses = this.getColumnModelProperty(c, 'classList');
                existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                
                updatedClassList = this.prepareNewClassList(existingClasses,...
                    newClassList, 'add');
                
                if ~isempty(updatedClassList) && ...
                        (~isequal(existingClasses, updatedClassList))
                    this.setColumnModelProperty(c, 'classList', updatedClassList);
                end
            end
        end
        
        function removeClassesFromColumn(this, column, classListToRemove)
            for c = column
                existingClasses = this.getColumnModelProperty(c, 'classList');
                existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                
                updatedClassList = this.prepareNewClassList(existingClasses,...
                    classListToRemove, 'remove');
                
                if (~isequal(existingClasses, updatedClassList))
                    this.setColumnModelProperty(c, 'classList', updatedClassList);
                end
            end
        end
        
        function addClassesToCell(this, row, column, newClassList)
            for r = row
                for c = column
                    existingClasses = this.getCellModelProperty(r, c, 'classList');
                    existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                    
                    updatedClassList = this.prepareNewClassList(existingClasses,...
                        newClassList, 'add');
                    
                    if ~isempty(updatedClassList) &&...
                            (~isequal(existingClasses, updatedClassList))
                        
                        this.setCellModelProperty(r, c, 'classList',...
                            updatedClassList);
                    end
                end
            end
        end
        
        function removeClassesFromCell(this, row, column, classListToRemove)
            for r = row
                for c = column
                    existingClasses = this.getCellModelProperty(r, c,...
                        'classList');
                    existingClasses = this.wrapClassListAsOneLayeredCellArray(existingClasses);
                    
                    updatedClassList = this.prepareNewClassList(existingClasses,...
                        classListToRemove, 'remove');
                    
                    if (~isequal(existingClasses, updatedClassList))
                        this.setCellModelProperty(r, c, 'classList',...
                            updatedClassList);
                    end
                end
            end
        end
        
    end
    
    methods(Access='protected')
        function updatedClassList = prepareNewClassList(~,...
                oldClassList, newClassList, action)
            if strcmp(action, 'add')
                % avoid duplicates, but maintain the order
                updatedClassList = unique([oldClassList...
                    newClassList], 'stable');
            elseif strcmp(action, 'remove')
                updatedClassList = oldClassList(~ismember(oldClassList,...
                    newClassList));
            else
                error('This method only allows add or remove actions');
            end
            
            % remove empty class names like {'' 'a' 'b'} => {'a' 'b'}
            updatedClassList(cellfun('isempty', updatedClassList)) = [];
        end
        
        % Note: we need this because getTable/Row/Column/CellModelProperty
        % returns different output type including a cell array, or a cell
        % within a cell array, or an empty numeric array
        function classList = wrapClassListAsOneLayeredCellArray(~, classList)
            if ~iscell(classList)
                if isnumeric(classList)
                    if isempty(classList)   % []
                        classList = {};
                    end
                else    % '' or 'a'
                    classList = {classList};
                end
            elseif iscell(classList)
                % for empty cell and 1x0 empty cell
                if isequal(size(classList), [1 0]) || isempty(classList)
                    classList = {};
                elseif iscell(classList{1})
                    % for cell in a cell array: {{'a'}}
                    classList = classList{1};
                end
            end
        end
        
        function [renderedData, renderedDims] = refresh(this, eventSource, eventData)
            this.logDebug('PeerArrayView','refresh','');
            
            % Refreshes the data block passed in, and updates the client
            this.refresh@internal.matlab.variableeditor.ArrayViewModel(...
                eventSource, eventData);
            
            if size(eventData.Range, 2) == 1
                % Refresh data for single cell
                dataBounds = struct('startRow', eventData.Range(1,1)-1, ...
                    'endRow', eventData.Range(1,1)-1, ...
                    'startColumn', eventData.Range(2,1)-1, ...
                    'endColumn',eventData.Range(2,1)-1);
            else
                % Refresh data for the current block
                dataBounds = struct('startRow', this.StartRow-1, ...
                    'endRow', this.EndRow-1, ...
                    'startColumn', this.StartColumn-1, ...
                    'endColumn', this.EndColumn-1);
            end
            [renderedData, renderedDims] = this.refreshRenderedData(dataBounds);
            
            if eventData.DimensionsChanged
                this.setSelection([], []);
                this.sendPeerEvent('dimensionsChanged', 'column', '');
            end
        end
        
        % Specialized validation function to be optionally overridden in
        % subclasses
        function isValid = validateInput(this,value,row,column)
            this.logDebug('PeerArrayView','isValid','','value',value,'row',row,'column',column);
            
            isValid = true;
        end
        
        % Evaluates the expression entered by the  user. This is required for cases
        % like 'pi' where the cell data should evaluate to '3.1416'
        % Arguments are (this, data, row, column)
        function result = evaluateClientSetData(~, ~, ~, ~)
            result = [];
        end
        
        % Defining getClassType to be optionally overridden in subclasses
        % Arguments are (this, row, column)
        function classType = getClassType(~, ~, ~)
            classType='';
        end
        
        % Specialized empty value function to be optionally overridden in
        % subclasses
        function replacementValue = getEmptyValueReplacement(this,row,column)
            this.logDebug('PeerArrayView','getEmptyValueReplacement','','row',row,'column',column);
            
            replacementValue = [];
        end
        
        % Check if the values are the same (using isequaln, but also
        % compare if one is a string and the user entered value is a char,
        % since it will convert to string in some assignments)
        function b = didValuesChange(~, eValue, currentValue)
            b = true;
            try
                % If the values aren't equal, but one is "test" and the
                % user entered value is 'test', these will be considered
                % equal since 'test' will convert to string when assigned.
                b = ~isequaln(eValue, currentValue) && ...
                    ~(isstring(currentValue) && ~isempty(eValue) && ...
                    ~isstring(eValue) && isequaln(eval(eValue), currentValue));
            catch
            end
        end
        
        % Sets the default column widths for all columns of data
        function setDefaultColumnWidths(this, data, colWidth)
            startColumn = 1;
            endColumn = size(data, 2);
            for col = startColumn:endColumn
                this.setColumnModelProperty(col, 'ColumnWidth', ...
                    colWidth, false);
            end
            this.updateColumnModelInformation(startColumn, endColumn)
        end
        
        function msgOnError = getMsgOnError(this, row, column, msg)
            % Constructs an function that can be called on error when the
            % eval of the command is done from java, but fails.  The error
            % message will be constructed using the status returned from
            % the set properties call.  For example, if you try to do
            % something like:  set(lineObj, 'Marker', pi), it will return
            % an error message with the valid values for Marker, which will
            % be displayed to the user.
            idx = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.documentIndex(this.DataModel.Name,...
                this.DataModel.Workspace);
            
            msgOnError = ['internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.Documents(' ...
                num2str(idx) ').ViewModel.sendPeerEvent(''' msg ''', ''status'', ''error'', ''message'', ' ...
                '''%1$s'', ' ...
                '''row'', ' ...
                num2str(row - 1) ', ''column'', ' ...
                num2str(column - 1) ' );'];
        end
        
        function out = executeCommandInWorkspace(this, data, row, column)
            msgOnError = this.getMsgOnError(row, column, 'dataChangeStatus');
            out = this.setData(data, row, column, msgOnError);
        end
    end
    
    % public utils
    methods
        % Disable cell update and resume it somewhere later
        function oldStatus = disableCellModelUpdate(this)
            % return original update status for save and resume.
            oldStatus = this.CellModelChangeListener.Enabled;
            
            this.CellModelChangeListener.Enabled = false;
        end
        
        % resume cell update
        function resumeCellModelUpdate(this, status, forceUpdate)
            if nargin < 3
                forceUpdate = false;
            end
            
            if forceUpdate
                this.CellModelChangeListener.Enabled = true;
            else
                this.CellModelChangeListener.Enabled = status;
            end
        end  
        
        % Disable column update and resume it somewhere later
        function oldStatus = disableColumnModelUpdate(this)
            % return original update status for save and resume.
            oldStatus = this.ColumnModelChangeListener.Enabled;
            
            this.ColumnModelChangeListener.Enabled = false;
        end
        
        % resume column update
        function resumeColumnModelUpdate(this, status, forceUpdate)
            if nargin < 3
                forceUpdate = false;
            end
            
            if forceUpdate
                this.ColumnModelChangeListener.Enabled = true;
            else
                this.ColumnModelChangeListener.Enabled = status;
            end
        end        
    end
end
