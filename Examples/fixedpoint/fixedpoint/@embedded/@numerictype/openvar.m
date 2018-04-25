function openvar(name, obj) 
%OPENVAR Open a numerictype object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a numerictype object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%
%    Copyright 2014-2017 The MathWorks, Inc.


if nargin > 0
    name = convertStringsToChars(name);
end

if ~isa(obj, 'embedded.numerictype')
    error(message('fixed:fi:unsupportedType', class(obj)));
end

% Check to see if a dialog already exists. Bring it into focus if
% it does
if ~isempty(name) && ischar(name)
    openDlg = DAStudio.ToolRoot.getOpenDialogs.find('DialogTag', ...
                                                    ['embedded.numerictype:',name]);
else
    openDlg = [];
end
if isempty(openDlg)
    DAStudio.Dialog(obj, name, 'DLG_STANDALONE');
else
    % the dialog already exists
    openDlg.show;
end
