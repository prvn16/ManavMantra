classdef MLNamedVariableObserver < internal.matlab.variableeditor.VariableObserver & internal.matlab.variableeditor.NamedVariable & JavaVisible
    %MLNAMEDVARIABLEOBSERVER Summary of this class goes here
    %   Detailed explanation goes here

    % Copyright 2013-2016 The MathWorks, Inc.

    % WebWorkspaceListener
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        % WebWorkspaceListener Property
        WebWorkspaceListener;
    end %properties
    methods
        function storedValue = get.WebWorkspaceListener(this)
            storedValue = this.WebWorkspaceListener;
        end
        
        function set.WebWorkspaceListener(this, newValue)
            reallyDoCopy = ~isequal(this.WebWorkspaceListener, newValue);
            if reallyDoCopy
                this.WebWorkspaceListener = newValue;
            end
        end
    end
    
    % Workspace Listeners
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        WorkspaceVariablesAddedListener;
        WorkspaceVariablesRemovedListener;
        WorkspaceVariablesChangedListener;
    end %properties
    
    % IgnoreUpdates
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % IgnoreUpdates Property
        IgnoreUpdates = false;
    end %properties
    methods
        function storedValue = get.IgnoreUpdates(this)
            storedValue = this.IgnoreUpdates;
        end
        
        function set.IgnoreUpdates(this, newValue)
            reallyDoCopy = ~isequal(this.IgnoreUpdates, newValue);
            if reallyDoCopy
                this.IgnoreUpdates = newValue;
            end
        end
    end
    
    methods(Access='public')
        % Constructor
        function this = MLNamedVariableObserver(name, workspace)
            this.Name = name;
            this.Workspace = workspace;
            % TODO: Make this a singleton
            if ~isdeployed
                % g1443766: temporary eLCM fix
                this.WebWorkspaceListener = com.mathworks.datatools.variableeditor.web.workspace.WebWorkspaceListener(this);
                this.WebWorkspaceListener.addWorkspaceListenerNoUpdate;
            end
            if isa(workspace, 'internal.matlab.variableeditor.MLWorkspace')
                this.WorkspaceVariablesAddedListener = event.listener(workspace, 'VariablesAdded', @(es,ed)this.workspaceUpdated());
                this.WorkspaceVariablesAddedListener = event.listener(workspace, 'VariablesRemoved', @(es,ed)this.workspaceUpdated());
                this.WorkspaceVariablesAddedListener = event.listener(workspace, 'VariablesChanged', @(es,ed)this.workspaceUpdated());
            end
        end
        
        % workspace data changed event from java
        function workspaceUpdated(this, varNames)
            naninfBreakpoint = this.disableNanInfBreakpoint();
            if nargin <= 1 || isempty(varNames)
                varNames = {};
            end
            
            if ~this.IgnoreUpdates
                 % This is called from java so we don't want to throw an
                 % exception back to java, we'll catch it and deal with it
                 % here
                try
                    varNames = string(varNames);
                    if isempty(varNames) || any(strcmp(varNames, this.Name))...
                            || strcmp(this.Name, 'who') % who is special cased for filtered workspaces, TODO: refactor for better solution
                        newData = evalin(this.Workspace,this.Name);
                        varSize = size(newData);
                        varClass = class(newData);
                        this.variableChanged(newData, varSize, varClass);
                    end
                catch ex
                    % We are probably evaluating in the wrong workspace!
                    % If the variable is out of scope, provide a
                    % message indicating that the variable does not
                    % exist that will be displayed in the Unsupported
                    % View. (g1217380)
                    errorMessage = getString(message('MATLAB:codetools:variableeditor:NonExistentVariable', this.Name));
                    this.variableChanged(errorMessage, 0, '');
                end
            end
            
            this.reEnableNanInfBreakpoint(naninfBreakpoint);
        end

        % This method is called if an error occurred updating the whos data
        function whosError(this, exception) %#ok<INUSD>
            % Override for implementation specific handling
        end
        
        function delete(this)
            if ~isempty(this.WebWorkspaceListener)
                this.WebWorkspaceListener.removeWorkspaceListener;
            end
        end
    end
    
    methods(Access = protected)
        function naninfBreakpoint = disableNanInfBreakpoint(~)
            % Disable the naninf breakpoint if it is set.  This is done
            % because if the user does a 'dbstop if naninf', we don't want
            % it to be hit during the background running code in the
            % workspace browser or variable editor.  Returns a logical
            % which is whether the naninf breakpoint was set by the user.
            b = dbstatus;
            naninfBreakpoint = false;
            for i = 1:length(b)
                if isequal(b(i).cond, 'naninf')
                    dbclear('if', 'naninf');
                    naninfBreakpoint = true;
                    break;
                end
            end
        end
        
        function reEnableNanInfBreakpoint(~, naninfBreakpoint)
            % Reenable the naninf breakpoint if it was previously set.
            if naninfBreakpoint
                dbstop('if', 'naninf');
            end
        end
    end
end

