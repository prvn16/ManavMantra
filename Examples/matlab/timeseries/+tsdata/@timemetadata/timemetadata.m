classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) timemetadata
%

% Copyright 2005-2013 The MathWorks, Inc.
    
    properties
        Units = 'seconds';
        UserData;
        Format = '';
        StartDate = '';
    end
    
    properties (SetAccess = protected)
        Length = 0;
    end
    
    properties (Dependent = true)
        End;
        Increment;
        Start;
    end
    
    properties (Hidden = true)
        DuplicateTimes = [];
        Time_;
        Increment_;
        Start_;        
    end
 
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.1;
    end
    
    properties (Hidden = true, SetAccess = protected, GetAccess = protected)
        % The Initialized property is used to turn on deprecation warnings
        % when directly setting the Start or Increment properties of a
        % timemetadata object in the TimeInfo of a timeseries. These
        % warnings must not be generated on an uninitialized object or they
        % will get thrown on loading.
        Initialized = false;
    end
    
    methods
  
        % isequal is overridden so as to compare only the properties that
        % reflect functional differences between time representation and to
        % exclude properties relating to storage. Since this method is
        % intended for use by the timeseries isequal method, any difference
        % in storage properties which effect the representation of the time
        % vector will be detected by comparison of the actual time
        % vector.
        function iseq = isequal(ts1,ts2)
            iseq = ~isempty(ts1) && ~isempty(ts2) && strcmp(ts1.Units,ts2.Units) && ...
                strcmp(ts1.Format,ts2.Format) && strcmp(ts1.Startdate,ts2.StartDate) && ...
                isequal(ts1.UserData,ts2.UserData) && isequal(ts1.getData,ts2.getData);
        end
        
        function this = timemetadata(timeArg,len,increment)
            %
            
            % The timeArg argument can either be a time vector or the start
            % time of a uniform time vector.
            if nargin==0 || isempty(timeArg)
                return;
            end
            % Turn on deprecation warnings
            this.Initialized = true;
            
            if nargin==1
                this.Time_ = timeArg;
                this.Length = length(timeArg);  
            elseif nargin==3
                this.Time_ = [];
                this.Start_ = timeArg;
                this.Length = len;  
                this.Increment_ = increment;
            end
        end
        
        function dupTimes = get.DuplicateTimes(this)
            % If the DuplicateTimes property is empty then it must be
            % calculated from the internally stored time vector or uniform
            % time parameters.
            if isempty(this.DuplicateTimes)
                increment = this.Increment_;
                if ~isempty(increment) && isfinite(increment)
                    hasDupTimes = (increment==0);
                else
                    t = this.Time_;
                    if isobject(t)
                        t = t.getTime;
                    end
                    if length(t)<=1
                        hasDupTimes = false;
                    elseif length(t)==2
                        hasDupTimes = (diff(t)==0);
                    else
                        hasDupTimes = (any(diff(t)==0));
                    end
                end
            else           
                hasDupTimes = this.DuplicateTimes;
            end
            dupTimes = hasDupTimes;
        end    
        
        function hasDupTimes = hasDuplicateTimes(this)
            hasDupTimes = this.DuplicateTimes;
        end
        
        function status = isUniform(this)
            status = isempty(this.Time_) && ~isempty(this.Increment_) && ...
                isfinite(this.Increment_);
        end
        
        function endVal = get.End(this)
            % Compute the End from the Start and Increment or the
            % internally stored time
            time = this.Time_;
            if isobject(this.Time_)
                time = time.getTime;
            end
            
            % Note that time may be empty (e.g. 0x1) when Increment_ is also
            % empty if the timeseries is empty. In this case the time
            % vector should be considered to be internally stored.
            if isempty(time) && ~isempty(this.Increment_) && isfinite(this.Increment_)
                endVal = this.Start_+(this.Length-1)*this.Increment_;
            else
                if ~isempty(time)
                    endVal = time(end);
                else
                    endVal = [];
                end
            end
            
        end
 
        function this = set.End(this,~)
               try
                  if this.Initialized
                     warning(message('MATLAB:tsdata:timemetadata:set:End:deprecation'));
                  end
               catch me
                   if ~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                       rethrow(me)
                   end
               end
               
        end

        function this = set.Start(this,input)
            this.Start_ = input;
            try
                if this.Initialized
                   warning(message('MATLAB:tsdata:timemetadata:set:start:deprecation'));
                end
            catch me
                   if ~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                       rethrow(me)
                   end
            end           
        end
        
        function this = set.Increment(this,input)
            this.Increment_ = input;
            
            % User code or tests prior to 2010a may set the Increment
            % property to a non NaN value to obtain a uniform time vector.
            % In this case we must set the Start_ to the initial value of
            % any non-empty internal time vector since the Start_ property 
            % will no longer have been automatically set when that time vector
            % was previously assigned.
            if ~isempty(input) && isfinite(input) && ~isempty(this.Time_)
                this.Start_ = this.Time_(1);
                this.Time_ = [];
            end
            try
                if this.Initialized           
                   warning(message('MATLAB:tsdata:timemetadata:set:increment:deprecation'));
                end
            catch me
                if ~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                       rethrow(me)
                end
            end 
        end
        
        function start = get.Start(this)
            t = this.Time_;           
            if isempty(t) 
                start = this.Start_;
            else
                if isobject(t)
                    t = t.getTime;
                end
                start = t(1);
            end
            
        end
        
        function increment = get.Increment(this)
            % If the locally stored Increment_ is empty, then Increment
            % must be calculated based on the internal time storage.
            if isempty(this.Increment_)
                t = this.Time_;
                if isempty(t) 
                    increment = [];
                    return
                elseif isobject(t)
                    t = t.getTime;
                end
                if length(t)==1
                    increment = NaN;
                elseif length(t)==2
                    increment = diff(t);
                else
                    dt = diff(t);
                    reldiff = max(abs(diff(dt)))/mean(abs(t));
                    if reldiff<1e-12
                        %g1537640 - to perform arithmetic of vector, we
                        %need to cast it to the same type
                        tClass = class(t);
                        var = (0 : 1 : length(t) - 1)';
                        varCast = cast(var,tClass);
                        A = t(1) + dt(1) * varCast;
                        
                        % Add one more increment if doing so would get closer to the end
                        % time. This is needed to prevent small round off errors in the
                        % increment causing the last time instant to 'vanish'
                        if (t(end)-A(end))>(A(end)+dt(1)-t(end))
                            A = [A; A(end)+dt(1)];
                        end
                        % If rounding errors prevent reconstruction, then represent time as
                        % non-uniform                   
                        if isequal(A,t)
                            increment = dt(1);
                        else
                            increment = NaN;
                        end
                    else
                        increment = NaN;
                    end
                end
            else
                increment = this.Increment_;
            end            
        end
        
        
        function hout = reset(h,t)
            %RESET is called when the time vector is assigned via the Time
            %property of the hosting timeseries object.
                        
            h.Length = length(t);
            hout = h;
            
            % Reset the DuplicateTime to null to force hasDuplicateTimes to
            % recalculate. We do not want to compute the DuplicateTime from
            % the new time vector to avoid impacting performance.
            hout.DuplicateTimes = [];
            
            % Check the time vector is valid
            if ~isempty(t)
                t = timeseries.tsChkTime(t);
                if ~issorted(t)
                     error(message('MATLAB:tsdata:timemetadata:reset:nosort'))
                end                
            end
            
            % The time vector is stored in uncompressed form (for
            % performance). Set the Start_,Increment_ and Time_ properties
            % accordingly.
            hout.Length = length(t);
            hout.Increment_ = [];
            hout.Start_ = [];
            hout.StartDate = h.StartDate;
            hout.Units = h.Units;
            if ~isempty(t) && isobject(t)
               hout.Time_ = t.getTime;
            else
               hout.Time_ = t;
            end
        end
        
        function this = setlength(this,newlen)
            this.Length = newlen;
        end
        
        function A = getData(this) 
            t = this.Time_;
            if isempty(t)
                increment = this.Increment_;
                
                % If the Increment_ property is not a finite scalar, then t
                % is empty because this is an empty timeseries. In this
                % case just return the empty internal time vector (which
                % may have a non-zero dimension, e.g. 0xn, which needs to 
                % be preserved. 
                if ~isempty(increment) && isfinite(increment) && this.End>=this.Start_
                    A = this.Start_ + increment * (0 : 1 : this.Length - 1)';
                    % Add one more increment if doing so would get closer to the end
                    % time. This is needed to prevent small round off errors in the
                    % increment causing the last time instant to 'vanish'
                    if (this.End-A(end))>(A(end)+increment-this.End)
                        A = [A; A(end)+increment];
                    end
                else
                    A = zeros(0, 1);
                end
            elseif isobject(t)
                A = t.getTime;
            else
                A = t;
            end
        end             
    end
       
    methods (Hidden = true)
            function this = setuniformtime(this,startTime,interval,endTime)
                props = {'StartTime','Interval','EndTime'};
                defaults = [0,1,1];
                params = [startTime,interval,endTime];
                len = this.Length;
                for k=1:length(props)
                   if ~isnan(params(k))
                       continue;
                   % If 2 parameters are specified, compute this parameter
                   elseif sum(~isnan([params(1:k-1) params(k+1:end)]))==2                        
                       if k==1
                           params(1) = params(3)-(len-1)*params(2);
                       elseif k==2
                           params(2) = (params(3)-params(1))/(len-1); 
                       elseif k==3
                           params(3) = params(1)+(len-1)*params(2);
                       end
                   else
                       params(k) = defaults(k);
                   end
                end
                
                
                % Check that the specified parameters comply with the
                % length. If the length is zero, compute it based on the
                % specified parameters.
                if len>0
                    if params(3) ~= params(1)+(len-1)*params(2)
                       error(message('MATLAB:tsdata:timemetadata:setuniformtime:invlen'));
                    end  
                else
                    this.Length = max(round(1+(params(3)-params(1))/params(2)),0);
                end

                this.Start_ = params(1);
                this.Increment_ =  params(2);
                this.Time_ = [];
            end
            
            % Undocumented method for setting non-uniform time without
            % performing a validity check (for performance)
            function this = setnonuniformtime(this,time)
                this.Time_ = time;
                this.Length = length(time);
                this.Increment_ = [];
                this.Start_ = [];
            end
            
            % Undocumented method for converting the Units property to a
            % Message Catalog string
            function displayStr = getUnitsDisplayStr(timeInfo)
                
                % If Units is empty, return an empty string
                if isempty(timeInfo.Units)
                    displayStr = '';
                else
                    switch lower(timeInfo.Units)
                        case 'weeks'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Weeks'));
                        case 'days'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Days'));
                        case 'hours'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Hours'));
                        case 'minutes'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Minutes'));
                        case 'seconds'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Seconds'));
                        case 'milliseconds'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Milliseconds'));
                        case 'microseconds'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Microseconds'));
                        case 'nanoseconds'
                            displayStr = getString(message('MATLAB:tsdata:timemetadata:timemetadata:Nanoseconds'));
                        otherwise
                            % units is not translated
                            displayStr = timeInfo.Units;
                    end
                end
            end
    end    
            
    methods (Static = true)
        function this = loadobj(obj)
            if isstruct(obj)
                this = tsdata.timemetadata;
                if isfield(obj,'UserData')
                    this.UserData = obj.UserData;
                end
                if isfield(obj,'Start')
                    this.Start_ = obj.Start;
                end
                if isfield(obj,'Increment')
                    this.Increment = obj.Increment;
                end
                if isfield(obj,'Format')
                    this.Format = obj.Format;
                end
                if isfield(obj,'StartDate')
                    this.StartDate = obj.StartDate;
                end
                if isfield(obj,'Units')
                    this.Units = obj.Units;
                end
                if isfield(obj,'Length')
                    this.Length = obj.Length;
                end                
        
            elseif isa(obj,'tsdata.timemetadata')
                this = obj;
            else
                error(message('MATLAB:tsdata:timemetadata:loadobj:invloadtimemetadata'));
            end
            this.Initialized = true;
        end
        
        function this = create(varargin)
            this = tsdata.timemetadata(varargin{:});    
            % Turn on deprecation warnings
            this.Initialized = true;
        end
    end
    
end