function selectedOption = uiconfirm(hUIFigure, messageString, titleString, varargin)
%UICONFIRM Shows a confirmation dialog inside a given uifigure.
%   UICONFIRM(f, message, title) shows a modal confirm dialog inside
%   the given uifigure with the given message and title.
%   By default, a question icon will be used and OK/Cancel buttons are
%   displayed.
%   f is the uifigure that was created using the uifigure function.
%   Message is a character vector or a cell array of character vectors.
%   Title is a character vector.
%
%   UICONFIRM(f, message, title, 'Options', {'Yes','No','Cancel'})
%   specifies the text of the options to display in the confirm dialog.
%   The default is {'Ok', 'Cancel'}.
%   Options can be a cell array containing 1 to 4 options.
%
%   UICONFIRM(f, message, title, 'Icon', IconSpec) specifies which
%   icon to display in the confirm dialog. IconSpec can be one of the
%   following: 'error', 'warning', 'info', 'success', 'question', 'none',
%   a file path to the icon file or an MxNx3 cdata matrix.
%   The default is 'question'.
%   Icon file types supported are SVG, PNG, JPEG and GIF.
%
%   UICONFIRM(f, message, title, 'CloseFcn', func) specifies the
%   callback function that will executed when the confirm  dialog is closed
%   by the user. The user response is provided in the eventdata of the
%   callback.
%
%   UICONFIRM(f, message, title, 'Options', {'a','b','c'}, ...
%             'DefaultOption', 'b', 'CancelOption', 'a')
%   DefaultOption specifies which entry in the options cell array is the
%   default focused option in the dialog.
%   CancelOption specifies which entry in the options cell array maps to
%   the cancel actions in the dialog.
%   The default are the first and last options respectively.
%   The value can be the text in cell array or the index.
%    
%   selectedOption = UICONFIRM(...) blocks MATLAB and waits until user
%   makes a selection on the confirmation dialog. The return argument is
%   the option selected by the user.
%
%   Example
%      % Assuming f is a figure created using the uifigure function.
%      uiconfirm(f, 'Do you want to quit MATLAB?', ...
%                   'Options', {'Yes','No','Cancel'}, ...
%                   'Quit?', 'CloseFcn', @(o,e) handleDialog(o,e));
%
%   See also UIFIGURE, UIALERT

%   Copyright 2017 The MathWorks, Inc.

narginchk(3,13);
nargoutchk(0,1);

messageString = convertStringsToChars(messageString);
titleString = convertStringsToChars(titleString);

if nargin > 3
    [varargin{:}] = convertStringsToChars(varargin{:});
end

figureID = matlab.ui.internal.dialog.DialogHelper.validateUIfigure(hUIFigure);

messageString = matlab.ui.internal.dialog.DialogHelper.validateMessageText(messageString);

titleString = matlab.ui.internal.dialog.DialogHelper.validateTitle(titleString);

% Default Parameter Values:
params = struct('Icon', 'question', 'CloseFcn', '');
params.Options = {getString(message('MATLAB:uitools:uidialogs:OK')), getString(message('MATLAB:uitools:uidialogs:Cancel'))};
params.DefaultOption = [];
params.CancelOption = [];

[params, iconType] = matlab.ui.internal.dialog.DialogHelper.validatePVPairs(params, varargin{:});

optLen = length(params.Options);
params.DefaultOption = validateOptions(params, 'DefaultOption', 1, optLen);
params.CancelOption = validateOptions(params, 'CancelOption', optLen, optLen);

params.Figure = hUIFigure;
params.FigureID = figureID;
params.Message = messageString;
params.Title = titleString;
params.IconType = iconType;

% Show dialog with given parameters and attributes
confirmDialogController = matlab.ui.internal.dialog.DialogHelper.setupConfirmDialogController();
dc = confirmDialogController(params);
dc.show();

if (nargout == 1)
    % If user requested output then we block and wait for the end-user
    % response to the dialog.
    waitfor(dc,'SelectedOption');
    
    selectedOption = dc.SelectedOption;
end
end

function out = validateOptions(params, type, default, optLen)
% DefaulOption and CancelOption can be a string or a number which matches
% the options cell array.
val = params.(type);
options = params.Options;

if isempty(val)
    out = default;
    return;
end

if isnumeric(val) && isscalar(val)
    [valid, idx] = ismember(val, 1:optLen);
    if ~valid
        throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
    end
    out = idx;
    return;
end

if ischar(val)
    [valid, idx] = ismember(val, options);
    if ~valid
        throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
    end
    out = idx;
    return;
end

% no match
throwAsCaller(MException(message('MATLAB:uitools:uidialogs:InvalidDefaultOption', type)));
end

