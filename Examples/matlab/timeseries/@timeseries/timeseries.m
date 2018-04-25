%TIMESERIES  Create a time series object.
%
%   TS = TIMESERIES creates an empty time series object.
%
%   TS = TIMESERIES(DATA) creates a time series object TS using
%   data DATA. By default, the time vector ranges from 0 to N-1,
%   where N is the number of samples, and has an interval of 1 second. The
%   default name of the TS object is 'unnamed'.
%
%   TS = TIMESERIES(NAME), where NAME is a string, creates an
%   empty time series object TS called NAME.
%
%   TS = TIMESERIES(DATA,TIME) creates a time series object TS
%   using data DATA and time in TIME. Note: When the times
%   are date strings, the TIME must be specified as a cell array of date
%   strings. When the data contains three or more dimensions, the length of
%   the time vector must match the size of the last data dimension
%
%   TS = TIMESERIES(DATA,TIME,QUALITY) creates a time series object
%   TS using data DATA, the time vector in TIME, and data quality in
%   QUALITY. Note: When QUALITY is a vector, which must have the same
%   length as the time vector, then each QUALITY value applies to the
%   corresponding data sample. When QUALITY has the same size as TS.Data,
%   then each QUALITY value applies to the corresponding element of a data
%   array.
%
%   You can enter property-value pairs after the DATA,TIME,QUALITY
%   arguments:
%       'PropertyName1', PropertyValue1, ...
%   that set the following additional properties of time series object:
%       (1) 'Name': a string that specifies the name of this time series object.
%       (2) 'IsTimeFirst': a logical value, when TRUE, indicates that the
%       first dimension of the data array is aligned with the time vector.
%       Otherwise the last dimension of the data array is aligned with the
%       time vector.When the data array contains three or more dimensions,
%       the last dimension of the data array must align with the time vector
%       (3) 'isDatenum': a logical value, when TRUE, indicates that the time vector
%       consists of DATENUM values. Note that 'isDatenum' is not a property
%       of the time series object.
%
%   EXAMPLES:
%   Create a time series object called 'LaunchData' that contains 4 data
%   sets (stored as columns with length of 5) and uses a default time vector:
%
%   b = timeseries(rand(5,4),'Name','LaunchData')
%
%   Create a time series object containing a single data set of length 5
%   and a time vector starting at 1 and ending at 5:
%
%   b = timeseries(rand(5,1),[1 2 3 4 5])
%
%   Create a time series object called 'FinancialData' containing 5 data
%   points at a single time point:
%   b = timeseries(rand(1,5),1,'Name','FinancialData')
%
%   See also TIMESERIES/ADDSAMPLE, TIMESERIES/TSPROPS

%   Copyright 2004-2017 The MathWorks, Inc.

