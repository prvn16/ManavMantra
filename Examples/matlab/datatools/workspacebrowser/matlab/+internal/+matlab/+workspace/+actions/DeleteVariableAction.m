classdef DeleteVariableAction < internal.matlab.variableeditor.VEAction
    %DeleteAction
    %        Delete selected actions in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'DeleteVariableAction'
    end
    
    methods
        function this = DeleteVariableAction(props, manager)
            props.ID = internal.matlab.workspace.actions.DeleteVariableAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.DeleteVariable;
        end
        
        function DeleteVariable(this)
            % get the list of selected fields and create a command to
            % clear them all, the command will be like 'builtin('clear',clc
            % 'varname')'
            wsbDocument = this.veManager.Documents;
            selectedFields = wsbDocument.ViewModel.SelectedFields;
            s = settings;
            confirmationsetting = s.matlab.confirmationdialogs.WorkspaceBrowserClearConfirmation.ActiveValue;
            this.getdialog(selectedFields,confirmationsetting);
        end
        
        function getdialog(this,selectedFields,confirmationsetting)
            if confirmationsetting==1
                [~,ncols]= size(selectedFields);
                user_response = this.get_userresponse(ncols);
                ok = getString(message('MATLAB:codetools:confirmationdialog:Ok'));
                cancel = getString(message('MATLAB:codetools:confirmationdialog:Cancel'));
                
                if strcmp(user_response,ok)
                    this.Deletehelper(selectedFields)
                elseif strcmp(user_response,cancel)
                    return
                end
            elseif  confirmationsetting==0
                this.Deletehelper(selectedFields)
            end
        end
        
        function response = get_userresponse(this, ncols)
            if ncols ==1
                dialogstring = getString(message('MATLAB:codetools:confirmationdialog:DeleteVariableConfirmation'));
            else
                dialogstring = getString(message('MATLAB:codetools:confirmationdialog:DeleteVariablesConfirmation'));
            end
            deletepreference = getString(message('MATLAB:codetools:confirmationdialog:DeletePreference'));
            ok = getString(message('MATLAB:codetools:confirmationdialog:Ok'));
            cancel = getString(message('MATLAB:codetools:confirmationdialog:Cancel'));
            response = questdlg(dialogstring,deletepreference, ok, cancel, ok);
        end
        
        function Deletehelper(this, selectedFields)
            clearfield = strjoin(string(selectedFields), ''',''');
            clearcmd = "builtin('clear','%s');";
            cmd = sprintf(clearcmd ,clearfield);
            this.executeInWebWorker(cmd);
        end
        
        function UpdateActionState(this)
            this.Enabled = true;
        end
    end
    
    methods(Access= protected)
        function executeInWebWorker(this, cmd)
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(cmd);
        end
    end
end

