function this = addsample(this,varargin)
% ADDSAMPLE  Add one or more samples to a timeseries object.
%
%   TS = ADDSAMPLE(TS, 'FIELD1', VALUE1, 'FIELD2', VALUE2) where one
%   of the fields must be 'Time' and the other field must be 'Data'.
%   The time VALUE must be a valid time vector. The size of the data VALUE
%   must be equal to getSampleSize(TS). When TS.IsTimeFirst is true, the
%   size of the data is N-by-SampleSize. When TS.IsTimeFirst is false, the
%   size of the data is SampleSize-by-N. For example,
%
%   ts=addsample(ts,'Time',3,'Data',3.2);
%
%   TS = ADDSAMPLE(TS,S) adds new sample(s) stored in a structure S to the
%   timeseries TS. S specifies the new sample as a collection of variable
%   name/value pairs. 
%
%   TS = ADDSAMPLE(TS, 'FIELD1', VALUE1, 'FIELD2', VALUE2, ...) where ...
%   indicates additional FIELD-VALUE pairs using the following FIELDS:
%       'Quality': an array of Quality codes (for more information, type help tsprops)
%       'OverwriteFlag': a logical value that control how to handle
%                        duplicated times. When true, the new samples will
%                        overwrite old samples defined at the same times.
%   For example:         
%
%   ts=addsample(ts,'Data',3.2,'Quality',1,'OverwriteFlag',true,'Time',3);
%
%   See also TIMESERIES/TIMESERIES, TIMESERIES/DELSAMPLE

% Copyright 2004-2016 The MathWorks, Inc.

if numel(this)~=1
    error(message('MATLAB:timeseries:addsample:noarray'));
end
    
try
    % Get time series sample size
    [tsDataSampleSize,tsQualitySampleSize] = getdatasamplesize(this);

    % Parse inputs
    % Convert the input pv pair into a struct if necessary
    ni = nargin-1;
    data = [];
    time = [];
    quality = [];
    overwriteFlag = [];
    if nargin>2
        % PV pair case
        for i=1:2:ni
            % Set each Property Name/Value pair in turn. 
            Property = varargin{i};
            if i+1>ni
                error(message('MATLAB:timeseries:addsample:pvsetNoValue'))
            else
                Value = varargin{i+1};
            end
            % Perform assignment
            switch lower(char(Property))
                case 'data'
                    data = Value;
                case 'time'
                    time = Value;
                case 'quality'
                    quality = Value;
                case 'overwriteflag'
                    overwriteFlag = Value;
                otherwise
                    error(message('MATLAB:timeseries:addsample:pvsetInvalid'))
           end % switch
        end % for
    else
        % struct case
        s = varargin{1};
        if ~isa(s,'struct') || ~isscalar(s)
            error(message('MATLAB:timeseries:addsample:noSampleStruct'))
        end
        % Analyze the input struct and get the value out of the struct
        % data
        if isfield(s,'Data')
            data = s.('Data');
        elseif isfield(s,'data')
            data = s.('data');
        else
            error(message('MATLAB:timeseries:addsample:dataMissing'))
        end
        if isfield(s,'Time')
            time = s.('Time');
        elseif isfield(s,'time')
            time = s.('time');
        else
            error(message('MATLAB:timeseries:addsample:timeMissing'))
        end
        if isfield(s,'Quality')
            quality = s.('Quality');
        elseif isfield(s,'quality')
            quality = s.('quality');
        end
        if isfield(s,'OverwriteFlag')
            overwriteFlag = s.('OverwriteFlag');
        elseif isfield(s,'overwriteflag')
            overwriteFlag = s.('overwriteflag');
        end
    end
    if isempty(data)
        error(message('MATLAB:timeseries:addsample:emptyData'))
    end
    if isempty(time)
        error(message('MATLAB:timeseries:addsample:emptyTime'))
    end


    % Verify all the input information in the correct FORMAT
    % 1. Convert abs times to numeric
    [time, timeLength] = localParseTime(this,time,tsDataSampleSize);
    % 2. Make sure the data variable is good    
    [data, dataSampleSize] = localParseData(data,this.IsTimeFirst,tsDataSampleSize,timeLength);
    % 3. make sure the quality variable is good, if any
    [quality, qualitySampleSize] = localParseQuality(this,quality,timeLength,time);
    % 4. get overwrite flag if any
    if isempty(overwriteFlag)
        overwriteFlag = false;
    elseif ~isscalar(overwriteFlag) || ~islogical(overwriteFlag)
        error(message('MATLAB:timeseries:addsample:overwriteFlg'));
    end

    % 5. calculate data sample
    %% Add sample
    % If the original timeseries already defines sample size, check whether the
    % new data size is compatible with the sample size. if the original 
    % timeseries doesn't define sample size, a.k.a. it is truly empty, use
    % the new sample size for the timeseries.  
    % NOTE: in any case, isTimeFirst property can not be changed

    % the original timeseries is either non-empty or all the samples have been
    % deleted (pseudo-empty).  
    if ~isempty(tsDataSampleSize)
        % If sample sizes are not compatible, error out
        if ~isequal(tsDataSampleSize,dataSampleSize)
            error(message('MATLAB:timeseries:addsample:datasamplesize'));
        end
        if ~isequal(tsQualitySampleSize,qualitySampleSize)
            error(message('MATLAB:timeseries:addsample:qualitysamplesize'))
        end
        % Time series is pseudo-empty, use init to repopulate
        %Ind = zeros(1,timeLength);
        if this.Length == 0
            this = this.init(data,time,quality);
        % Time series is not empty
        else
            for i=1:timeLength
                % Get the timestamp characteristics of the new sample
                [replaceTime,matchingTimeInd] = localFindTime(this,time(i));
                % Check if it is a new time stamp
                if replaceTime && ~overwriteFlag 
                    % If we are adding samples and this time matches existing
                    % time(s), then adding this time is equivalent to
                    % an insert at index max(matchingTimeInd)+1 
                    matchingTimeInd = max(matchingTimeInd)+1;
                    if matchingTimeInd>this.Length
                        matchingTimeInd = inf;
                    end
                    replaceTime = false;
                end
                % Otherwise, add data one by one
                singleData = localGetData(data,i,this.IsTimeFirst,dataSampleSize);
                singleQuality = localGetQuality(quality,i,this.IsTimeFirst,qualitySampleSize);
                this = localAddData(this,singleData,time(i),singleQuality, ...
                    tsDataSampleSize,tsQualitySampleSize,replaceTime,matchingTimeInd);
            end
        end
    % The original timeseries is truly empty, use init to repopulate
    else
        % if the timeseries is truly empty (0x0) add any dimensionality of
        % data
        if isempty(this.Data) && isequal(size(this.Data), [0 0])
            this = this.init(data,time,quality);
        else
            
            if this.IsTimeFirst
                this = this.init(data,time,quality,'IsTimeFirst',true);
            else
                this = this.init(data,time,quality,'IsTimeFirst',false);
            end
        end
    end
