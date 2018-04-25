function e = tsnewevent(varargin)
%
% tstool utility function

%   Copyright 2004-2016 The MathWorks, Inc.

%% Utility function which opens a model dialog to allow a new event to be 
%% defined. The optional argument is either a date string or a numeric
%% time

%% Open the dialog
if nargin==0 || isempty(varargin{1})
    [evname,evtime] = localNewEventDlg([]);
else
    [evname,evtime] = localNewEventDlg(varargin{1});
end
if isempty(evname)
    e = [];
    return
end

%% Create the event and add it to the node (the Events listener will add a
%% new row to the table)
e = tsdata.event(evname,evtime);
if nargin>=1 && ~isempty(varargin{1}) && ischar(varargin{1})
   e.StartDate = varargin{1};
   e.Units = 'days';
end
%--------------------------------------------------------------------------
function [name,t] = localNewEventDlg(reftime)

%% Builds the event definition modal dialog
f = figure('Name', ...
  getString(message('MATLAB:timeseries:DefineNewEvent')), ...
  'WindowStyle','modal','Units',...
  'Characters','Position',[103.8 49.231 54 12.231],'NumberTitle','off',...
  'HandleVisibility','off','IntegerHandle','off', 'Tag', 'TSNewEvent');
LBLname = uicontrol('Style','Text','Units','Characters','Parent',f, ...
    'String', getString(message('MATLAB:timeseries:Name')), ...
    'Position',[1.8 9.077 10.6 1.154],'HorizontalAlignment',...
    'Left');
EDITname = uicontrol('Style','Edit','Units','Characters','Parent',f,...
    'Position',[14.6 8.769 27 1.615],'HorizontalAlignment','Left',...
    'BackgroundColor',[1 1 1]);
LBLtime = uicontrol('Style','Text','Units','Characters','Parent',f, ...
    'String', getString(message('MATLAB:timeseries:TimeDate')), ...
    'Position',[1.8 6.308 10.6 1.154],'HorizontalAlignment',...
    'Left');
EDITtime = uicontrol('Style','Edit','Units','Characters','Parent',f,...
    'Position',[14.6 6.077 27 1.615],'HorizontalAlignment','Left',...
    'BackgroundColor',[1 1 1]);
if ~isempty(reftime)
    if ischar(reftime)
        set(EDITtime,'String',reftime)
    elseif isnumeric(reftime)
        set(EDITtime,'String',sprintf('%0.3g',reftime))
    end
end
BTNcalendar = uicontrol('Style','Pushbutton','Units','Characters','Parent',f,...
    'String','...','Position',[44.4 5.932 6.2 1.769],'Callback',...
    {@localEventCalendar f EDITtime reftime});
BTNok = uicontrol('Style','Pushbutton','Units','Characters','Parent',f,...
    'String',getString(message('MATLAB:timeseries:OK')), ...
    'Position',[21.6-15 1.538 13.8 1.769],...
    'Callback',{@localOK f EDITname EDITtime reftime}); 
BTNcancel = uicontrol('Style','Pushbutton','Units','Characters','Parent',f,...
    'String',getString(message('MATLAB:timeseries:Cancel')), ...
    'Position',[37-15 1.462 13.8 1.769],'Callback',...
    {@localCancel f}, 'Tag', 'BTNcancel');

BTNhelp = uicontrol('Style','Pushbutton','Units','Characters','Parent',f,...
         'String',getString(message('MATLAB:timeseries:Help')), ...
         'Position',[37 1.462 13.8 1.769],'Callback',...
         @(es,ed) tsdata.internal.tsDispatchHelp('d_define_event','modal',f));
         
set(f,'Color',get(LBLtime,'Backgroundcolor'))
centerfig(f)

%% Disable calendar for rel time
if ~ischar(reftime)
    set(BTNcalendar,'Enable','off')
end

uiwait(f)

if ishghandle(f)
    name = getappdata(f,'Name');
    t = getappdata(f,'Time');
    close(f)
else
    name = '';
    t = [];
end

%--------------------------------------------------------------------------
function localOK(es,ed,f,EDITname,EDITtime,reftime)

%% Event definition dialog ok button callback
if ~isempty(reftime) && ischar(reftime) % Absolute events
    if isempty(get(EDITtime,'String'))
        errordlg(getString(message('MATLAB:timeseries:TimeCannotBeEmpty')),...
            getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal')
        return
    end
    try
        evtime = datenum(get(EDITtime,'String'))-datenum(reftime);
    catch         
        errordlg(getString(message('MATLAB:timeseries:InvalidDateStringFormat')), ...
            getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal')
        return
    end
else
    evtime = eval(get(EDITtime,'String'),'[]');
    if isempty(evtime) || length(evtime)>1 || any(isnan(evtime)) || ...
            ~all(isfinite(evtime))
        errordlg(getString(message('MATLAB:timeseries:TimeMustEvaluateToANonemptyFiniteScalar')),...
            getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal')
        return
    end    
end
%% Get name
evname = get(EDITname,'String');
if isempty(deblank(evname))
    errordlg(getString(message('MATLAB:timeseries:EventNameCannotBeEmpty')), ...
        getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal')
    return
end

%% Cache results and resume
setappdata(f, 'Name',get(EDITname,'String'));
setappdata(f,'Time',evtime);
uiresume(f)

%--------------------------------------------------------------------------
function localCancel(es,ed,f)

%% Event definition dialog cancel button callback
set(f,'Visible','off')
uiresume(f)
    
%--------------------------------------------------------------------------
function localEventCalendar(eventSrc,eventData,f,EDITtime,reftime)

%% Event definition dialog Calendar button callback

%% Get the calendar handle
thisCalendar = getappdata(f,'Calendar');
if isempty(thisCalendar)
    thisCalendar = tsguis.calendar;
    thisCalendar.Updatefcn = ...
        @(es,ed) set(EDITtime,'String',datestr(get(thisCalendar,'DateNum')));
    thisCalendar.Type = '';
    thisCalendar.DateNum = datenum(reftime); % Opens the calendar

    % Cache the handle
    setappdata(f,'Calendar',thisCalendar);
end

%% Open the calendar
thisCalendar.Visible = 'on';