function this = addsampletocollection(this,varargin)
%ADDSAMPLETOCOLLECTION  Add sample(s) to a time-series collection
%
%   TSC = ADDSAMPLETOCOLLECTION(TSC, 'TIME', TIME, TS1NAME, TS1DATA, ...,
%   TSnNAME, TSnDATA)
%   adds data samples TSnDATA to a member TSnNAME in the tscollection TSC
%   at the time(s) TIME. Here, TSnNAME is the string that represents the name
%   of a time series in TSC, and TSnDATA is a data array. Note: If you do not
%   specify data samples for a time series member in TSC, that times series
%   member will contain missing data at time(s) TIME: (for numerical
%   time-series data) NaN values, or (for logical time-series data) FALSE
%   values.        
%
%   To specify quality together with the data samples (for a time series
%   member that requires quality values), use the following syntax: 
%
%   TSC = ADDSAMPLETOCOLLECTION(TSC, 'TIME', TIME, TS1NAME, TS1CELLARRAY, TS2NAME, TS2CELLARRAY, ...)
%   You specify data in the first element of cell array, and the quality in
%   the second cell array element.   

%   TIME must be a vector of valid times. A valid data array has the
%   following characteristics: if TS.IsTimeFirst is TRUE, data size is
%   N-by-SampleSize (where N is the length of the samples and SampleSize
%   equals TS.getSampleSize); if TS.IsTimeFirst is FALSE, data size is
%   SampleSize-by-N. The 'Quality' value must be either: 1. an integer, in
%   which case this value is applied to all data samples, or 2. an array of
%   integers such that its size matches the time series data size.
%
%   TSC = ADDSAMPLETOCOLLECTION(TSC, 'TIME', TIME, TS1NAME, TS1DATA, ..., 'OVERWRITEFLAG', FLAG)
%   includes an extra parameter, FLAG, which is a logical value. When the
%   time(s) of the new samples already exist in TS, the old samples will be
%   overwritten by the new samples when the OverwriteFlag is set TRUE.
%   Otherwise, an error message will be generated.
%
%   See also TSCOLLECTION/TSCOLLECTION,
%   TSCOLLECTION/DELSAMPLEFROMCOLLECTION

% Copyright 2005-2016 The MathWorks, Inc.

% Convert the input pv pair into a struct if necessary
narginchk(2,inf);
ni = nargin-1;
data = [];
time = [];
quality = [];
overwriteFlag = false;
tsnames = gettimeseriesnames(this);  
if nargin>2
    % PV pair case
    for i=1:2:ni
        % Set each Property Name/Value pair in turn. 
        Property = varargin{i};
        if i+1>ni
            error(message('MATLAB:tscollection:addsampletocollection:pv1'))
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(char(Property))
            case 'time'
                time = Value;
                if isempty(time)
                    error(message('MATLAB:tscollection:addsampletocollection:notime'))
                end
            case 'overwriteflag'
                overwriteFlag = Value;
            otherwise
                [isTsObject,index] = ismember(char(Property),tsnames);
                if isTsObject
                    if iscell(Value)
                        if length(Value)~=2
                            error(message('MATLAB:tscollection:addsampletocollection:cell'))
                        end
                        % Add both data and quality
                        data.(char(Property)) = Value{1};
                        quality.(char(Property)) = Value{2};
                    else
                        % Add data only
                        data.(char(Property)) = Value;
                        quality.(char(Property)) = [];
                        thists = getts(this,char(Property));
                        if ~isempty(thists.Quality)
                            quality.(char(Property)) = interp1(thists.Time,...
                                thists.Quality,time,'nearest','extrap');
                        end
                    end
                    tsnames(index) = [];
                else
                    error(message('MATLAB:tscollection:addsampletocollection:pv2'))
                end
       end % switch
    end % for
    % Initialize data for remaining (unspecified) time series
    % Rule for filling: if numeric, use NaN, if logical, use false, for
    % quality use nearest
    for i=1:length(tsnames)
        thists = getts(this,tsnames{i});
        if isnumeric(thists.Data)
            SampleSize = getdatasamplesize(thists);
            tmp = [ones(1,length(SampleSize)) length(time(:))];
            if thists.IsTimeFirst
                data.(tsnames{i}) = shiftdim(repmat(NaN(SampleSize),tmp),length(SampleSize)); %#ok<RPMTN>
            else
                data.(tsnames{i}) = repmat(NaN(SampleSize),tmp); %#ok<RPMTN>
            end
        elseif islogical(thists.Data)
            SampleSize = getdatasamplesize(thists);
            tmp = [ones(1,length(SampleSize)) length(time(:))];
            if thists.IsTimeFirst
                data.(tsnames{i}) = shiftdim(repmat(false(SampleSize),tmp),length(SampleSize)); %#ok<RPMTF>
            else                
                data.(tsnames{i}) = repmat(false(SampleSize),tmp); %#ok<RPMTF>
            end
        end
        if ~isempty(thists.Quality)
            quality.(tsnames{i}) = interp1(thists.Time,thists.Quality,time,'nearest','extrap');
        else
            quality.(tsnames{i}) = [];
        end
    end
