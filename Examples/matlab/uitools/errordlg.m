function varargout = errordlg(errorStringIn,dlgName,replace)
%ERRORDLG Error dialog box.
%  HANDLE = ERRORDLG(ERRORSTRING,DLGNAME) creates an error dialog box which
%  displays ERRORSTRING in a window named DLGNAME.  A pushbutton labeled OK
%  must be pressed to make the error box disappear.  
%
%  HANDLE = ERRORDLG(ERRORSTRING,DLGNAME,CREATEMODE) allows CREATEMODE
%  options that are the same as those offered by MSGBOX.  The default value
%  for CREATEMODE is 'non-modal'.
%
%  ErrorString will accept any valid string input but a cell array is
%  preferred.
%
%  ERRORDLG uses MSGBOX.  Please see the help for MSGBOX for a full
%  description of the input arguments to ERRORDLG.
%  
%   Example:
%       f = errordlg('This is an error string.', 'My Error Dialog');
%
%       f = errordlg('This is an error string.', 'My Error Dialog', 'modal');
%
%  See also DIALOG, HELPDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.

if nargin > 0
    errorStringIn = convertStringsToChars(errorStringIn);
end

if nargin > 1
    dlgName = convertStringsToChars(dlgName);
end

if nargin > 2
    replace = convertStringsToChars(replace);
end

NumArgIn = nargin;
if NumArgIn==0
   errorStringIn = {getString(message('MATLAB:uistring:popupdialogs:ErrorDialogDefaultString'))};
end

if NumArgIn<2,  dlgName = getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')); end
if NumArgIn<3,  replace='non-modal'     ; end

% Backwards Compatibility
if ischar(replace)
  if strcmp(replace,'on')
    replace='replace';
  elseif strcmp(replace,'off')
    replace='non-modal';
  end
end

ErrorStringCell = dialogCellstrHelper(errorStringIn);

handle = msgbox(ErrorStringCell,dlgName,'error',replace);
if nargout==1,varargout(1)={handle};end
