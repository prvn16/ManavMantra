function this = addevent(ts,e,varargin)
%ADDEVENT  Add event objects to a time series object.
%
%   ADDEVENT(TS,E) adds an array of tsdata.event objects E to the EVENTS
%   property of the time series TS.    
%
%   ADDEVENT(TS,NAME,TIME) constructs one or more tsdata.event objects and
%   add them to the EVENTS property of the time series TS. NAME is a cell
%   array of event name strings. TIME is a cell array of event times.
%
%   Adding duplicate events will have no effect.
%
%   Example
%
%   Create a time series object:
%   ts = timeseries(rand(5,4))
%
%   Create event objects called 'e1' and 'e2' where the event occurs at
%   time 3 and 4 respectively: 
%   e1 = tsdata.event('e1',3)
%   e2 = tsdata.event('e2',4)
%
%   View the properties (EventData, Name, Time, Units, StartDate) of the
%   event object: 
%   get(e1)
%
%   Add the event object to the time series object TS:
%   ts = addevent(ts,[e1 e2])
%   
%   An alternative way to add events is
%   ts = addevent(ts,{'e1' 'e2'},{3 4})
%
%   See also TIMESERIES/TIMESERIES

%   Copyright 2005-2016 The MathWorks, Inc.

this = ts;
if numel(this)~=1
    error(message('MATLAB:timeseries:addevent:noarray'));
end
if nargin==2
    % Check that the event is a valid singleton
    if isempty(e) % Ignore empty events
        return
    end
    if ~isa(e,'tsdata.event')
        error(message('MATLAB:timeseries:addevent:badtype'))
    end

    % Add events one at a time
    for k=1:length(e)
        this = localAddEvent(this,e(k));
    end
% Creating event object from name and time
elseif nargin==3
    time = varargin{1};
    if iscell(e)
        % Find indices of strings or char arrays
        p = cellfun('isclass',e,'char') | cellfun('isclass',e,'string');
        if ~all(p(:))
            error(message('MATLAB:timeseries:addevent:cellarrayname'))
        end
        if ~iscell(time)
            error(message('MATLAB:timeseries:addevent:times'))
        end
        if ~isequal(size(e),size(time))
            error(message('MATLAB:timeseries:addevent:size'))
        end
        % Add events one at a time
        for k=1:length(e)
            obj = tsdata.event(e{k},time{k});
            if isnumeric(time{k})
                obj.Units = this.Timeinfo.Units;
                obj.StartDate = this.Timeinfo.startDate;
            end
            this = localAddEvent(this,obj);
        end
    elseif ischar(e) || isstring(e)
        if size(e,1)>1
            error(message('MATLAB:timeseries:addevent:name'))
        else
            obj = tsdata.event(e,time);
            if isnumeric(time)
                obj.Units = this.Timeinfo.Units;
                obj.StartDate = this.Timeinfo.startDate;
            end
            this = localAddEvent(this,obj);
        end
    else
        error(message('MATLAB:timeseries:addevent:name'))
    end
end


function ts = localAddEvent(ts,e)
% Adds events one at a time

% Check for duplication
if ~isempty(ts.Events) 
    if ~any(e==ts.Events)
        ts.Events = [ts.Events, e];
    end
else
    ts.Events = e;
end

