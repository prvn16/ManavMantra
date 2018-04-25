classdef SaveAllVariablesAction < internal.matlab.variableeditor.VEAction
    %SaveAction
    %        Save all workspace varaibles
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'SaveAllVariablesAction'
    end
    
    methods
        function this = SaveAllVariablesAction(props, manager)
            props.ID = internal.matlab.workspace.actions.SaveAllVariablesAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.SaveAllVariables;
        end
        
        function SaveAllVariables(this)
            cmd = 'uisave;';
            this.executeInWebWorker(cmd);
        end
        
        function UpdateActionState(this)
            WSBmanager = internal.matlab.workspace.peer.PeerWorkspaceBrowser.getInstance;
            WSBdata = WSBmanager.WorkspaceDocument.DataModel.Data;
            if ~isempty(fieldnames(WSBdata))
                this.Enabled = true;
            else
                this.Enabled = false;
            end
        end
    end
    
    methods(Access = protected)
        function executeInWebWorker(this, cmd)
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(cmd);
        end
    end
    
end

