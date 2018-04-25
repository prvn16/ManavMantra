function uiwait(hFigDlg, timeOutVal)
%UIWAIT Block execution and wait for resume.
%   UIWAIT(FIG) blocks execution until either UIRESUME is called or the
%   figure FIG is destroyed (closed).  UIWAIT with no input arguments is
%   the same as UIWAIT(GCF).
%
%   UIWAIT(FIG, TIMEOUT), in addition to the previous syntax, blocks
%   execution until either TIMEOUT seconds elapse or one of the
%   previous return conditions is met. TIMEOUT value cannot be less than
%   one second. In case the TIMEOUT value entered is less than one second
%   that particular value will not be used and a TIMEOUT value of one
%   second will be used.
%
%   When the dialog or figure is created, it should have a
%   uicontrol that either:
%       has a callback that calls UIRESUME, or
%       has a callback that destroys the dialog box
%   since these are the only methods that can resume program execution
%   after it has been suspended by the waitfor command.
%
%   UIWAIT is a convenient way to use the waitfor command and is used in
%   conjunction with a dialog box or figure.  When used with a modal
%   dialog (which captures all keyboard and mouse events), it provides a
%   way to suspend a MATLAB code and prevent the user from accessing any
%   MATLAB window until they respond to the dialog box.
%
%   Examples:
%       f = figure;
%       h = uicontrol('Position', [20 20 200 40], 'String', 'Continue', ...
%                     'Callback', 'uiresume(gcbf)');
%       disp('This will print immediately');
%       uiwait(gcf);
%       disp('This will print after you click Continue'); close(f);
%
%   See also UIRESUME, WAITFOR.

%   Copyright 1984-2010 The MathWorks, Inc.

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('uiwait');

% -------- Validate argument
if nargin < 1
    hFigDlg = gcf;
end

if ~isscalar(hFigDlg) || ~ishghandle(hFigDlg,'figure')
    error (message('MATLAB:uiwait:InvalidInputType'))
end

% -------- Setup and start timer object if a second argument is passed
t = [];
if nargin == 2
    if ~isnumeric(timeOutVal)
        error(message('MATLAB:uiwait:InvalidSecondInputType'));
    end
    if (timeOutVal < 1)
        timeOutVal = 1;
        warning(message('MATLAB:uiwait:InvalidSecondInputValue'));
    end
    t = timer('TimerFcn',{@uiresumeWrapper,hFigDlg}, ...
        'StartDelay',timeOutVal, ...
        'ExecutionMode','SingleShot');
end

% Setup a cleanup object
c = onCleanup(@() cleanupUiwait(t, hFigDlg));

% --------  Set the dialog's waitstatus property to 'waiting' and visible
set (hFigDlg, 'Visible', 'on', 'WaitStatus', 'waiting');
setappdata(hFigDlg,'UiResumeCalledAndWaitStatusChanged',false);

% --------  Start the timer
if (~isempty(t))
    start(t);
end

% --------  Call waitfor if WaitStatus has not resumed.
if ~getappdata(hFigDlg,'UiResumeCalledAndWaitStatusChanged')
    % If uiresumeWrapper is called here, MATLAB will remain blocked
    waitfor (hFigDlg, 'WaitStatus', 'inactive');
end

% -------- Explicitly delete the cleanup object
delete(c)
end


function uiresumeWrapper(~, ~, hFigDlg)
uiresume(hFigDlg);
setappdata(hFigDlg,'UiResumeCalledAndWaitStatusChanged',true);
end


function cleanupUiwait(t,hFigDlg)
% --------  Clean up appdata and timer object if it's there

if ~isempty(t) && isa(t,'timer')
    stop(t);
    delete(t);
end

if(ishghandle(hFigDlg))
    if isappdata(hFigDlg,'UiResumeCalledAndWaitStatusChanged')
        rmappdata(hFigDlg,'UiResumeCalledAndWaitStatusChanged');
    end
end
end

