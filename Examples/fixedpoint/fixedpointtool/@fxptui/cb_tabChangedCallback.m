function cb_tabChangedCallback(~,~,tabIndex)
%% cb_tabChangedCallback gets executed on tab selection.
% tabIndex - Index of the tab that is selected.
% workflowTabIndex = 0
% resultDetailsDialogTabIndex = 1
%   Copyright 2014 The MathWorks, Inc.

if( tabIndex )
    % result details tab selected.
    me = fxptui.getexplorer;
    if ~isempty (me)
        me.refreshDetailsDialog;
    end
end