classdef (CaseInsensitiveProperties = true) timeseries
    properties
        Events = [];
        Name = '';
        UserData = [];
    end
    properties (Dependent = true)
        Data;
    end
    properties
        DataInfo = [];
    end
    properties (Dependent = true)
        Time;
    end
    properties
        TimeInfo = [];
    end
    properties (Dependent = true)
        Quality;
    end
    properties
        QualityInfo = [];
    end
    properties (Dependent = true)
        IsTimeFirst;
    end
    properties
        TreatNaNasMissing = true;
    end
    properties (Dependent = true, SetAccess = protected)
        Length;
    end
    properties (SetAccess = protected, Hidden = true)
        Data_ = [];
        Time_ = [];
        Quality_ = [];
    end
    % Simulink needs access so these props cannot be read-only
    properties (Hidden = true)
        IsTimeFirst_ = true;
        Storage_ = [];
    end
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.2;
    end
    properties (Hidden = true)
        BeingBuilt = false;
    end
    properties (Hidden = true, Dependent = true, Transient = true)
        Datenums;
    end
    
    methods
        function this = setprop(this,propName,propVal)
            this.(propName) = propVal;
        end
        
        function propval = getprop(this,propName)
            propval = this.(propName);
        end
        
        function outtime = get.Time(this)
            timeMetadata = this.TimeInfo;
            try
                if ~isempty(timeMetadata)
                    if isa(timeMetadata,'tsdata.internal.commontimedata')
                        outtime = timeMetadata.getData(this.DataInfo);
                    else
                        outtime = timeMetadata.getData;
                    end
                else
                    outtime = [];
                end
            catch
                % g1502208: Invalid DataInfo should throw a warning instead
                % of error so that Simulink logging works properly without
                % any segmentation fault
                warning(message('MATLAB:timeseries:timeseries:invalidTimeInfo'));
                outtime = [];
            end
        end
        
        function this = set.Time(this,input)
            % Verify the size of the time vector if BeingBuilt is false and
            % if we are not adding a non-empty time vector to an empty
            % timeseries.
            if ~this.BeingBuilt
                this.chkTimeProp(input);
            end
            timeInfo = this.TimeInfo;
            if isa(timeInfo,'tsdata.internal.commontimedata')
                [this.TimeInfo,this.DataInfo] = reset(this.TimeInfo,this.DataInfo,input);
            else
                this.TimeInfo = reset(this.TimeInfo,input);
            end
        end
        
        function outdata = get.Data(this)
            dataInfo = this.DataInfo;
            % Storage order of precedence:
            % 1. DataInfo storage object gets the first opportunity to
            % provide data
            % 2. Storage_ object
            % 3. Cached Data_
            try
                if ~isempty(dataInfo) && (dataInfo.isstorage || isa(dataInfo,...
                        'tsdata.internal.commontimedata'))
                    % Pass the Time and TimeInfo to getData so that data
                    % storage can use information about the time vector
                    % to reconstruct the data if needed.
                    outdata = dataInfo.getData(this.Time,this.TimeInfo);
                elseif ~isempty(this.Storage_)
                    % Pass the Time and TimeInfo to getData so that data
                    % storage can use information about the time vector
                    % to reconstruct the data if needed.
                    outdata = this.Storage_.getData(this.Time,this.TimeInfo);
                else
                    outdata = this.Data_;
                end
            catch
                % g1502208: Invalid DataInfo should throw a warning instead
                % of error so that Simulink logging works properly without
                % any segmentation fault
                warning(message('MATLAB:timeseries:timeseries:invalidDataInfo'));
                outdata = this.Data_;
            end
        end
        
        function this = set.Data(this,input)
            if iscell(input)
                error(message('MATLAB:timeseries:set:Data:nocell'))
            end
            len = this.Length;
            
            % Verify the size of the data array if BeingBuilt is false and
            % if we are not adding a non-empty data array to an empty
            % timeseries. If necessary reshape data to conform to grid.
            if ~this.BeingBuilt && len>0
                % Data should not be reshaped if the timeseries is being
                % built from an empty state since the reshape would only
                % occur if time were set before data and not vice-versa.
                if ~isempty(this.Data_) || ~isempty(this.Storage_) || ...
                        this.DataInfo.isstorage
                    input = this.formatData(input);
                end
                this.chkDataProp(input);
            end
            
            % Storage order of precedence:
            % 1. DataInfo storage object gets the first opportunity to
            % store data
            % 2. Storage_ object
            % 3. Cached Data_
            dataInfo = this.DataInfo;
            if ~isempty(dataInfo) && dataInfo.isstorage
                % setData returns data for internal storage (which may be
                % empty) and a new DataInfo object. The ability to return
                % both enables the data storage object to either store
                % data itself or give up and just revert to standard
                % memory resident storage in the Data_ property with a
                % base tsdata.datametadata object.
                if isa(dataInfo,'tsdata.internal.commontimedata')
                    [this.Data_,this.DataInfo,this.TimeInfo] = dataInfo.setData(this.TimeInfo,input);
                else
                    [this.Data_,this.DataInfo] = dataInfo.setData(input);
                end
            elseif ~isempty(this.Storage_)
                % setData returns data for internal storage (which may be
                % empty) and a new Storage object (which may be empty).
                % The ability to return both enables the data storage object
                % to either store data itself or give up and just revert to
                % standard memory resident storage in the Data_ property with
                % an empty Storage_ object.
                [this.Data_,this.Storage_] = this.Storage_.setData(input);
            else
                this.Data_ = input;
            end
        end
        
        function outdata = get.Quality(this)
            outdata = this.QualityInfo.getData(this.Quality_);
        end
        
        function this = set.IsTimeFirst(this,input)
            if ~this.BeingBuilt
                this.chkIsTimeFirstProp(input);
            end
        end
        
        function outdata = get.IsTimeFirst(this)
            outdata = tsdata.datametadata.isTimeFirst(size(this.Data),...
                this.Length,this.DataInfo.InterpretSingleRowDataAs3D) ;
        end
        
        function this = set.Quality(this,input)
            if ~this.BeingBuilt
                input = this.formatQuality(input);
            end
            this.Quality_ = setData(this.QualityInfo,input);
        end
        function outdata = get.Length(this)
            timeInfo = this.TimeInfo;
            if ~isempty(timeInfo)
                if isa(timeInfo,'tsdata.internal.commontimedata')
                    outdata = timeInfo.getLength(this.DataInfo);
                else
                    outdata = timeInfo.Length;
                end
            else
                outdata = [];
            end
        end
        function this = set.Length(this,len) %#ok<INUSD>
            error(message('MATLAB:timeseries:set:Length:lenro'));
        end
        
        % This temporary get function is used by linked timeseries plots
        % since the x axis uses a datetime/datenum representation of the
        % time vector.
        function outdata = get.Datenums(this)
            if ~isempty(this.TimeInfo.StartDate)
                outdata = tsunitconv('days',this.TimeInfo.Units)*this.Time + datenum(this.TimeInfo.StartDate);
            else
                outdata = this.Time;
            end
        end
        
        function this = set.Datenums(this,value)
            if ~isempty(this.TimeInfo.StartDate)
                this.Time = tsunitconv(this.TimeInfo.Units,'days')*(value - datenum(this.TimeInfo.StartDate));
            else
                this.Time = value;
            end
        end
        
        function hasDupTimes = hasduplicatetimes(this)
            hasDupTimes = false;
            timeInfo = this.TimeInfo;
            if ~isempty(timeInfo)
                % Deal with legacy TimeInfo with no hasDuplicateTimes
                % method
                try
                    if isa(timeInfo,'tsdata.internal.commontimedata')
                        hasDupTimes = timeInfo.hasDuplicateTimes(this.DataInfo);
                    else
                        hasDupTimes = timeInfo.hasDuplicateTimes;
                    end
                catch me
                    if strcmp('MATLAB:noSuchMethodOrField',me.identifier)
                        return;
                    end
                end
            end
        end
        
        function this = timeseries(varargin)
            % Initialize metadata
            
            % Create a tsdata.timemetadata with deprecation warnings for object
            % setting using the create static constructor.
            this.TimeInfo = tsdata.timemetadata.create;
            
            this.DataInfo = tsdata.datametadata;
            this.QualityInfo = tsdata.qualmetadata;
            this.DataInfo.Interpolation = tsdata.interpolation.createLinear;
            % Empty names timeseries
            if nargin ==1 && isa(varargin{1},'char')
                this.Name = varargin{1};
                return
            end
            % Upcast
            if nargin ==1 && isa(varargin{1},'timeseries')
                if numel(varargin{1})>1
                    error(message('MATLAB:timeseries:timeseries:noarray'));
                end
                inObj = varargin{1};
                this.Name = inObj.Name;
                this = init(this,inObj.Data,inObj.Time,inObj.Quality);
            elseif nargin ==1 && isa(varargin{1},'tsdata.timeseries')
                this = varargin{1}.TsValue;
            elseif nargin>0
                this.Name = 'unnamed';
                this = init(this,varargin{:});
            end
        end
        
        function iseq = isequal(ts1,ts2)
            % two empty timeseries should be equal
            if isempty(ts1) && isempty(ts2) && isa(ts1, 'timeseries') &&...
                    isa(ts2, 'timeseries')
                iseq = true;
                return;
            end
            
            if isempty(ts1) || isempty(ts2) || ~isa(ts2,'timeseries') || ...
                    ~isequal(size(ts1),size(ts2))
                iseq = false;
                return
            end
            iseqarray = eq(ts1,ts2);
            iseq = all(iseqarray(:));
        end
    end
    
    
    
    methods (Access = protected)
        
        % Check that Time property is not changing the length of the
        % timeseries.
        function chkTimeProp(this,input)
            isTimeFirst = this.IsTimeFirst;
            % If the data is stored in the timeseries, we only need check
            % that the new time vector does not change the length if it is
            % >0. If the length is zero, the length of the time dimension
            % of the data must match the new time vector.
            if ~isempty(this.Data_)
                len = this.Length;
                if len>0 && len~=length(input)
                    error(message('MATLAB:timeseries:chkTimeProp:arraymismatch'));
                elseif len==0
                    sData = size(this.Data_);
                else % Non empty time which has not changed length
                    return;
                end
                % If the Data is stored in a Storage_ or a DataInfo object,
                % the size of the data must be compared with the time vector
                % since the data size may change with time (e.g. for Signal
                % Builder)
            elseif ~isempty(this.Storage_) || this.DataInfo.isstorage
                if ~isempty(this.Storage_)
                    sData = this.Storage_.getSize(input,this.TimeInfo);
                else
                    sData = this.DataInfo.getSize(input,this.TimeInfo);
                end
            else % No data, build from empty state
                return
            end
            
            % For cases where data is stored in the timeseries but time
            % had zero length or where data was stored in a storage object
            % test that the length of the time vector matches the data.
            if (isTimeFirst && sData(1)~=length(input)) || ...
                    (~isTimeFirst && length(input)>1 && sData(end)~=length(input))
                error(message('MATLAB:timeseries:chkTimeProp:arraymismatch'));
            end
        end
        
        % Check that the dimensions of the Data property are consistent
        % with the Time and IsTimeFirst properties.
        function chkDataProp(this,input)
            len = this.Length;
            s = size(input);
            isTimeFirst = tsdata.datametadata.isTimeFirst(size(input),...
                this.Length,this.DataInfo.InterpretSingleRowDataAs3D);
            if (len>=1 && ((isTimeFirst && len~=s(1)) || ...
                    ~isTimeFirst && len>1 && len~=s(end)))
                error(message('MATLAB:timeseries:chkDataProp:arraymismatch'))
            end
        end
        
        % Check that the IsTimeFirst property is consistent with the Time and
        % Data properties.
        function chkIsTimeFirstProp(this,input)
            s = size(this.Data);
            len = this.Length;
            if ~all(s==0) % Do not warn or error if modifying an empty timeseries
                if ((input && s(1)~=len) || (~input && len>1 && s(end)~=len))
                    if input
                        error(message('MATLAB:timeseries:chkIsTimeFirstProp:istimefirstMisalignTrue'));
                    else
                        error(message('MATLAB:timeseries:chkIsTimeFirstProp:istimefirstMisalignFalse'));
                    end
                end
                % isTimeFirst deprecation warning will throw error instead
                % of warning
                tsdata.datametadata.warnAboutIsTimeFirst(input,size(this.Data),...
                    len,this.DataInfo.InterpretSingleRowDataAs3D);
            end
        end
        
        % Check that the dimensions of the Quality property are consistent
        % with the Time and IsTimeFirst properties.
        function chkQualityProp(this,input)
            timeseries.utCheckQuality(input,this.Data,this.Length,this.IsTimeFirst);
        end
        
        % Attempt to reshape the Data to match the Time vector and
        % IsTimeFirst property.
        function data = formatData(this,input)
            data = timeseries.utreshape(this.Length,input,[]);
        end
        
        % Attempt to reshape the Quality to match the Time vector and
        % IsTimeFirst property.
        function quality = formatQuality(this,input)
            [~,quality] = timeseries.utreshape(this.Length,this.Data,input);
        end
        
        
    end
    
    methods (Static = true)
        
        function h = loadobj(s)
            
            if isstruct(s)
                if isfield(s,'objH')
                    % <=2006a @timeseries objects always include a wrapped tsata.timeseries in objH
                    % This will have been converted to a valid 2006b tsdata.timeseries obj by
                    % its loadobj
                    h = s.objH.TsValue;
                else
                    h = timeseries;
                    classTs = metaclass(h);
                    h.BeingBuilt = true;
                    pNames = fieldnames(s);
                    for k=1:length(pNames)
                        if strcmp(pNames{k},'Time_')
                            if ~isequal(size(s.Time_),[0 0]);
                                h.TimeInfo.Time_ = s.Time_;
                            end
                        elseif any(cellfun(@(p) strcmpi(p.Name,pNames{k}),classTs.Properties))
                            h.(pNames{k}) = s.(pNames{k});
                        end
                    end
                    
                    % Instance props from 2006a 2006b
                    % Any fieldnames which do not correspond to timeseries
                    % properties (except Grid_,InstancePropValues_,
                    % InstancePropNames are instance properties). Add them as
                    % a struct in the UserData property.
                    cTimeSeries = ?timeseries;
                    instanceProps = setdiff(fields(s),cellfun(@(x) {x.Name},cTimeSeries.Properties));
                    instanceProps = setdiff(instanceProps,{'Grid_','InstancePropValues_',...
                        'InstancePropNames_'});
                    if ~isempty(instanceProps)
                        for k=1:length(instanceProps)
                            h.UserData.(instanceProps{k}) = s.(instanceProps{k});
                        end
                    end
                    % The fieldnames InstancePropNames_ and
                    % InstancePropValues_ represent 2006a,b instance props.
                    % Add them to the instance props stored in the UserData
                    if isfield(s,'InstancePropNames_') && ~isempty(s.InstancePropNames_)
                        for k=1:min(length(s.InstancePropNames_),length(s.InstancePropValues_))
                            h.UserData.(s.InstancePropNames_{k}) = s.InstancePropValues_{k};
                        end
                    end
                    h.BeingBuilt = false;
                end
            elseif isa(s,'timeseries')
                h = s;
                % The following logic is added to allow timeseries data/time
                % to be modified directly in HDF5 without MATLAB. The idea is
                % to modify the arrays directly and fix the length when the
                % object is loaded. This was requested by Michael Kositsky.
                if ~isempty(h.TimeInfo) && h.Length == 0 && ...
                        (isempty(h.TimeInfo.Increment_) || ...
                        isnan(h.TimeInfo.Increment_))
                    if ~isequal(size(h.Time_),[0 0]) && isempty(h.TimeInfo.Time_)
                        h.TimeInfo = h.TimeInfo.reset(h.Time_);
                    else
                        h.TimeInfo = h.TimeInfo.reset(h.TimeInfo.Time_);
                    end
                end
                
                % Move time storage to TimeInfo if it was previously stored in
                % the Time_ property
                if ~isempty(h.Time_)
                    h.TimeInfo = h.TimeInfo.reset(h.Time_);
                    h.Time_ = [];
                end
                
                % Warn the user for backwards in compatibility. If the
                % timeseries object created on or before R2012b with
                % IsTimeFirst_ property whose value is incompatible with
                % calculated value of IsTimeFirst value, reshape the Data to
                % match the simulink rule and warn the user regarding the change.
                if ~isempty(h.Data_)
                    if h.Version < 10.2 && h.IsTimeFirst_ ~= tsdata.datametadata.isTimeFirst(size(h.Data_),h.Length,h.DataInfo.InterpretSingleRowDataAs3D)
                        s = size(h.Data_);
                        if ~ismatrix(h.Data_)
                            warning(message('MATLAB:timeseries:timeseries:loadObjectWarning'));
                            h.Data_ = reshape(h.Data_,[s(1) prod(s(2:end))]);
                        else
                            warning(message('MATLAB:timeseries:timeseries:loadObjectNoReshapeWarning'));
                        end
                    end
                end
            else
                h = [];
            end
        end
        
        function time = tsChkTime(time)
            stime = size(time);
            if length(stime)>2
                error(message('MATLAB:timeseries:tsChkTime:manytimedim'))
            end
            if max(stime)<1
                error(message('MATLAB:timeseries:tsChkTime:shorttime'))
            end
            if stime(2)>1
                stime = stime(2:-1:1);
                time = reshape(time,stime);
            end
            if stime(2)~=1
                error(message('MATLAB:timeseries:tsChkTime:matrixtime'))
            end
            if any(isinf(time)) || any(isnan(time))
                error(message('MATLAB:timeseries:tsChkTime:inftime'))
            end
            if ~all(isreal(time))
                error(message('MATLAB:timeseries:tsChkTime:realtime'))
            end
        end
        
        function t = tsgetrelativetime(date,dateRef,unit)
            % This method calculates relative time value between date and
            % dateref.
            vecRef = datevec(char(dateRef));
            if iscellstr(date)
                % Cell arrays of date chars arrays
                vecDate = datevec(date);
            elseif ischar(date) || (isstring(date) && isscalar(date))
                % Scalar dates
                vecDate = datevec(char(date));
            elseif iscell(date) || isstring(date)
                % Cell arrays of dates which contain strings or string
                % arrays
                vecDate = datevec(cellstr(date));
            end
            t = (datenum([vecDate(:,1:3) zeros(size(vecDate,1),3)])-datenum([vecRef(1:3) 0 0 0]))*...
                tsunitconv(unit,'days')+ ...
                (vecDate(:,4:6)*[3600 60 1]'-vecRef(:,4:6)*[3600 60 1]')*...
                tsunitconv(unit,'seconds');
        end
    end
    
    methods (Hidden = true)
        utDisplay(ts, useHTML);
        
        % Set method for external assignment of the Data_ property. This
        % method ensures that a non-empty Data_ cannot coexist with a
        % non-empty Storage_ property.
        function this = setData_(this,data)
            if ~isempty(this.Storage_) || (~isempty(this.DataInfo) && ...
                    this.DataInfo.isstorage)
                error(message('MATLAB:timeseries:setData:storageData'));
            end
            this.Data_ = data;
        end
        % Set method for external assignment of the Storage_ property. This
        % method ensures that a non-empty Data_ cannot coexist with a
        % non-empty Storage_ property.
        function this = setStorage_(this,data)
            if ~isempty(this.Data_) || (~isempty(this.DataInfo) && ...
                    this.DataInfo.isstorage)
                error(message('MATLAB:timeseries:setStorage:storageStorage'));
            end
            this.Data_ = data;
        end
        
    end
    
    methods (Static = true, Hidden = true)
        
        
        function this = utcreatearraywithoutcheck(data, time, varargin)
            % this method returns an array of timeseries
            
            % TO DO: This must change when data storage migrates to
            % metadata.
            
            sigcnt = size(data, 1);
            
            if ~iscell(time)
                time = {time};
            end
            
            if ~iscell(data)
                data = {data};
            end
            
            this = timeseries;
            this = repmat(this, 1, sigcnt);
            timeInfo = this.TimeInfo;
            timeInfo.Increment_ = [];
            timeInfo.Start_ = [];
            
            for n = 1:sigcnt
                time_ = time{n}';
                data_ = data{n}';
                this(n).Data_ = data_;
                
                % inlining setnonuniformtime(time_):
                timeInfo.Time_ = time_;
                timeInfo = setlength(timeInfo, length(time_));
                this(n).TimeInfo = timeInfo;
            end
            
            if nargin >= 3
                this.DataInfo.interpolation.fhandle = {@tsinterp varargin{1}};
                this.DataInfo.interpolation.Name = varargin{1};
            end
        end
        
        % TO DO Add interp flag
        function this = utcreatewithoutcheck(data,time,interpretSingleRowDataAs3D,...
                duplicatedTimes,varargin)
            
            % Utility method which may change in a future release.
            % Optional 3rd input argument specifies the dimensions of a
            % single sample.
            
            % Assign the data to data storage props.
            % TO DO: This must change when data storage migrates to
            % metadata.
            this = timeseries;
            this.Data_ = data;
            
            this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
            
            % Assign the metadata - could we just set props on the existing
            % object
            this.TimeInfo = this.TimeInfo.setnonuniformtime(time);
            this.TimeInfo.DuplicateTimes = duplicatedTimes;
            
            % If specified, assign default interpolation method
            if nargin>=5
                this.DataInfo.interpolation.fhandle = {@tsinterp varargin{1}};
                this.DataInfo.interpolation.Name = varargin{1};
            end
            
            % Initialize IsTimeFirst_
            this.IsTimeFirst_ = tsdata.datametadata.isTimeFirst(size(data),length(time),interpretSingleRowDataAs3D);
        end
        
        function this = utcreateuniformwithoutcheck(data,len,starttime,increment,...
                interpretSingleRowDataAs3D,varargin)
            % Utility method which may change in a future release.
            
            this = timeseries;
            this.Data_ = data;
            
            % Use the post-2010a logic for assigning IsTimeFirst
            this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
            
            
            % Assign the metadata
            timeInfo = tsdata.timemetadata(starttime,len,increment);
            this.TimeInfo = timeInfo;
            
            % If specified, assign default interpolation method
            if nargin>=6
                this.DataInfo.interpolation.fhandle = {@tsinterp varargin{1}};
                this.DataInfo.interpolation.Name = varargin{1};
            end
            
            % Avoid the need to use the time vector to compute DuplicateTimes
            % by caching the known value.
            this.TimeInfo.DuplicateTimes = increment==0 && len>=2;
            
            % Initialize IsTimeFirst_
            this.IsTimeFirst_ = tsdata.datametadata.isTimeFirst(size(data),len,interpretSingleRowDataAs3D);
        end
        
        
        function tsout = utarithcommonoutput(ts1,ts2,tsout,warningFlag)
            %UTARITHCOMMONOUTPUT
            %
            
            % Merge qualmetadata properties
            if ~isempty(ts1.QualityInfo) && ~isempty(ts2.QualityInfo)
                tsout.QualityInfo = qualitymerge(ts1.QualityInfo,ts2.QualityInfo);
            end
            % Merge quality values: pick up minimums
            if ~isempty(get(get(tsout,'QualityInfo'),'Code')) && ~isempty(ts1.Quality) && ...
                    ~isempty(ts2.Quality)
                tsout.Quality = min(ts1.Quality,ts2.Quality);
            end
            
            % Merge events
            tsout = addevent(tsout,horzcat(ts1.Events,ts2.Events));
            
            % issue a warning if offset is used.
            if warningFlag
                warning(message('MATLAB:timeseries:utArithCommonOutput:newtime'))
            end
        end
        
        function [time,data,quality,I] = utsorttime(time,data,quality,isTimeFirst)
            
            % timeseries utility function
            
            % UTSORTTIME Utility to sort time vector
            %
            % Sort time numeric or cell array datestr data.
            
            % Return [] if empty
            if isempty(time)
                I = [];
                return
            end
            
            len = length(time);
            if nargin>=2
                sdata = size(data);
                if sdata(1)~=len && sdata(end)~=len && len>1
                    error(message('MATLAB:timeseries:utsorttime:datamismatch'))
                end
            end
            if nargin>=3 && ~isempty(quality)
                squality = size(quality);
                if squality(1)~=len && squality(end)~=len && len>1
                    error(message('MATLAB:timeseries:utsorttime:qualmismatch'))
                end
            end
            
            
            % Convert datestr times to numeric vector
            if iscell(time)
                time = datenum(time);
            end
            
            % Return the same if single
            if isscalar(time)
                I = 1;
                return
            end
            
            % Sort generate sorting index, sort both time and data
            timeissorted = issorted(time);
            if ~timeissorted
                [time, I] = sort(time);
                s = size(data);
                % Rearrange data
                if nargin>=2
                    % If necessary, infer isTimeFirst from the data
                    if nargin<=3
                        if s(1)==len && s(end)~=len
                            isTimeFirst = true;
                        elseif s(1)~=len && s(end)==len
                            isTimeFirst = false;
                        else
                            error(message('MATLAB:timeseries:utsorttime:istimefirstAlign'))
                        end
                    end
                    
                    % Sort data samples
                    if isTimeFirst
                        ind = [{I} repmat({':'}, [1 length(s)-1])];
                    else
                        ind = [repmat({':'}, [1 length(s)-1]) {I}];
                    end
                    data = data(ind{:});
                    
                    % Sort quality
                    if nargin>=3 && ~isempty(quality)
                        if isvector(quality)
                            quality = quality(I);
                        else
                            quality = quality(ind{:});
                        end
                    end
                end
            else
                I = (1:length(time))';
            end
            
        end
        
        function [data,quality] = utreshape(len,data,quality)
            % timeseries utility function
            
            % UTRESHAPE Reshape data and quality to match the timeseries
            % data-time-quality compatibility rules.
            %
            % Sort time numeric or cell array datestr data.
            
            % NOTE: Successful use of UTRESHAPE to assign the data and
            % quality and istimefirst properties of the timeseries,
            % guarantees a valid timeseries object meeting the following
            % compatibility conditions:
            %  If IsTimeFirst
            %    - First dim of 2D Data must be the same as the length of the
            %      time vector
            %    - If Quality is not empty, size(quality,1) must be the same
            %      as the length of the time vector
            % If ~IsTimeFirst
            %    - Last dim of ND Data must be the same as the length of the
            %      time vector if the time vector length > 1
            %    - If Quality is not empty, size(quality,end) must be the
            %      same as the length of the time vector if the time vector
            %      length >1
            %
            % If length(time)==1
            %    - If Quality is not empty, is must be a scalar or match
            %      the data size
            
            % Expand scalar data,quality
            s = size(data);
            if prod(s)==1 && len>1 %#ok<PSIZE>  % Cannot use numel because its overloaded by embedded.fi
                data = repmat(data,[len,1]);
            end
            if numel(quality)==1 && len>1
                quality = repmat(quality,[len,1]);
            end
            
            % If quality is a column vector and there is only one (row)sample, transpose it
            if ~isempty(quality) && len==1 && len == size(data,1) && ~isscalar(quality) && ...
                    isvector(quality) && size(quality,2)==1
                quality = quality';
            end
            
            size_data = size(data);
            if length(size_data)==2 && size_data(end)==len && size_data(1)~=len && len > 1
                data = reshape(data,[size_data(1:end-1) 1 len]);
            end
            
            % Check the data and time compatibility
            if (len > 1 && (len~=size(data,1) && len~=size(data,ndims(data))))
                error(message('MATLAB:timeseries:utreshape:datatimearraymismatch'));
            end
            
            if (ndims(data) >=3 && len > 1 && len~=size(data,ndims(data))) %#ok<ISMAT>
                error(message('MATLAB:timeseries:utreshape:datatimearraymismatch'));
            end
            
            
            % Attempt to align vector quality with data
            if ~isempty(quality)
                % interpretSingleRowDataAs3D can be either true or false because IsTimeFirst is only used below if len > 1
                isTimeFirst = tsdata.datametadata.isTimeFirst(size(data),len,true);
                if isvector(quality) && len>1
                    if isTimeFirst
                        quality = quality(:);
                    else
                        quality = reshape(quality,[ones(1,ndims(data)-1) numel(quality)]);
                    end
                end
                % Check quality size
                timeseries.utCheckQuality(quality,data,len,isTimeFirst);
            end
        end
        
        function utCheckQuality(quality,data,len,isTimeFirst)
            
            % Check quality size
            if ~isempty(quality)
                squality = size(quality);
                sdata = size(data);
                dataqualmatch = false;
                if len>1
                    if isTimeFirst
                        if (isvector(quality) && len==squality(1))
                            dataqualmatch = true;
                        elseif isequal(sdata,squality)
                            dataqualmatch = true;
                        end
                    else
                        if (all(squality(1:end-1)==1) && len==squality(end))
                            dataqualmatch = true;
                        elseif isequal(sdata,squality)
                            dataqualmatch = true;
                        end
                    end
                elseif len==1 && (isscalar(quality) || isequal(squality,sdata))
                    dataqualmatch = true;
                end
                if ~dataqualmatch
                    error(message('MATLAB:timeseries:utCheckQuality:qualitymismatch'))
                end
            end
        end
        
        
        function t = createSeed(arg1)
            % Utility method which may change in a future release.
            
            % This static method is used by incremental Simulink logging to
            % create a seed timeseries for file logging.
            
            % Dummy data and time are chosen to have recognizable values
            % for debugging.
            DUMMY_TIME = [0.32, 1.32, 4.32, 6.32, 13.32, 17.32, 22.32]';
            
            fiVals = [];
            enumVals = [];
            if nargin >= 1 && ~isempty(arg1)
                if strcmp(arg1, 'fi()')
                    fiVals = fi(DUMMY_TIME, 1, 29, 0.005, -3.17);
                elseif strcmp(arg1, 'fiFixptBinaryPointScaling')
                    fiVals = fi(DUMMY_TIME, 1, 16, 12);
                elseif strcmp(arg1, 'fiFixptSlopeBiasScaling')
                    fiVals = fi(DUMMY_TIME, 1, 30, 1.5, 2.1);
                elseif strcmp(arg1, 'fiScaledDoubleBinaryPointScaling')
                    fiVals = fi(DUMMY_TIME, 1, 16, 12, 'DataType', 'ScaledDouble');
                elseif strcmp(arg1, 'fiScaledDoubleSlopeBiasScaling')
                    fiVals = fi(DUMMY_TIME, 1, 30, 1.5, 2.1,'DataType', 'ScaledDouble');
                else
                    enumVals = enumeration(arg1);
                end
            end
            
            if ~isempty(enumVals)
                enumVals = unique(enumVals);
                % If there are less enumVals than the length of the
                % DUMMY_TIME array, pad the data with the first enumerated
                % value
                
                if length(enumVals)<=length(DUMMY_TIME)
                    data = [enumVals;repmat(enumVals(1),[length(DUMMY_TIME)-length(enumVals) 1])];
                    time = DUMMY_TIME;
                    % If there are more enumVals than the length of the
                    % DUMMY_TIME array, pad with the time with uniform values.
                else
                    data = enumVals;
                    time = [DUMMY_TIME;DUMMY_TIME(end)+(1:(length(enumVals)-length(DUMMY_TIME)))'];
                end
                data = reshape(data,[1 1 length(time)]);
            elseif ~isempty(fiVals)
                time = DUMMY_TIME;
                data = reshape(repmat(fiVals, [1 2]), [2 1 length(time)]);
            else
                time = DUMMY_TIME;
                data = reshape(ones(length(DUMMY_TIME),2)*219.61,[2 1 length(time)]);
            end
            
            % Create timeseries which uses a StreamingStorage object for
            % data storage
            t = timeseries;
            t.Name = 'xxx';
            t.IsTimeFirst_ = false;
            t.DataInfo.InterpretSingleRowDataAs3D = true;
            t.Storage_ = tsdata.StreamingStorage(data);
            t.Time = time;
            % TO DO: Revisit with M.K whether this can be removed
            t.TimeInfo = t.TimeInfo.setlength(0);
        end
        
        function availUnits = utGetAvailableUnits
            % returns a cell array of strings containing the available time
            % units for a timeseries object
            availUnits = {...
                'nanoseconds','microseconds','milliseconds',...
                'seconds','minutes','hours',...
                'days','weeks','months','years'};
        end
        
        function res = utGetFactors(timeUnit)
            % returns the 'time factor' for a time unit where a time factor is
            % the number of seconds for that unit.  For example (sec is 1,
            % millisecond is 0.001, minute is 60)
            
            % time factors for time units from nanoseconds to years
            factors = [1e-9 1e-6 1e-3 1 60 3600 86400 604800 2629800 31557600];
            
            %
            % if an input argument (e.g., units) is provided, return the factor
            % for that particular unit, otherwise return the entire array of
            % factors
            %
            if nargin == 1
                res = factors(strcmpi(timeseries.utGetAvailableUnits,timeUnit));
            else
                res = factors;
            end
        end
        
    end
    
end