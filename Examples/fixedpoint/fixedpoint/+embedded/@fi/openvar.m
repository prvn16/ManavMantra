function openvar(name,~)
%OPENVAR Open workspace variable in tool for graphical editing
%   OPENVAR(NAME) edits the array in the base workspace whose name is given
%   in NAME.  NAME must contain a string.
%
%   This is the method overloaded for the embedded.fi object.

%   Copyright 2015-2017 The MathWorks, Inc.

    % Error handling.
    if nargin > 0
        name = convertStringsToChars(name);
    end
    
    matlab.desktop.vareditor.VariableEditor.checkAvailable();
    matlab.desktop.vareditor.VariableEditor.checkVariableName(name);

    % The builtin openvar function opens a DAStudio Dialog if the object is
    % a scalar and either the dialog method or getDialogSchema method is
    % defined on the object. The fi object has a getDialogSchema, but wants
    % to open in the Workspace Editor for both scalar and matrix objects.
    variable = com.mathworks.mlservices.WorkspaceVariableAdaptor(name);
    com.mathworks.mlservices.MLArrayEditorServices.openVariable(variable);

end