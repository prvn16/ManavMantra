classdef OpenVariableAction < internal.matlab.variableeditor.VEAction
    %OpenAction
    %        Open selected actions in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'OpenVariableAction'
    end
    
    methods
        function this = OpenVariableAction(props, manager)
            props.ID = internal.matlab.workspace.actions.OpenVariableAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.OpenVariable;
        end
        
        function OpenVariable(this)
            % get the list of selected fields and create a command to
            % open them all
            wsbDocument = this.veManager.Documents;
            selectedFields = wsbDocument.ViewModel.SelectedFields;
            
            if ~isempty(selectedFields)
                cmd = this.getCommandForOpen(selectedFields);
                this.executeInWebWorker(cmd);
            end
        end
        
        function cmd = getCommandForOpen(this, selectedFields)
            for i=1:length(selectedFields)
                openvarcmd = "[~]=internal.matlab.variableeditor.peer.PeerVariableEditor.openvar('%s');";
                singlecmd = sprintf(openvarcmd, char(selectedFields{i}));
                if i==1
                    cmd = singlecmd;
                else
                    cmd = strcat(cmd, singlecmd);
                end
            end
        end
        
        function UpdateActionState(this)
            this.Enabled = true;
        end
    end
    
    methods(Access = protected)
        function executeInWebWorker(this, cmd)
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(cmd);
        end
    end
end

