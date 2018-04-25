function processAppDebugInfo(currentMlappFilename, currentMlappLineNumber, mlappsInStack) 
% This function is internal and may change in future releases.

% This is the bridge between com.mathworks.mde.appdesigner.AppDesignerDebugServices.java
% and App Designer's MATLAB api

% Copyright 2015 The MathWorks, Inc.

% mlappsInStack comes from the AppDesignerDebugServices.java as a 
% Java String array and so it needs to be converted to a MATLAB cell array
mlappsInStack = cell(mlappsInStack);

% Get AppCodeTool instance
appCodeTool = appdesigner.internal.application.getAppCodeTool();

% Process debugMlapp request to open App Designer if necessary and set
% debug state of MLAPPs in the debug stack
appCodeTool.processDebugInfo(currentMlappFilename, currentMlappLineNumber, mlappsInStack);


