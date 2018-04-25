function openvar(name, obj) 
%OPENVAR Open a fimath object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a fimath object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%
%    Copyright 2013-2014 The MathWorks, Inc.


if ~isa(obj, 'embedded.fimath')
    error(message('fixed:fi:unsupportedType', class(obj)));
end

% Check to see if a dialog already exists. Bring it into focus if
% it does
if ~isempty(name) && ischar(name)
    openDlg = DAStudio.ToolRoot.getOpenDialogs.find('DialogTag', ...
                                                    ['embedded.fimath:',name]);
else
    openDlg = [];
end
if isempty(openDlg)
    DAStudio.Dialog(obj, name, 'DLG_STANDALONE');
else
    % the dialog already exists
    openDlg.show;
end
