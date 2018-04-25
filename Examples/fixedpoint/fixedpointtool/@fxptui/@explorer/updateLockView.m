function updateLockView(h)
% UPDATELOCKVIEW updates the state of the LockView action

% Copyright 2014 The MathWorks, Inc.

vm = h.getViewManager;
lockAction = h.getaction('VIEWMANAGER_LOCK');

if strcmpi(vm.SuggestionMode,'show')
    lockAction.On = 'on';
else
    lockAction.On = 'off';
end

