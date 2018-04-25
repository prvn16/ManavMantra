function this = init(this,varargin)
% INIT  Initialize a time series object with new time and data values
%
%   INIT(TS,DATA) initializes the time series object TS with the data in
%   DATA. By default, the time vector ranges from 0 to N-1, where N is the
%   number of samples, and has an interval of 1 second. The default name of
%   the TS object is 'unnamed'.  
%
%   INIT(TS,DATA,TIME) initializes the time series object TS with the 
%   data in DATA and the time vector in TIME. Note: When the times are date
%   strings, the TIME must be specified as a cell array of date strings.
%
%   INIT(TS,DATA,TIME,QUALITY) initializes the time series object TS with
%   the data in DATA, the time vector in TIME, and data quality in QUALITY.
%   Note: When Quality is a vector, which must have the same length as
%   the time vector, then each Quality value applies to the corresponding
%   data sample. When Quality has the same size as TS.Data, then each
%   Quality value applies to the corresponding element of a data array.
%
%   You can enter property-value pairs after the DATA,TIME,QUALITY
%   arguments:
%       'PropertyName1', PropertyValue1, ...
%   that set the following additional properties of time series object: 
%       (1) 'Name': a string that specifies the name of this time series object.  
%       (2) 'IsTimeFirst': a logical value, when TRUE, indicates that the
%       first dimension of the data array is aligned with the time vector.
%       Otherwise the last dimension of the data array is aligned with the
%       time vector.
%       (3) 'isDatenum': a logical value, when TRUE, indicates that the time vector
%       consists of DATENUM values
%       (4)-(6) 'StartTime','EndTime',or 'Interval': numeric scalars which
%       specify the parameters of a uniform time vector. Note that these
%       will be ignored if a time vector is specified explicitly.
%
%   Note: The INIT function does not change the 'StartDate' and
%   'Format' fields in the 'TimeInfo' property.
% 
%   See also TIMESERIES
%

%   Copyright 2005-2016 The MathWorks, Inc.
%

this.BeingBuilt = true;
b_state = warning('query','backtrace');
w_state = warning;
warning off backtrace
if numel(this)~=1
    error(message('MATLAB:timeseries:init:noarray'));
end

