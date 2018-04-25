function this = delevent(ts,event,varargin)
%DELEVENT  Remove event objects from a time series object.
%
%   TS = DELEVENT(TS, EVENT), where EVENT is an event name string, removes the
%   corresponding tsdata.event object from TS.EVENTS property. 
%
%   TS = DELEVENT(TS, EVENTS), where EVENTS is a cell array of event name
%   strings, removes tsdata.event objects from the TS.EVENTS property.
%
%   TS = DELEVENT(TS, EVENT, N) removes the Nth tsdata.event object, whose
%   name is EVENT, from the TS.EVENTS property.
%
%   Example
%
%   Create a time series:
%   ts=timeseries(rand(5,4))
%
%   Create an event object called 'test' where the event occurs at time 3:
%   e=tsdata.event('test',3)
%
%   Add the event object to time series TS:
%   ts = addevent(ts,e)
%
%   Remove the event object from time series TS:
%   ts = delevent(ts,'test')
%
%   See also TIMESERIES/TIMESERIES, TIMESERIES/ADDEVENT

% Copyright 2005-2011 The MathWorks, Inc.


% User can select which one of the events to use if there are events with
% same names.  By default, the first one is always used.

this = ts;
if nargin == 3
    pick_which_dups = varargin{1};
else
    pick_which_dups = 1;
end

if numel(this)~=1
    error(message('MATLAB:timeseries:delevent:noarray'));
end

if isempty(this.Events)
    error(message('MATLAB:timeseries:delevent:noevents'));
end

% If user provides event name instead of event object, find the
% corresponding event object in the Events property
if ischar(event)
    % use name of the event, assuming that the event object is already
    % stored in the Events property of the time series object
    [~, index] = findEvent(this.Events,event,pick_which_dups);
    if index~=0
        this.Events(index) = [];
    end
elseif iscell(event) && all(cellfun('isclass',event(:),'char'))
    % use name of the event, assuming that the event object is already
    % stored in the Events property of the time series object
    for i=1:length(event(:))
        [~, index] = findEvent(this.Events,event{i},pick_which_dups);
        if index~=0
            this.Events(index) = [];
        end
    end
else
    error(message('MATLAB:timeseries:delevent:invalidname'));
end  
