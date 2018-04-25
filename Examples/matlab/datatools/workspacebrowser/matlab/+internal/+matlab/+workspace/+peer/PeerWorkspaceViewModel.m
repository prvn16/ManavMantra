classdef PeerWorkspaceViewModel < internal.matlab.variableeditor.peer.PeerStructureViewModel
    %PeerWorkspaceViewModel Peer Model Table View Model for scalar structures
    
    % Copyright 2013-2016 The MathWorks, Inc.
    properties(SetObservable=false, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=true)
        VariablesAddedListener;
        VariablesRemovedListener;
        VariablesChangedListener;
    end
    
    properties(Access = private)
        % Save the evaluated value when changing the data.  This is used in
        % places where superclasses may try to do an evalin 'caller',
        % expecting caller to be the user's workspace.
        evaluatedSetValue;
    end
    
    methods
        function this = PeerWorkspaceViewModel(parentNode, variable)
            this = this@internal.matlab.variableeditor.peer.PeerStructureViewModel(parentNode, variable, ...
                            'Name', 'Value');            
            this.PagedDataHandler.setMatlabTimeout(60*1000); % 1 minute
            this.setTableModelProperty('Draggable', true); % Set Draggable as a table model property            
            % Turn off the rename feature until we have tests 
            this.setColumnModelProperty(1, 'inplaceeditor', '');
            % Set the doCommitEmptyMetaData to false in the WSB to avoid
            % accidental commits
            this.setTableModelProperty('doCommitEmptyMetaData', 'false');
            this.VariablesAddedListener = event.listener(variable.DataModel, 'VariablesAdded', @(es,ed)this.sendVariableEvent('VariablesAdded',ed.Variables));
            this.VariablesRemovedListener = event.listener(variable.DataModel, 'VariablesRemoved', @(es,ed)this.sendVariableEvent('VariablesRemoved',ed.Variables));
            this.VariablesChangedListener = event.listener(variable.DataModel, 'VariablesChanged', @(es,ed)this.sendVariableEvent('VariablesChanged',ed.Variables));
        end
        
        function sendVariableEvent(this, type, Variables)
            internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(this.PeerNode, type, 'Variables', Variables)
        end
        
        function subVarName = getSubVarName(~, ~, varName)
            % Generates the name string for a sub-variable expression
            subVarName = varName;
        end
        
        function varargout = handlePeerEvents(this, ~, ed)
            this.logDebug('PeerArrayView','handlePeerEvents','');
            varargout = {};
            if isfield(ed.EventData,'type')
                switch ed.EventData.type
                    case 'VariablesAdded'
                    case 'VariablesRemoved'
                    case 'VariablesChanged'
                    otherwise
                        this.handlePeerEvents@internal.matlab.variableeditor.peer.PeerStructureViewModel([], ed);
                end
            end
        end
        
        function varargout = handleClientSetData(this, varargin)
            data = this.getStructValue(varargin{1}, 'data');
            row = this.getStructValue(varargin{1}, 'row');
            column = this.getStructValue(varargin{1}, 'column');
            
            if ~isempty(row)
                if ischar(row)
                    row = str2double(row);
                end
            end
            
            if ~isempty(column)
                if ischar(column)
                    column = str2double(column);
                end
            end
            
            %Get the HeaderName of the column being modified
            fieldName = this.getColumnModelProperty(column, 'HeaderName');
            
            % If the Name field is being modified, execute rename logic
            if (strcmp(fieldName{1}, 'Name'))
                try
                    names = fieldnames(this.DataModel.Data);
                    
                    if ~this.SortAscending
                        names = names(end:-1:1);
                    end
                    
                    renameCmd = sprintf('%s=%s; builtin clear %s;', data, names{row}, names{row});
                    
                    evalin(this.DataModel.Workspace, renameCmd);
                catch e
                    this.sendPeerEvent('dataChangeStatus', 'status', 'error', 'message', e.message, 'row', row-1, 'column', column-1);
                end
                
                varargout{1} = [];
            else
                % Reset the evaluated value that may be used in the
                % handleClientSetData
                this.evaluatedSetValue = [];
                
                % Check to see if the value is being changed to text.  If
                % it is, it may a variable in the workspace, so we should
                % try to evaluate it here.
                hm = varargin{1};
                data = this.getStructValue(hm, 'data');
                if ~isempty(data) && ischar(data)
                    % Need to do the eval here, because the Workspace is
                    % potentially 'caller'.  And if we call into the
                    % PeerStructureViewModel to do the handleClientSetData,
                    % then 'caller' isn't the same as it is here.
                    try
                        result = evalin(this.DataModel.Workspace, data);
                        if ~isempty(result) && ~isequal(data, result) 
                            this.evaluatedSetValue = result;
                        end
                    catch
                    end
                end
                
                varargout{1} = ...
                    this.handleClientSetData@internal.matlab.variableeditor.peer.PeerStructureViewModel(hm);
            end
        end
    end
    
    methods(Access = protected)
        function [renderedData, renderedDims] = refresh(this, ~ ,ed)
            fn = fieldnames(this.DataModel.Data);
            % If refresh is called from a sort property set event, sort the
            % fieldnames.            
            if ~this.SortAscending                
                fn = fn(end:-1:1);                
            end
            % Set properties for all rows of the workspacebrowser. Trying
            % to set for a block here with this.EndRow will have stale
            % values as the actual gridEditorHandler update happens later.            
            startRow = 1;
            endRow = length(fn);
            this.CellModelChangeListener.Enabled = false;
            % Setting the CellModelProperty only in server, dispatch to client will
            % happen after the gridEditorHandler updates the startRow and endRow
            for i=startRow:endRow                
                this.setCellModelProperty(i, 1, 'DragValue', fn(i), false);
            end          
            this.CellModelChangeListener.Enabled = true;
            % Call refresh once the cellModelProperties are updated. 
            [renderedData, renderedDims] = this.refresh@internal.matlab.variableeditor.peer.PeerStructureViewModel([], ed);            
        end        
      
        function result = evaluateClientSetData(this, ~, ~, ~)
            % Return the previously evaluated value, because evalin
            % 'caller' from the superclasses won't be correct
            result = this.evaluatedSetValue;
        end
    end
end
