classdef SaveVariablesAction < internal.matlab.variableeditor.VEAction
    %SaveAction
    %        Save selected actions in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'SaveVariablesAction'
    end
    
    methods
        function this = SaveVariablesAction(props, manager)
            props.ID = internal.matlab.workspace.actions.SaveVariablesAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.SaveVariables;
        end
        
        function SaveVariables(this)
            % get the list of selected fields and create a command to
            % save them all
            wsbDocument = this.veManager.Documents;
            selectedFields = wsbDocument.ViewModel.SelectedFields;
            if ~isempty(selectedFields)
                cmd = this.getCommandForSave(selectedFields);
                this.executeInWebWorker(cmd);
            end
        end
        
        function cmd = getCommandForSave(this, selectedFields)
            savevarcmd = "uisave({'%s'});";
            savefield = strjoin(string(selectedFields), ''',''');
            cmd = sprintf(savevarcmd ,savefield);
        end
        
        function  UpdateActionState(this)
            this.Enabled = true;
        end
    end
    
    methods(Access = protected)
        function executeInWebWorker(this, cmd)
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(cmd);
        end
    end
    
end