else
    % Struct case
    s = varargin{1};
    if ~isa(s,'struct') || ~isscalar(s)
        error(message('MATLAB:tscollection:addsampletocollection:pv4'))
    end
    % Analyze the input struct and get the value out of the struct
    if isfield(s,'Time')
        time = s.('Time');
    elseif isfield(s,'time')
        time = s.('time');
    else
        error(message('MATLAB:tscollection:addsampletocollection:notime'))
    end
    if isempty(time)
        error(message('MATLAB:tscollection:addsampletocollection:notime'))
    end
    if isfield(s,'OverwriteFlag')
        overwriteFlag = s.('OverwriteFlag');
    elseif isfield(s,'overwriteflag')
        overwriteFlag = s.('overwriteflag');
    end
    for i=1:length(tsnames)
        if isfield(s,tsnames{i})
            if iscell(s.(tsnames{i}))
                if length(s.(tsnames{i}))~=2
                    error(message('MATLAB:tscollection:addsampletocollection:cell'))
                end
                % Add both data and quality
                data.(tsnames{i}) = s.(tsnames{i}){1};
                quality.(tsnames{i}) = s.(tsnames{i}){2};
            else
                data.(tsnames{i}) = s.(tsnames{i});
                quality.(tsnames{i}) = [];
                thists = getts(this,tsnames{i});
                if ~isempty(thists.quality)   
                    quality.(tsnames{i}) = interp1(thists.Time,thists.Quality,time,'nearest','extrap');
                else
                    quality.(tsnames{i}) = [];
                end
            end
        else
            thists = getts(this,tsnames{i});
            SampleSize = getdatasamplesize(thists);
            if isnumeric(thists.Data)          
                tmp = [ones(1,length(SampleSize)) length(time(:))];
                if thists.IsTimeFirst                
                    data.(tsnames{i}) = shiftdim(repmat(NaN(SampleSize),tmp),length(SampleSize)); %#ok<RPMTN>
                else
                    data.(tsnames{i}) = repmat(NaN(SampleSize),tmp); %#ok<RPMTN>
                end
            elseif islogical(thists.Data)
                tmp = [ones(1,length(SampleSize)) length(time(:))];               
                if thists.IsTimeFirst
                    data.(tsnames{i}) = shiftdim(repmat(false(SampleSize),tmp),length(SampleSize)); %#ok<RPMTF>
                else
                    data.(tsnames{i}) = repmat(false(SampleSize),tmp); %#ok<RPMTF>
                end
            end
            if ~isempty(thists.Quality)
                quality.(tsnames{i}) = interp1(thists.Time,thists.Quality,time,'nearest','extrap');
            else
                quality.(tsnames{i}) = [];
            end
            
        end
    end
end

% Add time points only
tsnames = gettimeseriesnames(this);
if isempty(tsnames)
    % get time
    [time, timeLength] = localParseTime(this,time);
    % Time series is pseudo-empty
    if this.length == 0
        this = this.init(time);
    % Time series is not empty
    else
        for i=1:timeLength
            % Get the timestamp characteristics of the new sample
            idx = localFindTime(this,time(i));
            this = localAddTime(this,time(i),idx);
        end
    end
else 
    % Apply addsample on each timeseries member
    thisTsArray = cell(length(tsnames),1);
    for i=1:length(tsnames)  
        thisTsArray{i} = getts(this,tsnames{i});
        if isempty(quality.(tsnames{i}))
            thisTsArray{i} = addsample(thisTsArray{i},'Data',data.(tsnames{i}),'Time',...
                time,'OverwriteFlag',overwriteFlag);
        else
            thisTsArray{i} = addsample(thisTsArray{i},'Data',data.(tsnames{i}),'Time',...
                time,'Quality',quality.(tsnames{i}),'OverwriteFlag',overwriteFlag);
        end
    end
    
    % Update the tscollection time vector length
    this.TimeInfo = setlength(this.TimeInfo,thisTsArray{i}.TimeInfo.Length);
    this.Time  = thisTsArray{1}.Time;
    % Update the members
    for i=1:length(tsnames)
        this = setts(this,thisTsArray{i},tsnames{i});
    end
end

