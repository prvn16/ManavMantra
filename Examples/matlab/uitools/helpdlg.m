function varargout = helpdlg(helpString,dlgName)
%HELPDLG Help dialog box.
%  HANDLE = HELPDLG(HELPSTRING,DLGNAME) displays the 
%  message helpString in a dialog box with title DLGNAME.  
%  If a Help dialog with that name is already on the screen, 
%  it is brought to the front.  Otherwise a new one is created.
%
%  HelpString will accept any valid string input but a cell
%  array is preferred.
%
%   Example:
%       h = helpdlg('This is a help string','My Help Dialog');
%
%  See also DIALOG, ERRORDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.

if nargin > 0
    helpString = convertStringsToChars(helpString);
end

if nargin > 1
    dlgName = convertStringsToChars(dlgName);
end

if nargin==0
   helpString ={getString(message('MATLAB:uistring:popupdialogs:HelpDialogDefaultString'))};
end
if nargin<2
   dlgName = getString(message('MATLAB:uistring:popupdialogs:HelpDialogTitle'));
end

HelpStringCell = dialogCellstrHelper(helpString);

handle = msgbox(HelpStringCell,dlgName,'help','replace');

if nargout==1,varargout(1)={handle};end
