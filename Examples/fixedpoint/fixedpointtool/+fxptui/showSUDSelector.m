function showSUDSelector
% SHOWSUDSELECTOR Launches the Startup wizard

% Copyright 2014 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me)
    return
end
if isa(me.StartupObj, 'fxptui.Startup')
    me.StartupObj.deleteDialog;
    me.StartupObj.show;
end