function [time, len] = localParseTime(this,timein)

% Convert cell arrays which contain strings to cellstrs
cellstrTime = iscellstr(timein);
if ~cellstrTime && iscell(timein) && any(cellfun('isclass',timein,'string'))
    timein = cellstr(timein);
    cellstrTime = true;
end
if ischar(timein) || cellstrTime || isstring(timein)
    % sample length equals the number of rows
    len = size(timein,1);
    % if time series object requires relative time points, error out
    if isempty(this.Timeinfo.Startdate)
        time = timein;
    % otherwise, get time values relative to the StartDate and Units values
    else    
        time = tsAnalyzeAbsTime(timein,this.Timeinfo.Units,this.Timeinfo.Startdate);
    end
elseif isnumeric(timein)
    % sample length equals the number of rows
    if isvector(timein)
        len = length(timein);
        % make sure time is a column vector
        if size(timein,2) > 1
            time = timein';
        else
            time = timein;
        end
    else
        error(message('MATLAB:tscollection:localParseTime:badtime'));
    end
else
    error(message('MATLAB:tscollection:localParseTime:badformat'));
end


% -----------------------------------------------------------------------
% subroutine : get the time stamp information for the new sample
% output argument 1: a boolean variable. TRUE means the same timestamp
% already exists which means an updating case, FALSE means the timestamp i
% a new one, which implies either an appending case or an inserting case.
% output argument 2: an integer. If it is an updating case, it stores the
% index of the timestamp in the timeseries. If it is an appending case, its
% value is Inf.  If it is an inserting case, its value is the index of the
% closest timestamp which is larger than the new timestamp.
% NOTE: this function is only used when the original timeseries is not
% empty.
% -----------------------------------------------------------------------
function idx = localFindTime(this,time)

if this.Timeinfo.Length==0
    idx = 1;
    return
end
if isfinite(this.TimeInfo.Increment)
    % The original timeseries is uniformly sampled
    if time>=this.TimeInfo.Start && time<=this.TimeInfo.End
        % timestamp is within the time range of the original timeseries
        if isequal((time-this.TimeInfo.Start)/this.TimeInfo.Increment,...
                round((time-this.TimeInfo.Start)/this.TimeInfo.Increment))
            % timestamp already exists in a uniformly sampled timeseries,
            % return the index
            idx = (time-this.TimeInfo.Start)/this.TimeInfo.Increment+1;
        else
            % timestamp does not exist in a uniformly sampled timeseries,
            % return the index of the timestamp immediately larger than the
            % new timestamp
            idx = ceil((time-this.TimeInfo.Start)/this.TimeInfo.Increment)+1;
        end            
    else
        % timestamp is beyond the time range of the original timeseries
        if time<this.TimeInfo.Start
            % Return 1 if the timestamp is smaller than the first timestamp
            % in the timeseries.
            idx = 1;
        else
            % Return Inf if the timestamp is larger than the last timestamp
            % in the timeseries.
            idx = Inf;
        end
    end
else
    % the original timeseries is non-uniformly sampled
    if time>=this.TimeInfo.Start && time<=this.TimeInfo.End %time<=this.time(end)
        % timestamp is within the time range of the original timeseries
        originalTime = this.Time;
        idx = find(originalTime==time);
        if isempty(idx)
            % timestamp does not exist in the timeseries, return the index
            % of the timestamp immediately larger than the new timestamp
            idx = find(originalTime>time,1);
        end
    else
        % timestamp is beyond the time range of the original timeseries
        if time<this.TimeInfo.Start
            % return 1 if the timestamp is smaller than the first timestamp
            % in the timeseries.
            idx = 1;
        else
            % return Inf if the timestamp is larger than the last timestamp
            % in the timeseries.
            idx = Inf;
        end
    end
end


% -----------------------------------------------------------------------
% subroutine : append/insert/update a sample into the timeseries
% if the original timeseries is NOT uniformly sampled, add the sample
% first and changes will automatically happen if the timeseries becomes
% a uniformly sampled one after the addition operation.  vice versa
% -----------------------------------------------------------------------
function this = localAddTime(this,time,idx)

% Empty case or append case
this.TimeInfo = setlength(this.TimeInfo,this.TimeInfo.Length+1);
if ~isfinite(idx)    
    if ~isfinite(this.TimeInfo.Increment) || time-this.TimeInfo.End~=this.TimeInfo.Increment
        % Not Uniformly before and uniformly after
        this.Time = [this.Time; time];
    end
else
    tempTime = this.Time;
    if idx>1
        this.Time = [tempTime(1:idx-1);time;tempTime(idx:end)];
    else
        this.Time = [time;tempTime];
    end
end