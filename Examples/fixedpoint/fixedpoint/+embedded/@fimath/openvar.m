function openvar(name, ~) 
%OPENVAR Open a fimath object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a fimath object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%



%   Copyright 2016-2017 The MathWorks, Inc.

    % Error handling.
    if nargin > 0
        name = convertStringsToChars(name);
    end
    
    matlab.desktop.vareditor.VariableEditor.checkAvailable();
    matlab.desktop.vareditor.VariableEditor.checkVariableName(name);

    % The builtin openvar function opens a DAStudio Dialog if the object is
    % a scalar and either the dialog method or getDialogSchema method is
    % defined on the object. The fimath object has a getDialogSchema, but wants
    % to open in the Workspace Editor for both scalar and matrix objects.
    variable = com.mathworks.mlservices.WorkspaceVariableAdaptor(name);
    com.mathworks.mlservices.MLArrayEditorServices.openVariable(variable);

end