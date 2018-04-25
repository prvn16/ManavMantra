classdef ClearWorkspaceAction < internal.matlab.variableeditor.VEAction
    %ClearAction
    %        clear all variables in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'ClearWorkspaceAction'
    end
    
    methods
        function this = ClearWorkspaceAction(props, manager)
            props.ID = internal.matlab.workspace.actions.ClearWorkspaceAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.ClearWorkspace;
        end
        
        function ClearWorkspace(this)
            %check the conformationdialog setting first and open a confirmation dialog if setting is true
            s = settings;
            confirmationsetting = s.matlab.confirmationdialogs.WorkspaceBrowserClearConfirmation.ActiveValue;
            this.getdialog(confirmationsetting);
        end
        
        function getdialog(this,confirmationsetting)
            if confirmationsetting==1
                ok = getString(message('MATLAB:codetools:confirmationdialog:Ok'));
                cancel = getString(message('MATLAB:codetools:confirmationdialog:Cancel'));
                user_response = this.get_userresponse;
                
                if strcmp(user_response,ok)
                    % Call clear twice to handle the case where the user has a variable named 'variables'.
                    cmd = "builtin('clear', 'variables'); builtin('clear', 'variables');";
                    this.executeInWebWorker(cmd);
                elseif strcmp(user_response,cancel)
                    return
                end
                
            elseif confirmationsetting==0
                % Call clear twice to handle the case where the user has a variable named 'variables'.
                cmd = "builtin('clear', 'variables'); builtin('clear', 'variables');";
                this.executeInWebWorker(cmd);
            end
        end
        
        function response = get_userresponse(this)
            dialogstring = getString(message('MATLAB:codetools:confirmationdialog:ClearWSBConfirmation'));
            deletepreference = getString(message('MATLAB:codetools:confirmationdialog:ClearPreference'));
            ok = getString(message('MATLAB:codetools:confirmationdialog:Ok'));
            cancel = getString(message('MATLAB:codetools:confirmationdialog:Cancel'));
            response = questdlg(dialogstring,deletepreference, ok, cancel, ok);
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

