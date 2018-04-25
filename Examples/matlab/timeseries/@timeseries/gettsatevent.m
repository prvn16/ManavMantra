function ts = gettsatevent(this,event,varargin)
% GETTSATEVENT  Return a new timeseries object with all the samples
% occurring at the time of the specified event.  
%
%   GETTSATEVENT(TS, EVENT) where EVENT can be either a tsdata.event
%   object or a string.  If EVENT is a tsdata.event object, the time
%   defined by EVENT is used.  If EVENT is a string, the first tsdata.event
%   object in the Events property of TS that matches the EVENT name is used
%   to specify the time. 
%
%   GETTSATEVENT(TS, EVENT, N) where N is the Nth appearance of the
%   matching EVENT name.
%
%   Note: If the time series TS contains date strings and EVENT uses
%   relative time, the time selected by the EVENT is treated as a date
%   (calculated relative to the StartDate property in the TS.TimeInfo
%   property).  If TS uses relative time and EVENT uses dates, the time
%   selected by the EVENT is treated as a relative value. 
%
%   See also TIMESERIES/GETTSAFTEREVENT, TIMESERIES/GETTSBEFOREEVENT,
%   TIMESERIES/GETTSBETWEENEVENTS
%   

% Copyright 2005-2016 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:tsgettsatevent:noarray'));
end
if nargin == 2
    index = utGetEventTime(this,event,'at');
elseif nargin == 3 && (ischar(event) || (isstring(event) && isscalar(event)))
    % Single string or char vector event name
    index = utGetEventTime(this,event,'at',varargin{1});
else
    error(message('MATLAB:tsgettsatevent:invArgNum'))
end
if ~isempty(index)
    ts = this.getsamples(index);
else
    ts = eval(sprintf('%s;',class(this)));
    ts.Name = 'unnamed';
end