catch me
    rethrow(me);
end

% end of function

% -----------------------------------------------------------------------
% subroutine : verify the input information : time
% Time: sample time which should be a non-empty vector.
% -----------------------------------------------------------------------
function [time, len] = localParseTime(this,timein,tsDataSampleSize)

% If it is an array of char (absolute date)
if ischar(timein) || iscellstr(timein) || isstring(timein)
    % Sample length equals the number of rows
    len = size(timein,1);
    % If time series object requires relative time points, error out
    if isempty(this.Timeinfo.StartDate)
        if ~isempty(tsDataSampleSize)
            error(message('MATLAB:timeseries:addsample:numericValTime'));
        else
            time = timein;
        end
    % Otherwise, get time values relative to the StartDate and Units values
    else    
        time = tsAnalyzeAbsTime(timein,this.Timeinfo.Units,this.Timeinfo.StartDate);
    end
elseif isnumeric(timein)
    % sample length equals the number of rows
    if isvector(timein)
        len = length(timein);
        time = timein(:);
    else
        error(message('MATLAB:timeseries:addsample:timeVector'));
    end
else
    error(message('MATLAB:timeseries:addsample:invalidTimeFormat'));
end

% -----------------------------------------------------------------------
% subroutine : verify the input information : data
% Data should represent the ordinate data.
% -----------------------------------------------------------------------
function [data, dataSampleSize] = localParseData(datain,IsTimeFirst,...
    tsDataSampleSize,sample_number)

if ((isnumeric(datain) || islogical(datain)) && ~isempty(datain))
    data = datain;
else
    error(message('MATLAB:timeseries:addsample:mandatoryFirstArg'))
