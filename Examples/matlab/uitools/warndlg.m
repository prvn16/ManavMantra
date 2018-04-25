function varargout = warndlg(WarnString,DlgName,Replace)
%WARNDLG Warning dialog box.
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME) creates a warning dialog box
%  which displays WARNSTRING in a window named DLGNAME.  A pushbutton
%  labeled OK must be pressed to make the warning box disappear.
%  
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME,CREATEMODE) allows CREATEMODE options
%  that are the same as those offered by MSGBOX.  The default value
%  for CREATEMODE is 'non-modal'.
%
%  WarnString will accept any valid string input but a cell 
%  array is preferred.
%
%  WARNDLG uses MSGBOX.  Please see the help for MSGBOX for a
%  full description of the input arguments to WARNDLG.
%
%   Examples:
%       f = warndlg('This is a warning string.', 'My Warn Dialog');
%
%       f = warndlg('This is a warning string.', 'My Warn Dialog', 'modal');
%
%  See also DIALOG, ERRORDLG, HELPDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG.

%  Author: L. Dean
%  Copyright 1984-2012 The MathWorks, Inc.

if nargin > 0
    WarnString = convertStringsToChars(WarnString);
end

if nargin > 1
    DlgName = convertStringsToChars(DlgName);
end

if nargin > 2
    Replace = convertStringsToChars(Replace);
end

if nargin==0
   WarnString = getString(message('MATLAB:uistring:popupdialogs:WarnDialogDefaultString'));
end
if nargin<2
   DlgName = getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle'));
end
if nargin<3
   Replace = 'non-modal';
end

WarnStringCell = dialogCellstrHelper(WarnString);

handle = msgbox(WarnStringCell,DlgName,'warn',Replace);

if nargout==1,varargout(1)={handle};end
