function m = createmenu_file(h)
%CREATMENU_FILE

%   Author(s): G. Taillefer
%   Copyright 2006-2014 The MathWorks, Inc.

am = DAStudio.ActionManager;
m = am.createPopupMenu(h);

if(slfeature('FPTImportExportUISupport'))
    % add import menu option
    action = h.getaction('IMPORT_DATASET');
    m.addMenuItem(action);
    
    % add export menu option
    action = h.getaction('EXPORT_DATASET');
    m.addMenuItem(action);
end
m.addSeparator;

action = h.getaction('FILE_CLOSE');
m.addMenuItem(action);





% [EOF]