end
if ~isempty(tsDataSampleSize)
    if IsTimeFirst && sample_number~=1 && size(data,1)~=sample_number
        error(message('MATLAB:timeseries:addsample:first'));
    end
    if ~IsTimeFirst && sample_number~=1 && size(data,ndims(data))~=sample_number
        error(message('MATLAB:timeseries:addsample:last'));
    end
end
% get data sample size
if sample_number==1
    % if a single sample, sample size is the size of data
    dataSampleSize = size(data);
else
    % more complicated
    dataSampleSize = size(data);
    if IsTimeFirst
        if length(dataSampleSize)==2
            dataSampleSize(1)=1;
        else
            dataSampleSize=dataSampleSize(2:end);
        end
    else
        dataSampleSize=dataSampleSize(1:end-1);
    end
end

% -----------------------------------------------------------------------
% subroutine : verify the input information : quality
% varargin(1): sample quality (optional) which should be an integer. if
% the timeseries has empty (non-empty) quality value, the quality value
% should also be empty (non-empty). Otherwise, an error message is
% generated. 
% -----------------------------------------------------------------------
function [quality, qualitySampleSize] = localParseQuality(this,qualityin,...
      sample_number,time)

% user provides quality data
if ~isempty(qualityin)
    % Added Quality has to have integer value
    if ~isnumeric(qualityin(:)) || ~isequal(round(qualityin(:)),qualityin(:))
        error(message('MATLAB:timeseries:addsample:intQualityAttributes'));
    end
    % If ts contains samples without quality values, error out 
    if ~(this.Length==0) && this.Length>0 && isempty(this.Quality)
        error(message('MATLAB:timeseries:addsample:nonnull'));
    else
        quality = qualityin;
    end
    
    % Get quality sample size for the added samples
    qualitySampleSize = getQualitySampleSize(this.IsTimeFirst,quality,sample_number);
    
% User has not provided quality data
else
    if this.Length==0 || isempty(this.Quality)
        quality = [];
        qualitySampleSize = {};
    % If ts contains samples and it has quality values, error out 
    else
        if this.IsTimeFirst
            quality = interp1(this.Time,this.Quality,time,'nearest','extrap');
        else
            n = ndims(this.Quality);
            tmpQual = permute(this.Quality,[n 1:n-1]);
            modQuality = interp1(this.Time,tmpQual,time,'nearest','extrap');
            quality = permute(modQuality,[2:n 1]);
        end   
        % Get quality sample size for the added samples
        qualitySampleSize = getQualitySampleSize(this.IsTimeFirst,quality,sample_number);
    end
end

%------------------------------------------------------------------------
function singleData = localGetData(data,i,IsTimeFirst,SampleSize)

if isequal(size(data),SampleSize)
    singleData = data;
else    
    is = repmat({':'},[1 length(SampleSize)]);
    if IsTimeFirst
        tmp = [{i} is];
    else
        tmp = [is {i}];
    end
    singleData = data(tmp{:});
end


%------------------------------------------------------------------------
function singleQuality = localGetQuality(quality,i,IsTimeFirst,SampleSize)

if isempty(SampleSize) || isequal(size(quality),SampleSize)
    singleQuality = quality;
else    
    is = repmat({':'},[1 length(SampleSize)]);
    if IsTimeFirst
        tmp = [{i} is];
    else
        tmp = [is {i}];
    end
    singleQuality = quality(tmp{:});
end


% -----------------------------------------------------------------------
% Get the time stamp information for the new sample
%
% Output argument 1: a boolean variable. TRUE means the same timestamp
% already exists which means updating of an existing value, FALSE means
% the timestamp is new, which implies either an append or an insertion.
%
% Output argument 2: an integer. If updating an existing sample, it stores the
% index of the timestamp in the timeseries. If appending, its
% value is Inf.  If inserting, its value is the index of the
% closest timestamp which is larger than the new timestamp.
% NOTE: this function is only used when the original timeseries is not
% empty.
% -----------------------------------------------------------------------
function [doesExist,idx] = localFindTime(this,time)

if this.Length==0
    doesExist = false;
    idx = 1;
    return
