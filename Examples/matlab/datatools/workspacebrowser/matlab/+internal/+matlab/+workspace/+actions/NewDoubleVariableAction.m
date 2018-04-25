classdef NewDoubleVariableAction < internal.matlab.variableeditor.VEAction
    %NewAction
    %        Create a new unnamed variable in workspacebroswer
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        ActionType = 'NewDoubleVariableAction'
    end
    
    methods
        function this = NewDoubleVariableAction(props, manager)
            props.ID = internal.matlab.workspace.actions.NewDoubleVariableAction.ActionType;
            props.Enabled = true;
            this@internal.matlab.variableeditor.VEAction(props, manager);
            this.Callback = @this.NewDoubleVariable;
        end
        
        function NewDoubleVariable(this)
            % get the right variable name that we can use
            % create a new variable with the right name we get
            wsbDocument = this.veManager.Documents;
            data = wsbDocument.DataModel.Data;
            fields = fieldnames(data);
            
            cmd = this.getCommandForNewDouble(fields);
            this.executeInWebWorker(cmd);
        end
        
        function cmd = getCommandForNewDouble(this, fields)
            defaultvalue = 0;
            newUniqueName = matlab.lang.makeUniqueStrings('unnamed', fields);
            newcmd = "eval(['%s' ' = " + defaultvalue + ";']);";
            cmd = sprintf(newcmd, newUniqueName);
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