try    
    % Prepare input argument
    ni = nargin-1; % ni >= 1

    % initialize local variables
    quality = [];
    istimefirst = [];
    isdatenumprovided = [];
    interpretSingleRowDataAs3D = [];

    % uniform time parameters
    startTime = NaN;
    endTime = NaN;
    interval = NaN; 
    
    % PV starts
    dataInputStartPos = 0;
    PNVStart = 0; 
    while dataInputStartPos<ni && PNVStart==0
        nextarg = varargin{dataInputStartPos+1};
        % Is nextarg a single char vector property name then PNVStart is
        % dataInputStartPos+1
        if ischar(nextarg) && isvector(nextarg) % Property name
            PNVStart = dataInputStartPos+1;
        elseif isstring(nextarg) && isscalar(nextarg)
            % If the number of additional arguments after this string argument
            % is odd, then nextarg is a string property name, otherwise this
            % string is data e.g. timeseries("string") (undocumented use)
            if rem(ni-(dataInputStartPos+1),2)==1
                PNVStart = dataInputStartPos+1;
            end
        end
        if PNVStart==0
            dataInputStartPos = dataInputStartPos+1;
        end
    end

    % Deal with PV set
    if isempty(this.Name)
        this.Name = 'unnamed';
    end
    if PNVStart>0
        for i=PNVStart:2:ni
            % Set each Property Name/Value pair in turn. 
            Property = varargin{i};
            if i+1>ni
                error(message('MATLAB:timeseries:init:pvsetNoValue'))
            else
                Value = varargin{i+1};
            end
            % Perform assignment
            switch lower(char(Property))
                case 'name'
                    % Assign the name
                    if ischar(Value) || isstring(Value)
                        % Name has been specified 
                        this.Name = char(Value);
                    end
                case 'istimefirst'
                    if ~isempty(Value) && isscalar(Value) && islogical(Value) 
                        % IsTimeFirst has been specified
                        istimefirst = Value;
                    else
                        error(message('MATLAB:timeseries:init:pvsetScalarTimeFirst'))
                    end
                case 'isdatenum'
                    if ~isempty(Value) && isscalar(Value) && islogical(Value) 
                        % IsTimeFirst has been specified
                        isdatenumprovided = Value;
                    else
                        error(message('MATLAB:timeseries:init:pvsetScalarDatenum'))
                    end
                case 'interpretsinglerowdataas3d'
                    if ~isempty(Value) && islogical(Value)
                        % interpretSingleRowDataAs3D has been specified
                        interpretSingleRowDataAs3D = Value;
                    else
                        error(message('MATLAB:timeseries:init:scalarOneRowDataAsThreeD'))
                    end 
                case 'starttime'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % startTime has been specified
                        startTime = Value;
                    else
                        error(message('MATLAB:timeseries:init:pvsetScalarStartTime'))
                    end  
                case 'endtime'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % endTime has been specified
                        endTime = Value;
                    else
                        error(message('MATLAB:timeseries:init:pvsetScalarEndTime'))
                    end 
                case 'interval'
                    if ~isempty(Value) && isnumeric(Value) && isscalar(Value)
                        % interval has been specified
                        interval = Value;
                    else
                        error(message('MATLAB:timeseries:init:pvsetScalarInterval'))
                    end 
                otherwise
                    error(message('MATLAB:timeseries:init:pvsetInvalid'))
           end % switch
        end % for
    end

    % Parse inputs
    switch dataInputStartPos
        % PV starts from the 1st input argument
        case 0
            % Data array must be the first input
            error(message('MATLAB:timeseries:init:data'))
        % PV starts from the 2nd input argument
        case 1         
            % Accept: timeseries(data),timeseries([])
            if ~isnumeric(varargin{1}) && ~islogical(varargin{1}) && ...
                    ~isobject(varargin{1})
                error(message('MATLAB:timeseries:init:nodata'))
            else
                data = varargin{1};
            end
            sizeData = size(data); 
            if (sizeData(1) == 1 && length(sizeData) == 2)
                time = struct('Length',sizeData(2),...
                	'StartTime',startTime, 'EndTime',endTime,'Interval',interval);
            else
                time = struct('Length',sizeData(1)*(length(sizeData) == 2) + sizeData(end)*(length(sizeData) > 2),...
                	'StartTime',startTime, 'EndTime',endTime,'Interval',interval);
            end
        case {2, 3}
            % Process data vector first
            if ~isnumeric(varargin{1}) && ~islogical(varargin{1}) && ...
                    ~isobject(varargin{1})
                    error(message('MATLAB:timeseries:init:nodata'))
            else
                data = varargin{1};
            end
                
            % Deal with second arg.  Note: don't change the order of the
            % following if-else if branch structure
            definedTimeLength = [];
            if isempty(varargin{2}) 
                % 2nd arg is empty
                
                if ~isempty(data)
                    sizeData = size(data);
                    % Create a uniform time struct from any uniform time params
                    if (sizeData(1) == 1 && length(sizeData) == 2)
                        time = struct('Length',sizeData(2),...
                        	'StartTime',startTime, 'EndTime',endTime,'Interval',interval);
                    else
                        time = struct('Length',sizeData(1)*(length(sizeData) == 2) + sizeData(end)*(length(sizeData) > 2),...
                        	'StartTime',startTime, 'EndTime',endTime,'Interval',interval);
                    end
                else
                    time = varargin{2};
                end
            elseif isa(varargin{2},'tsdata.timemetadata') 
                % 2nd arg is a timemetadata object (required by Simulink Timeseries)
                % still build a local time vector
                time = varargin{2};
                definedTimeLength = time.Length;
            elseif ischar(varargin{2}) 
                % Multi-row char array, treat as absolute time vector
                time = mat2cell(varargin{2},ones(size(varargin{2},1),1),size(varargin{2},2));
                definedTimeLength = length(time);
            elseif isstring(varargin{2})
                % String array, treat as absolute time vector
                time = cellstr(varargin{2});
                definedTimeLength = length(time);
            elseif isnumeric(varargin{2})
                % Second argument is a time vector
                time = varargin{2};
                definedTimeLength = length(time);
            elseif iscell(varargin{2}) 
                % Second argument is a cell array. If it contains no dates
                % (chars), try to convert it to a numeric array. If the
                % cell array contains strigs, convert it to a cellstr
                time = varargin{2};
                Istrings = cellfun('isclass',time,'string');
                if ~any(cellfun('isclass',time,'char') | Istrings)
                    % numeric time values stored in cell array
                    time = cell2mat(time);
                elseif any(Istrings)
                    time = cellstr(time);
                end
                definedTimeLength = length(time);
            else
                error(message('MATLAB:timeseries:init:notime'))
            end

            % If time and interpretSingleRowDataAs3D were specified but 
            % istimefirst was not, istimefirst can be unambiguously 
            % calculated 
            if ~isempty(definedTimeLength) && ~isempty(interpretSingleRowDataAs3D) 
                    istimefirstTemp = tsdata.datametadata.isTimeFirst(size(data),...
                        definedTimeLength,interpretSingleRowDataAs3D);
                    if isempty(istimefirst) || istimefirst == istimefirstTemp 
                        istimefirst = istimefirstTemp;
                    else 
                        error(message('MATLAB:timeseries:init:incompatibleIsTimeFirst'));
                    end
            end
            
            if dataInputStartPos == 3
                if iscell(varargin{3})
                    error(message('MATLAB:timeseries:init:qualitycell'))
                else
                    quality = varargin{3};
                end        
            end
        otherwise
            error(message('MATLAB:timeseries:init:input'))
    end


    size_data = size(data);
    % For empty time assign the empty data (0x... or ...x0).
     if isempty(time)
        if size(time,1)~=0
            this.Time = time(:);
        else
            this.Time = time;
        end
        this.Data = data;
        this.Quality = [];
        this.BeingBuilt = false;
        warning(b_state);
        warning(w_state);
        return;    
    elseif isnumeric(time) || isstruct(time) || iscell(time) || ...
             isa(time,'tsdata.timemetadata')
       % Check the time format only if it is a numeric vector
       if isnumeric(time)          
           time = timeseries.tsChkTime(time);
       end

       if isnumeric(time) || iscell(time)
           lenTime = length(time);
       elseif isstruct(time) || isa(time,'tsdata.timemetadata')
           lenTime = time.Length;
       else
           error(message('MATLAB:timeseries:init:invtime')) 
       end
       
       % Attempt to reshape incompatible data, time and quality
       [data,quality] = timeseries.utreshape(lenTime,data,quality);
      
       % Sort time and data vectors
       if isnumeric(data) || islogical(data)
           % Check the order of time only if it is specified as a numeric
           % array or cell array
           % check if Calculated IsTimeFirst is same as the istimefirst
           % value if not error out
           
           calculateIsTimeFirstValue = tsdata.datametadata.isTimeFirst(size(data),...
                            lenTime,interpretSingleRowDataAs3D);
           if ~isempty(istimefirst) && ~isequal(calculateIsTimeFirstValue,istimefirst)
                   error(message('MATLAB:timeseries:utreshape:datatimearraymismatch'));
           end
           
           % Convert non-numeric times
           if isnumeric(time)
               [time, data, quality] = ...
                   timeseries.utsorttime(time,data,quality,calculateIsTimeFirstValue);
           elseif iscell(time)
               [~, data, quality, I] = timeseries.utsorttime(datenum(time),...
                  data,quality,calculateIsTimeFirstValue);                
           end
       end
    end
    
    % Assign the time vector
    % If datenum values are provided
    if ~isempty(isdatenumprovided) && isdatenumprovided && isnumeric(time)
        time = datestr(time);
        this.TimeInfo.Units = 'days';
        this = setabstime(this,time);
    elseif isnumeric(time)
        this.Time = time;
    % If date strings are provided        
    elseif iscell(time)
        % Absolute date never sorted before  
        this.TimeInfo.Units = 'days';
        this = setabstime(this,time(I));        
    elseif isstruct(time) && isfield(time,'StartTime') && isfield(time,'EndTime') && ...
            isfield(time,'Interval')
        % Create a tsdata.timemetadata with deprecation warnings for object
        % setting using the create static constructor.
        timeInfo = tsdata.timemetadata.create;
        
        timeInfo = timeInfo.setlength(time.Length);
        if time.Length>=2
           this.TimeInfo = timeInfo.setuniformtime(time.StartTime,...
               time.Interval,time.EndTime);
        elseif time.Length==1
           this.TimeInfo = timeInfo.reset(0);
        else
           this.TimeInfo = timeInfo;
        end
    elseif isa(time,'tsdata.timemetadata')
        this.TimeInfo = varargin{2};
    else
           error(message('MATLAB:timeseries:init:invtime')) 
    end
   
    
    
    if ~isempty(istimefirst)
        this.IsTimeFirst_ = istimefirst;
    end
    if ~isempty(quality)
        this.Quality = quality;
    end
    
    % Write custom interpretSingleRowDataAs3D to DataInfo. 
    if ~isempty(interpretSingleRowDataAs3D)
        this.DataInfo.InterpretSingleRowDataAs3D = interpretSingleRowDataAs3D;
    end
    this.Data = data;
catch me % Restore warning state before rethrowing error
    warning(b_state);
    warning(w_state);
    rethrow(me);
end
this.BeingBuilt = false;
warning(b_state);
warning(w_state);