end
if time>=this.TimeInfo.Start && time<=this.TimeInfo.End
    % Timestamp is within the time range of the original timeseries
    if isfinite(this.TimeInfo.Increment)
        if isequal((time-this.TimeInfo.Start)/this.TimeInfo.Increment,...
                round((time-this.TimeInfo.Start)/this.TimeInfo.Increment))
            % Timestamp already exists in a uniformly sampled timeseries,
            % return the index
            doesExist = true;
            idx = (time-this.Timeinfo.start)/this.Timeinfo.increment+1;
        else
            % Timestamp does not exist in a uniformly sampled timeseries,
            % return the index of the timestamp immediately larger than the
            % new timestamp
            doesExist = false;
            idx = ceil((time-this.TimeInfo.Start)/this.Timeinfo.increment)+1;
        end 
    else
        originalTime = this.Time;
        idx = find(originalTime==time);
        if isempty(idx)
            % timestamp does not exist in the timeseries, return the index
            % of the timestamp immediately larger than the new timestamp
            doesExist = false;
            idx = find(originalTime>time,1);
        else
            % timestamp already exists in the timeseries, return the index.
            doesExist = true;
        end
    end
else
    % timestamp is beyond the time range of the original timeseries
    doesExist = false;
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


% -----------------------------------------------------------------------
% Append/insert/update a SINGLE sample into the timeseries
% if the original timeseries is NOT uniformly sampled, add the sample
% first and changes will automatically happen if the timeseries becomes
% a uniformly sampled one after the addition operation.  vice versa
% -----------------------------------------------------------------------
function this = localAddData(this,data,time,quality,tsDataSampleSize,...
    tsQualitySampleSize,doesExist,idx)


% Append case
% Add to the end of the ts
if ~doesExist && ~isfinite(idx)
    
    % Update grid dimension length
    newtime = [this.Time;time];
    timeInfo = this.TimeInfo;
    tempIstimeFirst = this.IsTimeFirst;
    this.BeingBuilt = true;
    if isa(timeInfo,'tsdata.internal.commontimedata')
        [this.TimeInfo,this.DataInfo] = setlength(timeInfo,this.Length+1);
    else
        this.TimeInfo = setlength(this.TimeInfo,timeInfo.Length+1);
    end
    this.Time = newtime;
    % Deal with data
    if tempIstimeFirst       
        is = repmat({':'},[1 length(tsDataSampleSize)]);
        this.Data(this.Length,is{:}) = data;
    else
        is = repmat({':'},[1 length(tsDataSampleSize)]);
        this.Data(is{:},this.Length) = data;
    end

    % Deal with quality
    if ~isempty(quality)
        if tempIstimeFirst         
            is = repmat({':'},[1 length(tsQualitySampleSize)]);
            thisqual = this.Quality;
            thisqual(this.Length,is{:}) = quality;
            this.Quality = thisqual;
        else       
            is = repmat({':'},[1 length(tsQualitySampleSize)]);
            thisqual = this.Quality;
            thisqual(is{:},this.Length) = quality;
            this.Quality = thisqual;         
        end
    end
    
% update case
elseif doesExist
    % Deal with Data
    is = repmat({':'},[1 length(tsDataSampleSize)]);
    if isequal(size(this.Data),size(data))
        this.Data = data;
    else
        if this.IsTimeFirst
            this.Data(idx,is{:}) = data;
        else
            this.Data(is{:},idx) = data;
        end
    end
    % Deal with Quality
    if ~isempty(quality)
        is = repmat({':'},[1 length(tsQualitySampleSize)]);
        if isequal(size(this.Data),size(quality))
            this.Quality = quality;
        else
            thisqual = this.Quality;
            if this.IsTimeFirst
                thisqual(idx,is{:}) = quality;
            else
                thisqual(is{:},idx) = quality;
            end
            this.Quality = thisqual;
        end       
    end
