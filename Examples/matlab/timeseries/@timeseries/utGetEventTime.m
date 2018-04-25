function index = utGetEventTime(this,event,option,varargin)
%UTGETEVENTTIME

% UTGETEVENTTIME  Return an index of a subset of TS which contains all the
% samples found in the timeseries object based on the selected option.  It
% returns [] if no sample is found. 
%
%   INDEX = UTGETEVENTTIME(TS, EVENT, OPTION).  EVENT can be either a
%   tsdata.event object or a string.  If EVENT is a string, the time
%   defined in EVENT will be used as directly.  If EVENT is a string, the
%   first event in the Events property of TS, whose name is the same as
%   EVENT, will be selected as the desired time point.  OPTION can be
%   'before', 'beforeat', 'at', 'after', 'afterat', 'between' currently.
%
%   INDEX = UTGETEVENTTIME(TS, EVENT, OPTION, N).  If EVENT is a string,
%   the Nth event in a set of events in the Events property of TS, whose
%   name are the same as EVENT, will be selected as the desired time point.
%
%   Note: if TS object uses absolute date and EVENT uses relative time, the
%   time point indicated by EVENT will be treated as an absolute date
%   relative to the StartDate property in the TS.TimeInfo property.  if TS
%   object uses relative time and EVENT uses absolute date, the time point
%   indicated by EVENT will be treated as a relative value without using
%   the StartDate property in EVENT. 
%   
 
% Copyright 2006-2016 The MathWorks, Inc.

if this.Length==0
    index = [];
    return
end

% User can select which one of the events to use if there are events with
% same names.  By default, the first one is always used.
if nargin == 4
    pick_which_dups = varargin{1};
else
    pick_which_dups = 1;
end

% If user provides event name instead of event object, find the
% corresponding event object in the Events property
if ischar(event) || (isstring(event) && isscalar(event))
    % use name of the event, assuming that the event object is already
    % stored in the Events property of the time series object
    if isempty(this.Events)
        error(message('MATLAB:timeseries:utGetEventTime:noEvents'));
    else
        event = findEvent(this.Events,event,pick_which_dups);
    end
    if isempty(event)
        index = [];
        return;
    end
elseif ~isa(event,'tsdata.event')
    error(message('MATLAB:timeseries:utGetEventTime:noTime'));
end
    
%% deal with different time format
if isempty(this.TimeInfo.StartDate) && isempty(event.StartDate)
    % both relative time
    eTime = event.Time*tsunitconv(this.TimeInfo.Units,event.Units);
elseif ~isempty(this.TimeInfo.StartDate) && ~isempty(event.StartDate)
    % both absolute time
    tmpT = timeseries.tsgetrelativetime(event.StartDate,this.TimeInfo.StartDate,...
        this.TimeInfo.Units);
    eTime = event.Time*tsunitconv('days',event.Units)+ tmpT;
elseif isempty(this.TimeInfo.StartDate) && ~isempty(event.StartDate)
    % relative time series and absolute event, treat event as relative
    eTime = event.Time*tsunitconv(this.TimeInfo.Units,event.Units);
elseif ~isempty(this.TimeInfo.StartDate) && isempty(event.StartDate)
    % absolute time series and relative event, treat event as absolute
    % using time series start date
    eTime = event.Time*tsunitconv(this.TimeInfo.Units,event.Units);
end

switch option
    case 'before'
        index = find(this.Time < eTime);
    case 'beforeAt'
        index = find(this.Time <= eTime);
    case 'after'
        index = find(this.Time > eTime);
    case 'afterAt'        
        index = find(this.Time >= eTime);
    case 'at'
        index = find(this.Time == eTime);
    case 'notAt'
        index = find(this.Time ~= eTime);
    otherwise
        error(message('MATLAB:timeseries:utGetEventTime:invOption'));
end