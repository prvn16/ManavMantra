function addArrayEditorVariable(varName)

% Called from java client listener in ArrayEditorManager when a new
% Variable Editor is opened.

%   Copyright 2007-2008 The MathWorks, Inc.

h = datamanager.BrushManager.getInstance();
parenStart = strfind(varName,'(');
subsstr = '';
if ~isempty(parenStart)
    subsstr = varName(parenStart:end);
    varName = varName(1:parenStart(1)-1);    
end

% If this variable and subreference string is not represented in the
% Brushing Manager, add it.
if ~any(strcmp(h.ArrayEditorVariables,varName) & strcmp(h.ArrayEditorSubStrings,subsstr))
    h.ArrayEditorVariables = [h.ArrayEditorVariables;...
                              {varName}];
    h.ArrayEditorSubStrings = [h.ArrayEditorSubStrings;...
                              {subsstr}]; 
end