% Insert case
else
    % Get data and quality in timeseries
    tempData = this.Data;
    tempQuality = this.Quality;
    
    % Generate is size
    isData = repmat({':'},[1 length(tsDataSampleSize)]);
    % Special treatment to data in matrix format
    if all(tsDataSampleSize~=1)
        if this.IsTimeFirst
            tempIndex = [{1} isData];
        else
            tempIndex = [isData {1}];
        end
        temp(tempIndex{:}) = data;
        data = temp;
        if this.Length==1
            temp(tempIndex{:}) = tempData;
            tempData = temp;
        end
    end
       
    % Generate is size
    isQuality = repmat({':'},[1 length(tsQualitySampleSize)]);
    if ~isempty(tempQuality)
        % Special treatment to data in matrix format
        if all(tsQualitySampleSize~=1)
            if this.IsTimeFirst
                tempIndex = [{1} isQuality];
            else
                tempIndex = [isQuality {1}];
            end
            temp(tempIndex{:}) = quality;
            quality  = temp;
            if this.Length==1
                temp(tempIndex{:}) = tempQuality;
                tempQuality = temp;
            end
        end
    end
    
    % deal with time   
    if isnan(this.TimeInfo.Increment)
        tempTime = this.Time;
    else
        tempTime = this.TimeInfo.getData;
    end
    originalTimeLength = this.Length;
    tempIsTimeFirst = this.IsTimeFirst;
    this.BeingBuilt = true;
    %this.TimeInfo = setlength(this.TimeInfo,this.TimeInfo.Length+1);
    if idx>1
        this.Time = [tempTime(1:idx-1);time;tempTime(idx:end)];
    else
        this.Time = [time;tempTime];
    end

    
    % deal with data and quality
    % add to the middle of the ts
    if idx>1
        if tempIsTimeFirst
            % Data is grid first
            tempIndex_Data1 = [{1:idx-1} isData];
            tempIndex_Data2 = [{idx:originalTimeLength} isData];
            
            % Insert data
            tempData = [tempData(tempIndex_Data1{:});...
                        data;...
                        tempData(tempIndex_Data2{:})];
            % Quality is grid first
            if ~isempty(quality)
                tempIndex_Quality1 = [{1:idx-1} isQuality];
                tempIndex_Quality2 = [{idx:originalTimeLength} isQuality];            
                % Insert quality
                tempQuality = [tempQuality(tempIndex_Quality1{:});...
                               quality;...
                               tempQuality(tempIndex_Quality2{:})];
            end
        else
            % Data is grid last
            tempIndex_Data1 = [isData {1:idx-1}];
            tempIndex_Data2 = [isData {idx:originalTimeLength}];
            % Insert data
            tempData = cat(ndims(tempData),tempData(tempIndex_Data1{:}), ...
                data,tempData(tempIndex_Data2{:}));
            % Quality is grid last
            if ~isempty(quality)
                tempIndex_Quality1 = [isQuality {1:idx-1}];
                tempIndex_Quality2 = [isQuality {idx:originalTimeLength}];            
                % Insert quality
                tempQuality = cat(ndims(tempQuality),tempQuality(tempIndex_Quality1{:}), ...
                    quality,tempQuality(tempIndex_Quality2{:}));
            end
        end
    % Add to the beginning of the ts
    else
        if tempIsTimeFirst
            % Data is grid first
            tempIndex_Data = [{1:originalTimeLength} isData];
            % Append data
            tempData = [data;...
                        tempData(tempIndex_Data{:})];
            % Quality is grid first
            if ~isempty(quality)
                tempIndex_Quality = [{1:originalTimeLength} isQuality];
                % Append quality
                tempQuality = [quality;tempQuality(tempIndex_Quality{:})];
            end
        else
            % Data is grid last
            tempIndex_Data = [isData {1:originalTimeLength}];
            % Special case when original ts has a single sample 
            if isequal(size(tempData),size(data))            
                tempData = cat(ndims(tempData)+1,data,tempData(tempIndex_Data{:}));
            else
                tempData = cat(ndims(tempData),data,tempData(tempIndex_Data{:}));
            end
            % Quality is grid last
            tempIndex_Quality = [isQuality {1:originalTimeLength}];
            if ~isempty(quality)
                % special case when original ts has a single sample 
                if isequal(size(tempQuality),size(quality))            
                    tempQuality = cat(ndims(tempQuality)+1,quality,...
                        tempQuality(tempIndex_Quality{:}));
                else
                    tempQuality = cat(ndims(tempQuality),quality,...
                        tempQuality(tempIndex_Quality{:}));
                end
            end
        end
    end
    % Save data and quality
    this.Data = tempData;
    this.Quality = tempQuality;
    this.BeingBuilt = false;
end


function qualitySampleSize = getQualitySampleSize(IsTimeFirst,quality,sample_number)

% Find the size of the added quality

% Get quality sample size for the added samples
if sample_number==1
    qualitySampleSize = size(quality);
else
    qualitySampleSize = size(quality);
    if IsTimeFirst
        if length(qualitySampleSize)==2
            qualitySampleSize(1) = 1;
        else
            qualitySampleSize = qualitySampleSize(2:end);
        end
    else
        if length(qualitySampleSize)==2
            qualitySampleSize(1) = 1;
        else
            qualitySampleSize = qualitySampleSize(1:end-1);
        end
    end
end