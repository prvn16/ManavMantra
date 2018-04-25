classdef MLWorkspaceDataModel < internal.matlab.variableeditor.MLStructureDataModel
    %MLWorkspaceDataModel
    %   MATLAB Workspace Data Model
    
    % Copyright 2013-2014 The MathWorks, Inc.

    events
        VariablesAdded;
        VariablesRemoved;
        VariablesChanged;
    end

    methods(Access='public')
        % Constructor
        function this = MLWorkspaceDataModel(Workspace)
            this@internal.matlab.variableeditor.MLStructureDataModel(...
                'who', Workspace);
        end

        % workspace data changed event from java
        function workspaceUpdated(this, varNames)
            naninfBreakpoint = this.disableNanInfBreakpoint();
            if nargin <= 1 || isempty(varNames)
                varNames = {};
            end
            varNames = string(varNames);
            
            if ~this.IgnoreUpdates
                 % This is called from java so we don't want to throw an
                 % exception back to java, we'll catch it and deal with it
                 % here
                errorMessages = {};
                try
                    newData = evalin(this.Workspace,this.Name);
                    
                    % Sorting the data alphabetically (case-insensitive)
                    %TODO: Make this an optional selection
                    [~, sortId] = sort(lower(newData));
                    newData = newData(sortId);
                    
                    % Convert the array of structure variables into one
                    % structure with variable names as the fields and the
                    % variable as the value
                    data = struct();
                    for i=1:length(newData)
                        try
                            data.(newData{i}) = evalin(this.Workspace, newData{i});
                        catch e
                          errorMessages{end+1} = e.message;
                        end
                    end
                    varSize = size(data);
                    varClass = class(data);

                    origData = this.Data;
                    fieldNames = fieldnames(origData);
                    newFieldNames = fieldnames(data);
                    addedVariables = setdiff(newFieldNames, fieldNames);
                    removedVariables = setdiff(fieldNames, newFieldNames);
                    sameFields = intersect(fieldNames, newFieldNames);
                    this.variableChanged(data, varSize, varClass);

                    if ~isempty(addedVariables)
                        wce = internal.matlab.workspace.WorkspaceChangeEventData;
                        wce.Variables = addedVariables;
                        this.notify('VariablesAdded', wce);
                    end
                    
                    if ~isempty(removedVariables)
                        wce = internal.matlab.workspace.WorkspaceChangeEventData;
                        wce.Variables = removedVariables;
                        this.notify('VariablesRemoved', wce);
                    end
                    
                    if ~isempty(sameFields)
                        diffValues =  sameFields(cellfun(@(x)~strcmp(...
                            [this.getSizeString(origData.(x)) ' ' class(origData.(x))], ...
                            [this.getSizeString(data.(x)) ' ' class(data.(x))]), ...
                            sameFields));
                        if ~isempty(diffValues)
                            wce = internal.matlab.workspace.WorkspaceChangeEventData;
                            wce.Variables = diffValues;
                            this.notify('VariablesChanged', wce);
                        end
                    end
                catch e
                    % We are probably evaluating in the wrong workspace!
                    errorMessages{end+1} = e.message;
                end
                if ~isempty(errorMessages)
                    if ~ischar(this.Workspace)
                        error(message('MATLAB:workspace:ErrorUpdatingPrivateWorkspaceVariableList', strjoin(errorMessages,'\n')));
                    else
                        error(strjoin(errorMessages,'\n'));
                    end
                end
            end

            this.reEnableNanInfBreakpoint(naninfBreakpoint);
        end

        % Executes a matlab command in the correct workspace when MATLAB is
        % available
        function evalStr = executeSetCommand(this, evalStr, varargin)
            if ischar(this.Workspace) && strcmpi(this.Workspace, 'caller')
                 if ~com.mathworks.datatools.variableeditor.web.WebWorker.TESTING
                    if nargin == 3 && ~isempty(varargin{1})
                        com.mathworks.datatools.variableeditor.web.WebWorker.executeCommandAndFormatError(evalStr, varargin{1});
                    else
                        com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(evalStr);
                    end
                end
            else
                evalin(this.Workspace, evalStr);
                try
                    this.workspaceUpdated();
                catch
                end
            end
        end
    end %methods
        
    methods(Access='protected')
        function lhs=getLHS(this, idx)
            % Return the left-hand side of an expression to assign a value
            % to a matlab structure field.  (The variable name will be
            % pre-pended by the caller).  Returns a string like: '.field'
            fieldNames = fieldnames(this.Data);
            numericIdx = str2num(idx); %#ok<ST2NM>
            lhs = fieldNames{numericIdx(1)};
        end
        
        function sizeStr = getSizeString(~, obj)
            % Returns a string representing the size.  For most cases, it
            % will be num2str(size(obj)), but this function also handles
            % java objects in the workspace
            try
                s = size(obj);
            catch
                s = [1,1];
            end
            if isnumeric(s)
                sizeStr = int2str(s);
            elseif isjava(obj) && ismethod(s, 'toString')
                sizeStr = char(s.toString);
            else
                sizeStr = '';
            end
        end
    end    
end
