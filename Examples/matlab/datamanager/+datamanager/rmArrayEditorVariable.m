function rmArrayEditorVariable(varName)

% Called from ArrayEditorManager.java when a Variable Editor client is closed.

%   Copyright 2007-2008 The MathWorks, Inc.

% Update the brushmanager to a variable being closed from the Variable
% Editor.
h = datamanager.BrushManager.getInstance();
ind = strcmp(h.ArrayEditorVariables,varName);
h.ArrayEditorVariables(ind) = [];
h.ArrayEditorSubStrings(ind) = [];

% Garbage collect any orphaned variables from the brushmanager.
h.reconcile;