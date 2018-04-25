function CreateBAExplorer
%CREATE Summary of this function goes here
%   Detailed explanation goes here

%   Copyright 2016-2018 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
if ~isempty(fpt)
    topMdl = fpt.getModel;
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(topMdl);
    if ~success
        fxptui.showdialog(dlgType);
        return;
    end
    
    topMdlObj = get_param(topMdl,'Object');
    
    bae = fxptui.BAExplorer(topMdlObj);

    dlg = bae.getDialog;
    dlg.setActiveTab('shortcut_editor_tabs', 1);
end

end

