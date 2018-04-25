function refreshDetailsDialog(h)

%   Copyright 2014-2015 The MathWorks, Inc.

resultDetailsTabIndex = 1;
activeTabIndex = 0;
tabContainerTag = 'FPTTabContainer';

me = fxptui.getexplorer;
if ~isempty(me)
    fptDlgHandle =  me.getDialog;
    if isa(fptDlgHandle,'DAStudio.Dialog')
        activeTabIndex = getActiveTab(fptDlgHandle,tabContainerTag);
    end
    
    if(isequal(activeTabIndex,resultDetailsTabIndex))
        node = h.getSelectedListNodes;
        h.resultInfoController.packageData(node);
        h.resultInfoController.publishData;
    end
end

%--------------------------------------------------------------------------