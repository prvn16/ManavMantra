function createviewmanager(h)
%CREATEVIEWMANAGER Defines the views in the Fixed-Point Tool View Manager


%   Copyright 2010-2014 The MathWorks, Inc.

vm = h.getViewManager;
if isempty(vm)
    vm = fxptui.FPTViewManager();
    vm.install(h, false); % for menus
    vm.load;
    vm.customize;
    activeView = vm.getView(fxptui.message('labelViewSimulation'));
    if isempty(activeView)
        allViews = vm.getAllViews;
        activeView = allViews(1);
    end
    vm.ActiveView = activeView;
    h.SuggestionListener = handle.listener(vm, findprop(vm,'SuggestionMode'),'PropertyPostSet',@(s,e)updateLockView(h));

end

% [EOF]
