function installSaveToWorkSpaceContextMenu(hImage, varLabel, varName)
%   Copyright 2014 The MathWorks, Inc.

% Adds right-click context menu to a image which cases the corresponding
% cdata in the image axis to the workspace as a variable

hcmenu = uicontextmenu('Parent', getParentFigure(hImage));
uimenu(hcmenu,...
    'Label',getString(message('images:commonUIString:exportImageToWS')),...
    'Tag', 'exportToWorkSpace',...
    'Callback', @(varargin)saveToWS(hImage,varLabel, varName));
set(hImage,'uicontextmenu',hcmenu);

end


function saveToWS(hImage, varLabel, varName)
h = export2wsdlg({varLabel},{varName}, {hImage.CData});
movegui(h,'center');
end

function obj = getParentFigure(obj)
while ~isa(obj,'matlab.ui.Figure')
    obj = get(obj,'parent');
end
end