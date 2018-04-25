function OpenSettingsEditor(varargin)
% Opens the settings panel of the shortcut editor

% Copyright 2016-2018 The MathWorks, Inc.

topMdlObj = [];
if nargin < 1
    fpt = fxptui.FixedPointTool.getExistingInstance;
    if ~isempty(fpt)
        model = fpt.getModel;
        
        topMdlObj = get_param(model,'Object');
    end
else
    % Used by diagnostic messages that ask user to change MMO/DTO settings
    try
        model = bdroot(varargin{1});
        topMdlObj = get_param(model,'Object');
    catch
    end
end
if ~isempty(topMdlObj)  
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(model);
    if ~success
        fxptui.showdialog(dlgType);
        return;
    end
    bae = fxptui.BAExplorer(topMdlObj);    
    dlg = bae.getDialog;
    dlg.setActiveTab('shortcut_editor_tabs', 0);
end
end
