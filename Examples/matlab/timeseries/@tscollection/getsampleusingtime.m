function tsc = getsampleusingtime(this,StartTime,varargin)
%GETSAMPLEUSINGTIME  Extract samples from a tscollection object between a
% specified start and end time values into a new tscollection object.
% 
% TSC2 = GETSAMPLEUSINGTIME(TSC1,TIME) returns a new tscollection TSC2 with a
% single sample corresponding to time TIME in TSC1
%
% TSC2 = GETSAMPLEUSINGTIME(TSC1,START,END) returns a new tscollection TSC2 with 
% samples between the times START and END in TS1
%
% TS2 = GETSAMPLEUSINGTIME(TSC1,TIME,'ALLOWDUPLICATETIMES',VALUE)
% You can explicitly allow the single time case to return multiple samples 
% when it coincides with a duplicate time value by adding the Property-Value
% pair: 'allowduplicatetimes',VALUE where VALUE is either true or false.
%
% Note: (1) When the time vector in TSC1 is numeric, START and END must be
% numeric. (2) When the times in TSC1 are date strings, but the START
% and END values are numeric, START and END values are treated as DATENUM values.
%
 
% Copyright 2005-2016 The MathWorks, Inc.
 
narginchk(2,5);
if isempty(this)
    tsc = this;
    return
end
 
% Parse the inputs
allowduplicatetimes = false;
if nargin == 2
    EndTime = StartTime;
elseif nargin==3
    EndTime = varargin{1};
elseif nargin==4 
    if isTimeString(varargin{1}) && strcmpi('allowduplicatetimes',varargin{1}) && isscalar(varargin{2})
        EndTime = StartTime;
        allowduplicatetimes = logical(varargin{2});
    else
        error(message('MATLAB:tscollection:getsampleusingtime:invalidpv'))
    end
end
 
if isnumeric(StartTime) && isnumeric(EndTime) && ...
        (~isscalar(StartTime) || ~isscalar(EndTime) || ~isreal(StartTime) || ...
            ~isreal(EndTime))
        error(message('MATLAB:tscollection:getsampleusingtime:noScalars'))
end
% Only work if the time vector is absolute
if isempty(this.TimeInfo.StartDate)
    % The time vector is relative for this time series object
    % in this case, start and end have to be numeric values
    if isnumeric(StartTime) && isnumeric(EndTime)
        StartIndex = find(this.Time >= StartTime);
        EndIndex = find(this.Time <= EndTime);        
    else
        error(message('MATLAB:tscollection:getsampleusingtime:noNumericStart'))
    end
else
    % The time vector is absolute for this time series object
    % in this case, if start and end are numeric values, they are treated
    % as datenum value; if start and end are strings, they are treated
    % as date strings; otherwise error out
    if (isTimeString(StartTime) && isTimeString(EndTime)) || (isnumeric(StartTime) && isnumeric(EndTime)) 
        StartValue = tsgetrelativetime(StartTime,this.TimeInfo.StartDate,this.TimeInfo.Units);
        EndValue = tsgetrelativetime(EndTime,this.TimeInfo.StartDate,this.TimeInfo.Units);
        StartIndex = find(this.Time >= StartValue);
        EndIndex = find(this.Time <= EndValue);        
    else
        error(message('MATLAB:tscollection:getsampleusingtime:invStartFormat'))
    end
end
index = intersect(StartIndex,EndIndex);
 
% Check that we are not asking for a single time value which coincides with
% a duplicate time.
if ~allowduplicatetimes && this.hasduplicatetimes && length(index)>=2
    error(message('MATLAB:tscollection:getsampleusingtime:invalidduptimes'));
end

if ~isempty(index)
    tsc = subsref(this,struct('type','()','subs',{{index}}));
else
    tsc = tscollection;
end

function isTimeString = isTimeString(time)

isTimeString = ischar(time) || (isstring(time) && isscalar(time));

