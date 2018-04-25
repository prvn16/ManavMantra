function ts = gettsbetweenevents(this,event1,event2,varargin)
% GETTSBETWEENEVENTS  Return a new timeseries object with all the samples
% occurring at and between two specified vents. 
%
%   GETTSBETWEENEVENTS(TS, EVENT1, EVENT2).  where EVENT can be either a tsdata.event
%   object or a string.  If EVENT is a tsdata.event object, the time
%   defined by EVENT is used.  If EVENT is a string, the first tsdata.event
%   object in the Events property of TS that matches the EVENT name is used
%   to specify the time.
%
%   GETTSBETWEENEVENTS(TS, EVENT1, EVENT2, N1, N2) where N is the Nth appearance of the
%   matching EVENT name for each specified event.
%
%   Note: If the time series TS contains date strings and EVENT uses
%   relative time, the time selected by the EVENT is treated as a date
%   (calculated relative to the StartDate property in the TS.TimeInfo
%   property).  If TS uses relative time and EVENT uses dates, the time
%   selected by the EVENT is treated as a relative value. 
%
%   See also TIMESERIES/GETTSAFTEREVENT, TIMESERIES/GETTSBEFOREEVENT,
%   

% Copyright 2004-2016 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:gettsbetweenevents:noarray'));
end
if nargin == 3
    index1 = utGetEventTime(this,event1,'afterAt');
    index2 = utGetEventTime(this,event2,'beforeAt');    
    index = intersect(index1,index2);
elseif nargin == 5 && (ischar(event1) || (isstring(event1) && isscalar(event1))) && ...
        (ischar(event2) || (isstring(event2) && isscalar(event2)))
    % Single string or char vector event names
    index1 = utGetEventTime(this,event1,'afterAt',varargin{1});
    index2 = utGetEventTime(this,event2,'beforeAt',varargin{2});    
    index = intersect(index1,index2);
else
    error(message('MATLAB:timeseries:gettsbetweenevents:invArgNum'))
end
if ~isempty(index)
    ts = this.getsamples(index);
else
    ts = eval(sprintf('%s;',class(this)));
    ts.Name = 'unnamed';
end