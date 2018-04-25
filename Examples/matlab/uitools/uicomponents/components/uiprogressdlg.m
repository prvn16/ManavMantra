function progressDialog = uiprogressdlg(hUIFigure, varargin)
%UIPROGRESSDLG Shows a progress dialog inside a given uifigure.
%   UIPROGRESSDLG(f) shows a modal progress dialog inside
%   the given uifigure with the progress value set to zero
%   f is the uifigure that was created using the uifigure function.
%
%   progressDialog = UIPROGRESSDLG( ___ ,Name,Value) show a progress dialog
%   configured with one or more Name,Value pair arguments.
%
%   Example 1: Create a progress dialog and update its value
%      progressDialog = uiprogressdlg(f);
%      % Do some task
%      progressDialog.Value = .5;
%      % Complete task
%      progressDialog.Value = 1;
%      % close the dialog
%      delete(progressDialog);
%
%   Example 2: Create a progress dialog with title and message text
%      progressDialog = uiprogressdlg(f,'Message','Processing selected images',...
%                       'Title','Please Wait!');
%
%   Example 3: Create an indeterminate progress bar
%      progressDialog = uiprogressdlg(f,'Indeterminate','on',...
%                       'Message','Processing selected images',...
%                       'Title','Please Wait!')
%
%   See also UIFIGURE, UIALERT, UICONFIRM

%   Copyright 2017 The MathWorks.

narginchk(1,nargin);
progressDialog = matlab.ui.dialog.ProgressDialog(hUIFigure, varargin{:});
end