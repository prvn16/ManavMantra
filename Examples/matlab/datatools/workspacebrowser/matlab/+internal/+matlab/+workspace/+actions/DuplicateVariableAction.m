classdef DuplicateVariableAction < internal.matlab.variableeditor.VEAction
    %DuplicateAction
    %        Duplicate selected variables in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'DuplicateVariableAction'
    end
    
    methods
        function this = DuplicateVariableAction(props, manager)
            props.ID = internal.matlab.workspace.actions.DuplicateVariableAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.DuplicateVariable;
        end
        
        function DuplicateVariable(this)
            % get the right variable name that we can use
            % duplicate the variable with the right name we get
            wsbDocument = this.veManager.Documents;
            selectedFields = wsbDocument.ViewModel.SelectedFields;
            data = wsbDocument.DataModel.Data;
            fields = fieldnames(data);
            
            if ~isempty(selectedFields)
                cmd = this.getCommandForDuplicate(selectedFields, fields);
                this.executeInWebWorker(cmd);
            end
        end
        
        function cmd = getCommandForDuplicate(this, selectedFields, fields)
            for i=1:length(selectedFields)
                % Get the unique variable name to use for the copy
                newUniqueName = this.getVarNameForCopy(selectedFields{i}, fields);
                
                % Add in the variable name being created to the list of
                % fields
                fields = {fields{:} char(newUniqueName)}; %#ok<CCAT>

                % Create the command for the duplicatation
                dupliactecmd = "eval(['%s = %s;']);";
                singlecmd = sprintf(dupliactecmd, newUniqueName, char(selectedFields{i}));
                if i==1
                    cmd = singlecmd;
                else
                    cmd = strcat(cmd, singlecmd);
                end
            end
        end
        
        function  UpdateActionState(this)
            this.Enabled = true;
        end
    end
    
    methods(Access = protected)
        function executeInWebWorker(~, cmd)
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(cmd);
        end
    end
    
    methods(Hidden = true)
        function new = getVarNameForCopy(~, varname, fields)  
            % Get the variable name to use for the copy.  Given a variable
            % name of 'x', it will return 'xCopy'.  If 'xCopy' already
            % exists, it will append _<number> to find a unique variable
            % name.  In addition, this function assures that the return
            % variable name will not exceed namelengthmax.
            if iscell(varname)
                varname = varname{1};
            end
            counter = 0;
            if strlength(varname) + 4 > namelengthmax
                varname = varname(1:namelengthmax - 4);
            end
            new_base = varname + "Copy";
            new = new_base;
            while any(new == fields)
                counter = counter + 1;
                proposed_number_string = "_" + counter;
                new = new_base + proposed_number_string;
                if strlength(new) > namelengthmax
                    new = varname(1:namelengthmax - 4 - strlength(proposed_number_string)) + ...
                        "Copy"  + proposed_number_string;
                end
            end
        end
    end
end

