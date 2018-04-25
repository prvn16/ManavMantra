function dlg = getautoscaledialog(h)
%GETAUTOSCALEDIALOG return reference to the autoscale dialog.

%   Copyright 2007 The MathWorks, Inc.

dlg = h.autoscaleinfo;
if isempty(dlg)
    dlg = DAStudio.ToolRoot.getOpenDialogs.find('DialogTag','Fixed_Point_Tool_Autoscale_Information');
end

% [EOF]