function this = delsample(this,method,value)
%DELSAMPLE  Delete one or more samples from a timeseries object
%
%   TS = DELSAMPLE(TS,'Index',VALUE) removes samples from the timeseries 
%   object TS. Here, VALUE specifies the indices of the TS time vector that
%   correspond to the samples you want to remove.
%   
%   TS = DELSAMPLE(TS,'Value',VALUE) removes samples from the time series 
%   object TS. Here, VALUE specifiers the time values that correspond to the
%   samples you want to remove.  
%
%   See also TIMESERIES/TIMESERIES, TIMESERIES/ADDSAMPLE

%   Copyright 2005-2016 The MathWorks, Inc.


TimeValue = this.Time;

if isempty(value)
    return;
end

if numel(this)~=1
    error(message('MATLAB:timeseries:delsample:noarray'));
end

% Process command
if (ischar(method) && isvector(method)) || (isstring(method) && isscalar(method))
    % Single char vector or single string
    switch lower(char(method))
        case 'index'
            if ~isnumeric(value) || ~isvector(value)
                error(message('MATLAB:timeseries:delsample:invalidindex'));
            else
                % Make sure indices are unique
                selectedIndexArray = unique(value);
                % Check if all the indices are valid    
                if ~isequal(round(selectedIndexArray),selectedIndexArray)
                    error(message('MATLAB:timeseries:delsample:nonintegerindex'))
                elseif any(selectedIndexArray <= 0) || any(selectedIndexArray > this.Length)
                       error(message('MATLAB:timeseries:delsample:outofboundsindex'))
                end
                
            end
        case 'value'
            % If it is an array of char or strings (absolute date(s))
            if ischar(value) || iscell(value) || isstring(value)
                % If time series object requires relative time points, error out
                if isempty(this.Timeinfo.StartDate)
                    error(message('MATLAB:timeseries:delsample:nostartdate'));
                end
                % Otherwise, get time values relative to the StartDate and Units values
                try
                    value = tsAnalyzeAbsTime(value,this.Timeinfo.Units,...
                        this.Timeinfo.Startdate);
                catch                     %#ok<*CTCH>
                    error(message('MATLAB:timeseries:delsample:timeconversion'))
                end
                selectedIndexArray = ismember(round(TimeValue(:) *1e10),round(value(:) * 1e10));
            elseif isnumeric(value) && isvector(value)
                selectedIndexArray = ismember(TimeValue(:),value(:));
            else
                error(message('MATLAB:timeseries:delsample:invalidtime'));
            end
            if isempty(selectedIndexArray)
                return;
            end
        % case 'nearest'
            % TO DO
        otherwise
            error(message('MATLAB:timeseries:delsample:unrecognizedmethod'))
    end
else
    error(message('MATLAB:timeseries:delsample:invalidmethod'))
end

beingBuiltCache = this.BeingBuilt;
tempIstimeFirst = this.IsTimeFirst;
sampleSize = this.getdatasamplesize;
this.BeingBuilt = true;
% Update timeInfo
if isa(this.TimeInfo,'tsdata.internal.commontimedata')
    [this.TimeInfo,this.DataInfo] = setlength(this.TimeInfo,this.Length-length(selectedIndexArray));
else
    this.TimeInfo = setlength(this.TimeInfo,this.TimeInfo.Length-length(selectedIndexArray));
end
% Update data for grid variables
TimeValue(selectedIndexArray) = [];
this.Time = TimeValue;

% Update data for dependent values
is = repmat({':'},[1 length(sampleSize)]);
if tempIstimeFirst %this.IsTimeFirst
    tempIndex = [{selectedIndexArray} is];
else
    tempIndex = [is {selectedIndexArray}];
end
tmpData = this.Data;
tmpData(tempIndex{:}) = [];
this.Data = tmpData;
if ~isempty(this.Quality)
    this.Quality(selectedIndexArray) = [];
end
this.BeingBuilt = beingBuiltCache;

