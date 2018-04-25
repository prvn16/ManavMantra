function cb_togglelockview
% CB_TOGGLELOCKVIEW Lock/unlock the currently selected view in the view manager
% against automatic view switching

% Copyright 2014 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me)
    return;
end
vm = me.getViewManager;
me.LockColumnView = ~me.LockColumnView;
% Disable property listener on the Suggestion mode before setting it
me.SuggestionListener.Enabled = 'Off';
if me.LockColumnView
    vm.SuggestionMode = 'show';
else
    vm.SuggestionMode = 'auto';
end
me.SuggestionListener.Enabled = 'On';
