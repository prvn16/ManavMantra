classdef PeerObjectArrayViewModel < ...
        internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.ObjectArrayViewModel
    % PeerObjectArrayViewModel Peer Model Object Array View Model.  This
    % extends the ObjectArrayViewModel to provide the functionality for
    % display of object arrays and NxM struct arrays in Matlab Online.
    %
    % Copyright 2015 The MathWorks, Inc.
    
    methods
        function this = PeerObjectArrayViewModel(parentNode, variable)
            % Creates a new PeerObjectArrayViewModel for the given
            % variable, using the specified parentNode.
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(...
                parentNode, variable);
            this@internal.matlab.variableeditor.ObjectArrayViewModel(...
                variable.DataModel);
            
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            this.PagedDataHandler = ArrayEditorHandler(...
                variable.Name, this.PeerNode.Peer, this);
            
            % Setup some table model properties (renderer and inplaceeditor
            % don't change for object arrays, so its more efficient to set
            % them here)
            widgets = ...
                internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('', 'cell');
            this.setTableModelProperties('ShowColumnHeaderLabels', false);
            this.setTableModelProperties('renderer', ...
                widgets.CellRenderer);
            this.setTableModelProperties('inplaceeditor', ...
                widgets.InPlaceEditor);
        end
        
        function [renderedData, renderedDims] = getRenderedData(this, ...
                startRow, endRow, startColumn, endColumn)
            % Returns the rendered data for the specified range of
            % startRow/endRow, startColumn/endColumn.
            data = this.getRenderedData@internal.matlab.variableeditor.ObjectArrayViewModel(...
                startRow, endRow, startColumn, endColumn);
            rawData = this.DataModel.Data;
            
            % Determine the starting and ending rows and columns, based on
            % the size of the data
            sRow = max(1,startRow);
            eRow = min(size(rawData,1),endRow);
            sCol = max(startColumn,1);
            eCol = min(endColumn,size(rawData,2));
            
            rowStrs = strtrim(cellstr(num2str((sRow-1:eRow-1)'))');
            colStrs = strtrim(cellstr(num2str((sCol-1:eCol-1)'))');

            % Populate the renderedData cell array with the data determined
            % from the ObjectArrayViewModel, as well as the row/column
            % numbers 
            renderedData = cell(size(data));
            colStrsIndex = 1;
            for col = 1:size(renderedData,2)
                colStr = colStrs{col};
                rowStrsIndex = 1;
                for row = 1:size(renderedData,1)
                    rowStr = rowStrs{row};
                    
                    % Setup the editor value (something like
                    % varName(row,column))
                    editorValue = sprintf('%s(%d,%d)', ...
                        this.DataModel.Name, row + sRow - 1, ...
                        col + sCol - 1);
                    longData = data{row,col};
                    
                    % Get the JSON data for the cell
                    renderedData{row,col} = this.getJSONforCell(...
                        data{row,col}, longData,...
                        true, editorValue, rowStr, colStr);
                    rowStrsIndex = rowStrsIndex + 1;
                end
                colStrsIndex = colStrsIndex + 1;
            end
            renderedDims = size(renderedData);
        end
        
        function varargout = handleClientSetData(this, varargin)
            % Overrides the PeerArrayViewModel handleClientSetData in order
            % to prevent empty values from being applied - this is the only
            % difference.  (PeerArrayViewModel has the ability to validate
            % input, but not empty input).  We are unable to override it
            % and call the super method because of dependencies on being
            % able to evalin('caller'..., which by adding a function in
            % between causes problems.
            data = this.getStructValue(varargin{1}, 'data');
            if isempty(data)
                % Cannot have empty data in object arrays
                row = this.getStructValue(varargin{1}, 'row');
                column = this.getStructValue(varargin{1}, 'column');
                m = message(...
                    'MATLAB:codetools:variableeditor:EmptyValueInvalid');
                this.sendPeerEvent('dataChangeStatus', 'status', ...
                    'error', 'message', m.getString, 'row', row-1, ...
                    'column', column-1);
                varargout{1} = '';
                return;
            end
            
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

                    this.logDebug('PeerObjectArrayView', ...
                        'handleClientSetData', '', ...
                        'row', row, 'column', column,' data', data);

                    removeQuotes = this.getCellPropertyValue(...
                        row, column, 'RemoveQuotedStrings');
                    if ~isempty(removeQuotes) && iscell(removeQuotes)
                        removeQuotes = removeQuotes{1};
                    end
                    if ~isempty(removeQuotes) && ~isempty(data) && ...
                            ((islogical(removeQuotes) && removeQuotes==true) ...
                            || strcmp(removeQuotes, 'true') || ...
                            strcmp(removeQuotes, 'on'))
                        data = strrep(data, '''', '''''');
                        data = ['''' data ''''];
                    end

                    % Check for empty value passed from user and replace
                    % with valid "empty" value
                    if isempty(data)
                        data = this.getEmptyValueReplacement(row, column);
                        if ~ischar(data)
                            data = mat2str(data);
                        end
                    else
                        % TODO: Code below does not test for expressions in
                        % terms of variables in the current workspace (e.g.
                        % "x(2)") and it allows expression in terms of
                        % local variables in this workspace. We need a
                        % better method for testing validity. LXE may
                        % provide this capability.
                        if ~ischar(data)
                            data = mat2str(data);
                        end
                        % Test for a valid expression.
                        [result] = evalin(this.DataModel.Workspace, data); 
                        if ~this.validateInput(result, row, column)
                            error(message('MATLAB:codetools:variableeditor:InvalidInputType'));
                        end
                    end

                    % Send data change event for equal data
                    eValue = evalin(this.DataModel.Workspace, data);
                    if ~ischar(eValue)
                        if ~ischar(this.DataModel.Workspace) && ...
                                ismethod(this.DataModel.Workspace, 'disp')
                            try
                                dispValue = this.DataModel.Workspace.disp(...
                                    data);
                            catch
                                dispValue = strtrim(evalc(...
                                    'evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
                            end
                        else
                            dispValue = strtrim(evalc(...
                                'evalin(this.DataModel.Workspace, [''disp('' data '')''])'));
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
                    
                    if isequaln(eValue, currentValue)
                        this.sendPeerEvent('dataChangeStatus', ...
                            'status', 'noChange', ...
                            'dispValue', dispValue, ...
                            'row', row-1, 'column', column-1);
                        
                        % Even though the data has not changed we will fire
                        % a data changed event to take care of the case
                        % that the user has typed in a value that was to be
                        % evaluated in order to clear the expression and
                        % replace it with the value (e.g. pi with 3.1416)
                        eventdata = internal.matlab.variableeditor.DataChangeEventData;
                        eventdata.Range = [row, column];
                        eventdata.Values = this.getRenderedData(...
                            row, row, column, column);
                        if ~isempty(eventdata.Values)
                            eventdata.Values = eventdata.Values{1, 1};
                        end
                        this.notify('DataChange', eventdata);
                    end
                    varargout{1} = this.executeCommandInWorkspace(...
                        data, row, column);
                    this.sendPeerEvent('dataChangeStatus', ...
                        'status', 'success', 'dispValue', dispValue, ...
                        'row', row - 1, 'column', column - 1);
                else
                    error(message('MATLAB:codetools:variableeditor:UseNameRowColTriplets'));
                end
            catch e
                % Send data change event.
                this.sendPeerEvent('dataChangeStatus', 'status', 'error', ...
                    'message', e.message, 'row', row - 1, ...
                    'column', column - 1);
            end
        end
    end
    
    methods(Access = protected)        
        function classType = getClassType(this, row, column) %#ok<INUSL>
            % Called to return the class type
            classType = eval(sprintf('class(this.DataModel.Data(%d,%d))', ...
                row, column));
        end
        
        function isValid = validateInput(this, value, row, column)
            % Called to validate the input for the specified row/column.
            % Attempt to make the assignment.  If it errors, the error will
            % be displayed as an error message in the Variable Editor.
            this.DataModel.Data(row,column) = value;
            isValid = true;
        end
    end
end
