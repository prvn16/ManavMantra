classdef MLArrayDataModel < internal.matlab.variableeditor.ArrayDataModel & internal.matlab.variableeditor.NamedVariable & internal.matlab.variableeditor.MLNamedVariableObserver
    %MLARRAYDATAMODEL
    %   MATLAB Array Data Model

    % Copyright 2013-2017 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLNamedVariableObserver(name, workspace);
            this.Name = name;
        end
        
        % setData
        % Sets a block of values.
        % If only one paramter is specified that parameter is assumed to be
        % the data and all of the data is replaced by that value.
        % If three paramters are passed in the the first value is assumed
        % to be the data and the second is the row and third the column.
        % Otherwise users can specify value index pairings in the form
        % setData('value', index1, 'value2', index2, ...)
        %
        %  The return values from this method are the formatted command
        %  string to be executed to make the change in the variable.
        function varargout = setData(this,varargin)
            c = varargin;
            errorMsg = [];
			% The last argument we will be expecting is an error command that gets the current document
			% and send a dataChange error message back to the client. The errormessage should start 
			% with 'internal.matlab.variableeditor'. We strip this off because the ArrayDataModel
			% setData function does not need it and cannot handle the extra input argument
            if strfind(varargin{end}, 'internal.matlab.variableeditor') == 1
                errorMsg = c{end};
                c(end) = [];
            end
            setStrings = this.setData@internal.matlab.variableeditor.ArrayDataModel(c{:});

            % Evaluate any MATLAB changes (TODO: Remove when LXE is in)
            if ~isempty(setStrings)
                setCommands = cell(1,length(setStrings));
                for i=1:length(setStrings)
                    if ~isempty(errorMsg)
                        setCommands{i} = this.executeSetCommand(setStrings{i}, errorMsg);
                    else
                        setCommands{i} = this.executeSetCommand(setStrings{i});
                    end
                end
                varargout{1} = setCommands;
            end
        end
        
        % Executes a matlab command in the correct workspace when MATLAB is
        % available
        function evalStr = executeSetCommand(this, setCommand, varargin)
            evalStr = sprintf('%s%s',this.Name, setCommand);
            if ischar(this.Workspace)
                if ~com.mathworks.datatools.variableeditor.web.WebWorker.TESTING
					% If I have 3 input arguments and varargin{1} is not
					% empty, that will be our error command.
                    
                    c = internal.matlab.datatoolsservices.CodePublishingService.getInstance;
                    channel = ['VariableEditor/' this.Name];
                    if nargin == 3 && ~isempty(varargin{1})
                        c.publishCode(channel, evalStr, varargin{1});
                    else
                        c.publishCode(channel, evalStr);
                    end
                end
            else
                origData = this.Data;
                evalin(this.Workspace, evalStr);
                evalStr = '';
                this.Data = evalin(this.Workspace, this.Name);

                % Because the change is internal to a workspace a workspace
                % event may not fire, so we must trigger the update ourselves.
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                [I,J] = this.doCompare(origData);
                eventdata.Range = [I,J];
                 if size(I,1)==1 && size(J,1)==1
                    % If there is only one change, pass this back as the
                    % Values for the event data.
                     eventdata.Values = this.getData(I(1,1),I(1,1),J(1,1),J(1,1));
                 else
                    % Otherwise, pass back empty, which will trigger the
                    % client to refresh its view.
                    eventdata.Values = [];
                 end
                
                this.notify('DataChange',eventdata);
            end
        end
        
        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            origData = this.Data;
            dataEqual = this.equalityCheck(origData, newData);
            if ~dataEqual
                sizeEqual = isequal(this.getDataSize(origData),this.getDataSize(newData));
                
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                eventdata.DimensionsChanged = ~sizeEqual;
                if sizeEqual
                    % If the sizes are the same, call doCompare to find out
                    % which entries actually changed
                    [I,J] = this.doCompare(newData);
                else
                    % Otherwise, create an array the same size as newData
                    % using meshgrid, so the result is viewed as all of the
                    % data changed.
                    %
                    % Revisit: This may be too big to transfer to the
                    % client when the variable is large
                    % G1005445: using the max in order to handle the case
                    % for switching between scalar and non-scalar
                    [I,J] = meshgrid(1:max(size(origData,1),size(newData,1)),1:max(size(origData,2),size(newData,2)));
                end
                
                I = I(:)';
                J = J(:)';
                eventdata.Range = [I;J];
                
                % Set the new data
                this.Data = newData;
                
                % The eventData Values property should represent the data
                % that has changed within the cached this.Data block as it 
                % is rendered. Currently the cached data may be huge, so
                % for now don't attempt to represent it.
                 if ~isempty(I) && ~isempty(J) && size(I,1)==1 && size(J,1)==1 && sizeEqual
                    % If there is only one change, pass this back as the
                    % Values for the event data.
                     eventdata.Values = this.getData(I(1,1),I(1,1),J(1,1),J(1,1));
                 else
                    % Otherwise, pass back empty, which will trigger the
                    % client to refresh its view.
                    eventdata.Values = [];
                 end
                
                this.notify('DataChange',eventdata);
            end
            data = this.Data;
        end
        
        function data = variableChanged(this, varargin)
            % variableChanged() is called by the MLNamedVariableObserver
            % workspaceUpdated() method in response to workskpace updates from the
            % WebWorkspaceListener to track changes in the data. However,
            % this method will also be called when the class of the
            % variable changes, which causes the MLDocument
            % variableChanged() method to replace this MLArrayDataModel by
            % a new one to represent the new class. Detect this case and
            % return early to avoid calling updateData on this about to be
            % deleted MLArrayDataModel
            
            oldClass = this.getClassType;
            if nargin>=4 
                newClass = varargin{3};
            end
            
            % there are some datatypes which have the same class but have
            % different view (documentTypes). Ex: scalar structurea, 1xn or
            % nx1 structure arrays and mxn structure arrays. For this
            % reason we derive the class from the adapter
             if nargin>=4 && ~isa(this, 'internal.matlab.workspace.MLWorkspaceDataModel') 
                 manager = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager;
                 if ~isempty(manager) && ~isempty(manager.FocusedDocument)
                    newClass = manager.getVariableAdapterClassType(varargin{3}, varargin{2}, varargin{1});
                 end
             end 
            
            if nargin>=4 &&...
                    ... % If we are looking at string arrays don't do this check
                    ~(internal.matlab.variableeditor.FormatDataUtils.checkIsString(this.Data) && internal.matlab.variableeditor.FormatDataUtils.checkIsString(varargin{1})) &&...
                    (...
                        (... % The type has changed and we're not looking at objects
                            ~any(strcmp(newClass,oldClass)) && ...
                            ~(isobject(this.Data) && isobject(varargin{1}))...
                        ) ||...
                        (... % We've gone from a scalar to non-scalar or vice-versa
                            (~isscalar(this.Data) && isscalar(varargin{1})) ||...
                            (isscalar(this.Data) && ~isscalar(varargin{1}))...
                        )...
                    )
                data = [];
                return
            end
            data = this.updateData(varargin{:});
        end
        
        function dims = getDataSize(~, data)
            dims = size(data);
        end
        
        function eq = equalityCheck(~, oldData, newData)
            eq = internal.matlab.variableeditor.areVariablesEqual(oldData, newData);
        end
    end %methods
    
    methods(Access='protected',Abstract=true)
        [I,J]=doCompare(this, newData);
    end
end
