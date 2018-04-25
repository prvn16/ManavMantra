function cb_showsyspanelforfpa
%CB_SHOWSYSPANELFORFPA Callback to turn on the visibility of the "current
%system setings" panel in the Fixed-Point Tool from FPA. 
% FPA has checks that can prompt users to change the DTO & Instrumentation
% settings via the FPT. The system settings panel needs to be visible in
% this case. 

%   Copyright 2011-2016 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me);return; end
if ~me.ShowSystemSettingsPanel
    % Use the action to show the system settings since the menu needs to be
    % sybchronized.
    toggle_action = me.getaction('VIEW_SYSSETTINGSPNL');
    toggle_action.On = 'On';
end


% [EOF]
