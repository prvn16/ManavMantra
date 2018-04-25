function b = isFPTEnabledForSignalLogging(model)
% ISFPTENABLEDFORSIGNALLOGGING Package function to tell if FPT is valid, open and is visible with
% the model set as the root of FPT. This function is used by Signal Builder
% to tell if SDI data needs to be added. 

% Copyright 2014 The MathWorks, Inc.

me = fxptui.getexplorer;
rootModel = me.getFPTRoot.getHighestLevelParent;
b = ~isempty(me) && me.isVisible && ...
    strcmpi(rootModel, model) && ...
    strcmpi(get_param(rootModel,'SignalLogging'),'on');
