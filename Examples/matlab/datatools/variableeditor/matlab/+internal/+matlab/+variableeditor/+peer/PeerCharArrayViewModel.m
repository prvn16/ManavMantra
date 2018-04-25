
classdef PeerCharArrayViewModel < ...
        internal.matlab.variableeditor.peer.PeerArrayViewModel & ...
        internal.matlab.variableeditor.CharArrayViewModel
    % PeerCharArrayViewModel Peer Model View Model for char array
    % variables
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Constant, GetAccess=protected)
        widgets = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance().getWidgets('', 'char');
    end

    methods
        function this = PeerCharArrayViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerArrayViewModel(parentNode, variable);            
            this@internal.matlab.variableeditor.CharArrayViewModel(variable.DataModel);           
            
            % Build the ArrayEditorHandler for the new Document
            import com.mathworks.datatools.variableeditor.web.*;
            this.PagedDataHandler = ArrayEditorHandler(variable.Name,this.PeerNode.Peer,this,this.getRenderedData(1,1,1,1));

            % Set the renderer types on the table
            this.setTableModelProperties(...
                'renderer', internal.matlab.variableeditor.peer.PeerCharArrayViewModel.widgets.CellRenderer,...
                'editor', internal.matlab.variableeditor.peer.PeerCharArrayViewModel.widgets.Editor,...
                'inplaceeditor', internal.matlab.variableeditor.peer.PeerCharArrayViewModel.widgets.InPlaceEditor,...
                'ShowColumnHeaderLabels', false,...
                'ShowRowHeaderLabels', false,...
                'RemoveQuotedStrings',false);
        end
    end
    
    methods(Access='public')
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            % dataSize denotes the actual char array size where each
			% character occupies one column.
			% Eg: s = 'hello_world'
			% dataSize = [1 11]
            dataSize = this.DataModel.getSize();
            data = this.getRenderedData@internal.matlab.variableeditor.CharArrayViewModel(startRow,dataSize(1),startColumn,dataSize(2));
            this.setCurrentPage(1,1,1, 1, false);

			if isempty(data)
				data = '';
            end
            isMetaData = dataSize(2) > internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH;
			jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, ...
                struct('class', 'char', ...
                'value', data,...
                'editValue', data, ...
                'isMetaData', isMetaData, ...
                'row', '0', ...
                'col', '0'));
            renderedData{1,1} = jsonData;

            renderedDims = size(renderedData);
        end
        
		% overidden method
		% handles data changes when the user edits the cell
		% char arrays handle a special 0x0 array view when data is empty
        function varargout = handleClientSetData(this, varargin)
            % Handles setData from the client and calls MCOS setData.  Also
            % fires a dataChangeStatus peerEvent.
            data = '';
            if ~isempty(varargin{1})
                data = this.getStructValue(varargin{1}, 'data');
            end
            
            try
                if isequal(data, '''') || isequal(data, '"')
                    dispValue = '';
                else
                    data = strrep(data,'''','''''');
                    if ~isempty(data)
                        % The user is not expected to explicitly type
                        % quotes while entering char data in the VE
                        data = ['''' data ''''];
                        this.logDebug('PeerArrayView','handleClientSetData','','row',1,'column',1,'data',data);
                        dispValue = this.getStructValue(varargin{1}, 'data');
                    else
                        % when data is empty, the web worker(in java) needs
                        % to translate it as valid empty data. The
                        % dispValue and data thus need to be padded with
                        % additional quotes. resultant dispValue = ''''
                        dispValue = '''''''''';
                        
                        % resultant data = ''
                        data = '''''';
                    end
                end
                currentValue = this.getData(1, 1, 1, this.getStructValue(varargin{1}, 'column'));
                
                if isequaln(dispValue, currentValue)
                    this.sendPeerEvent('dataChangeStatus','status', 'noChange', 'dispValue', dispValue, 'row', 0, 'column', 0);
                else
                    this.sendPeerEvent('dataChangeStatus','status', 'success', 'dispValue', dispValue, 'row', 0, 'column', 0);
                end
                
                varargout{1} = this.executeCommandInWorkspace(data, 0, 0);
            catch e
                % Send data change event.
                this.sendPeerEvent('dataChangeStatus', 'status', 'error', 'message', e.message, 'row', 0, 'column', 0);
                varargout{1} = '';
            end
        end
    end
end