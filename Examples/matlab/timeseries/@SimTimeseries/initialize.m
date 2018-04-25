function this =     initialize(this, ...
                    name,~,~,~,~, ...
                    data, time, starttimes, interval, endtimes, framesize, ...
                    regionInfo) %#ok<INUSD>

%
%   Copyright 2004-2011 The MathWorks, Inc.

%INITIALIZE
% Input arguments
% DATA: Time series ordinate data. If the time series is frame based the
% data matrix will be n x framesize. Note that data can be a cell array
% containing the arguments of the constructor for the data instead of the
% data itself. In this case the time series data storage object will store
% the constructor and postpone building the data set until it is accessed.
%
% TIME: Time vector if the data is irregularly sampled. If time is
% regularly sampled this argument must be empty
%
% START: Vector of start times for regularly sampled data or enabled
% subsystems. 
%
% ENDTIMES: Vector of end times for regularly sampled data or enabled subsystems
%
% FRAMESIZE: Assumed frame size. If this is non-empty a frame based time
% series will be created. If empty a non frame based time series will be
% created.

%   Copyright 2004-2011 The MathWorks, Inc.
%

% Turn off time/data compatibility checking
this.BeingBuilt = true;

% Assign name
if ~isempty(name) && ischar(name) 
     set(this,'Name',name);      this.Name = name; 
else
     set(this,'Name','');      this.Name = name; 
end 


% Empty data means signal was not logged
if isempty(data),
  data = [];
  time = [];
  starttimes = [];
  endtimes   = [];
end
  
% Validate arguments
localValidateInterval(starttimes,endtimes)    

% Initialize time/frame metadata
if ~isempty(framesize) %This time series is frame based
    % Frame based time series must have uniform time vectors so a time
    % vector should not be specified
    if ~isempty(time)
        error(message('MATLAB:SimTimeseries:initialize:noirregtime'))
    end
    newTimeInfo = Simulink.FrameInfo;
    newTimeInfo.Framesize = framesize;
    newTimeInfo.FrameStart = starttimes;
    newTimeInfo.FrameEnd = endtimes;
    newTimeInfo.FrameIncrement = interval;
    newTimeInfo = update(newTimeInfo); %Assign the @TimeInfo props
    newTimeInfo.Time_ = [];
else % Build TimeInfo for non frame based non-uniform time
    % Populate start,end and interval for the Timemetatdata case only  
    newTimeInfo = Simulink.TimeInfo;
    newTimeInfo.Start = starttimes;
    newTimeInfo.End = endtimes;
    % Build the timeInfo
    if ~isempty(time),
       newTimeInfo.Increment = NaN;
       newTimeInfo.Time_ = time;
    else
       %this.Time = []; % This will build data storage 
       newTimeInfo.Increment = interval;
    end
end
this.TimeInfo = newTimeInfo;

% Calculate IsTimeFirst from the stored data characteristics
if iscell(data)
    this.Storage_ = Simulink.TimeseriesDataConstructor(data);
    % Temporary fix, which used the constructor cell array to pre-assign
    % the IsTimeFirst property. A more general means of determining
    % IsTimeFirst must be found for externally stored data.
    this.IsTimeFirst = ~(length(data)>=2 && ndims(data{2})>=3);
else  
    % Modified to make it consistent with base timeseries model, which
    % also generate the right sample size
    % more than 1 samples, therefore data must be a vector, ndims>=2
    if this.Length>1
        s = size(data);
        % If data size is greater than 2, always use IsTimeFirst false
        if ndims(data)>2
            if s(end)==this.Length 
                this.IsTimeFirst = false;
            else
                error(message('MATLAB:SimTimeseries:initialize:wrongdatasize'))
            end
        end
    % Only 1 sample, therefore data must be a vector, ndims>=2
    elseif this.Length==1
        % If data is a scalar or a row vector, IsTimeFirst = true,
        % otherwise, false
        this.IsTimeFirst = isscalar(data) || ...
            (isvector(data) && size(data,1)==1);
    end
    this.Data = data;
end

% Add enable/disable events. Do not use addEvent because of the overhead of
% checking for event equality.
if ~isempty(starttimes)
    for k=length(starttimes):-1:1
        eventArray(2*k-1) = tsdata.event('Simulink:enable',starttimes(k));
        eventArray(2*k-1).EventData = k;
        eventArray(2*k) = tsdata.event('Simulink:disable',endtimes(k));
        eventArray(2*k).EventData = k;
    end 
    this.Events = eventArray;
end
    

% Restore time/data compatibility checking
this.BeingBuilt = false;

function localValidateInterval(starttimes,endtimes)

if isempty(starttimes) && isempty(endtimes)
    return
end
if ~all(isnumeric(starttimes)) || ~all(isnumeric(endtimes)) || length(starttimes)<1 || ...
        length(endtimes)<1 || length(starttimes)~=length(endtimes) || ...
        ~all(isfinite(endtimes)) || ~all(isfinite(starttimes))
    error(message('MATLAB:SimTimeseries:initialize:invinterval'))
end % valid arg chk
