classdef PeerObjectViewModel < internal.matlab.variableeditor.peer.PeerStructureViewModel & ...
        internal.matlab.variableeditor.ObjectViewModel
    % PEEROBJECTVIEWMODEL Peer Object View Model
    
    % Copyright 2014-2016 The MathWorks, Inc.   
   
    methods
        function this = PeerObjectViewModel(parentNode, variable, ...
                propertyColumnName, valueColumnName)
            % Creates a new PeerObjectViewModel
            if nargin<3 || isempty(propertyColumnName)
               propertyColumnName = 'Property';
            end
            if nargin<4 || isempty(valueColumnName)
                valueColumnName = 'Value';
            end
            
            this@internal.matlab.variableeditor.ObjectViewModel(variable.DataModel);
            this = this@internal.matlab.variableeditor.peer.PeerStructureViewModel(...
                parentNode, variable, propertyColumnName, valueColumnName);
            
            % Setting columnWidth of first column of Objects alone to a higher value.
            this.setColumnModelProperty(1, 'ColumnWidth', this.defaultColumnWidth);
        end
    end
    
    methods (Access = public)
        function [renderedData, renderedDims] = getRenderedData(this, ...
                startRow, endRow, startColumn, endColumn)
            % Get the rendered data from the ObjectViewModel, and reformat
            % it for display in JS.
            data = this.getRenderedData@internal.matlab.variableeditor.ObjectViewModel(...
                startRow, endRow, startColumn, endColumn);
            
            [renderedData, renderedDims] = this.renderData(data, startRow, endRow, ...
                startColumn, endColumn);
        end
        
        function editable = isEditable(this, row, col)
            % Return whether the cell specified by row, col is editable.
            editable = this.isEditable@internal.matlab.variableeditor.ObjectViewModel(...
                row,col);
        end
        
        function varargout = handleClientSetData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
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
                    
                    this.logDebug('PeerObjectView','handleClientSetData','','row',row,'column',column,'data',data);
                    
                    removeQuotes = this.getCellModelProperty(row, column, 'RemoveQuotedStrings');
                    if ~isempty(removeQuotes) && ~isempty(data) && (removeQuotes==true || strcmp(removeQuotes,'true') || strcmp(removeQuotes,'on'))
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
                            data = mat2str(data);
                        end
                        [result] = evalin(this.DataModel.Workspace, data); % Test for a valid expression.
                        if ~this.validateInput(result,row,column)
                            error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                        end
                    end
                    
                    % Eval the data in the workspace
                    eValue = evalin(this.DataModel.Workspace, data);
                    if ~ischar(eValue)
                        dispValue = strtrim(evalc('evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
                    else
                        dispValue = data;
                    end
                    
                    currentValue = this.getData(row, row, column, column);
                    if iscell(currentValue)
                        currentValue = currentValue{:};
                    end
                    if isequaln(eValue, currentValue)
                        this.sendPeerEvent('dataChangeStatus', 'status', ...
                            'noChange', 'dispValue', dispValue, ...
                            'row', row-1, 'column', column-1);
                        
                        % Even though the data has not changed we will fire
                        % a data changed event to take care of the case
                        % that the user has typed in a value that was to be
                        % evaluated in order to clear the expression and
                        % replace it with the value (e.g. pi with 3.1416)
                        eventdata = internal.matlab.variableeditor.DataChangeEventData;
                        eventdata.Range = [row, column];
                        eventdata.Values = this.getRenderedData(row, row, ...
                            column, column);
                        if ~isempty(eventdata.Values)
                            eventdata.Values = eventdata.Values{1,1};
                        end
                        this.notify('DataChange',eventdata);
                    end

                    varargout{1} = this.executeCommandInWorkspace(data, row, column);
                    this.sendPeerEvent('dataChangeStatus','status', 'success', 'dispValue', dispValue, 'row', row-1, 'column', column-1);
                else
                    error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                end
            catch e
                % Send data change event.
                this.sendPeerEvent('dataChangeStatus', 'status', 'error', 'message', e.message, 'row', row-1, 'column', column-1);
                varargout{1} = '';
            end
        end
    end
    
    methods (Access = protected)
        function [cellEditor, cellInPlaceEditor] = getEditors(this, data, ...
                row, editor, inPlaceEditor)
            % Returns the editors to use for the cell.  If the property
            % value doesn't have setAccess = public, it should be displayed
            % as read-only on the client.  (This is done by having no
            % editor for the cell).
            cellEditor = editor;
            if ~this.setAccessPublic(data{row, 1})
                cellInPlaceEditor = '';
            else
                cellInPlaceEditor = inPlaceEditor;
            end
        end
    end
end
