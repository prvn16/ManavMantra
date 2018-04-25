function uialert(hUIFigure, messageString, titleString, varargin)
%UIALERT Shows an alert dialog inside a given uifigure.
%   UIALERT(f, message, title) shows a modal alert dialog inside
%   the given uifigure with the given message and title.
%   By default, an error icon will be used.
%   f is the uifigure that was created using the uifigure function.
%   Message is a character vector or a cell array of character vectors.
%   Title is a character vector.
%
%   UIALERT(f, message, title, 'Icon', IconSpec) specifies which
%   icon to display in the alert dialog. IconSpec can be one of the
%   following: 'error', 'warning', 'info', 'success', 'none', a file path to the
%   icon file or an MxNx3 cdata matrix. The default is 'error'.
%   Icon file types supported are SVG, PNG, JPEG and GIF.
%
%   UIALERT(f, message, title, 'Modal', false) specifies the
%   modality of the alert dialog. Specify false to make a non-modal alert
%   dialog. The default is a modal alert dialog.
%
%   UIALERT(f, message, title, 'CloseFcn', func) specifies the
%   callback function that will executed when the alert dialog is closed.
%
%   Example
%      % Assuming f is a figure created using the uifigure function.
%      uialert(f, 'The filename entered cannot be found.', ...
%                 'Invalid Filename Entered');
%
%   See also UIFIGURE, UICONFIRM

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(3, 9);
nargoutchk(0,0);

messageString = convertStringsToChars(messageString);
titleString = convertStringsToChars(titleString);

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

figureID = matlab.ui.internal.dialog.DialogHelper.validateUIfigure(hUIFigure);

messageString = matlab.ui.internal.dialog.DialogHelper.validateMessageText(messageString);

titleString = matlab.ui.internal.dialog.DialogHelper.validateTitle(titleString);

% Default Parameter Values:
params = struct('Icon', 'error', 'Modal', true, 'CloseFcn','');
[params, iconType] = matlab.ui.internal.dialog.DialogHelper.validatePVPairs(params, varargin{:});

params.Figure = hUIFigure;
params.FigureID = figureID;
params.Message = messageString;
params.Title = titleString;
params.IconType = iconType;

% Show dialog with given parameters and attributes
alertDialogController = matlab.ui.internal.dialog.DialogHelper.setupAlertDialogController();
dc = alertDialogController(params);
dc.show();
end



