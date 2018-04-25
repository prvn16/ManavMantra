function this = init(this,varargin)
%INIT  Initialize a tscollection object with new time or new time series.
%
%   INIT(TSC,TIME) initializes the tscollection object TSC using new
%   time vector TIME. Note: When the times are date strings, the TIME must
%   be specified as a cell array of date strings. 
%
%   INIT(TSC,TS) initializes the tscollection object TSC with a time series
%   object TS. Note: the times in TS will be used as the common time vector. 
%
%   INIT(TSC,TS) initializes the tscollection object TSC with a cell array
%   of time series objects stored in TS.
%
%   You can enter property-value pairs after the TIME or TS arguments:
%       'PropertyName1', PropertyValue1, ...
%   that set the following additional properties of tscollection object: 
%       (1) 'Name': a string that specifies the name of this tscollection object.  
%       (3) 'isDatenum': a logical value, when TRUE, indicates that the time vector
%       consists of DATENUM values
%

%   Copyright 2006-2016 The MathWorks, Inc.
%

% validate the number of the input arguments
narginchk(2,inf);

%% PV starts
ni = nargin-1; % ni >= 1
DataInputs = 0;
PNVStart = 0;
while DataInputs<ni && PNVStart==0
  nextarg = varargin{DataInputs+1};
  if (ischar(nextarg) && isvector(nextarg)) || (isstring(nextarg) && isscalar(nextarg))
     % Single string or char vector
     PNVStart = DataInputs+1;  
  else
     DataInputs = DataInputs+1;
  end
end
%% Deal with PV set
% initialize name
if isempty(this.Name)
    this.Name = 'unnamed';
end
isdatenumprovided = [];
if PNVStart>0
    for i=PNVStart:2:ni
        % Set each Property Name/Value pair in turn. 
        Property = varargin{i};
        if i+1>ni
            error(message('MATLAB:tscollection:init:pvsetNoValue'))
        else
            Value = varargin{i+1};
        end
        % Perform assignment
        switch lower(Property)
            case 'name'
                % Assign the name
                if ~isempty(Value) && (ischar(Value) || isstring(Value))
                    % Name has been specified  as a string or char vector
                    this.Name = char(Value);
                end
            case 'isdatenum'
                if ~isempty(Value) && isscalar(Value) && islogical(Value) 
                    % IsTimeFirst has been specified
                    isdatenumprovided = Value;
                else
                    error(message('MATLAB:tscollection:init:nonScalarDatenum'))
                end
            otherwise
                error(message('MATLAB:tscollection:init:pvsetInvalid'))
       end % switch
    end % for
end

if builtin('isempty',varargin{1}) 
    this.TimeInfo = tsdata.timemetadata;
    return
elseif isa(varargin{1},'timeseries')
    ts = varargin{1};
    if ts.Length==0
        this.TimeInfo = tsdata.timemetadata;
        return
    end
    % Single time series object, use its time as the common time
    % vector and insert the object
    if ts.TimeInfo.Length>0
        this.TimeInfo = ts.TimeInfo;
        this.Time = ts.Time;
        this = this.addts(ts);
    else
        error(message('MATLAB:tscollection:init:emptytimeseries'))
    end          
elseif iscell(varargin{1}) && all(cellfun(@(x) isa(x,'timeseries'),varargin{1}(:)))
    tsCellArray = varargin{1}(:);
    if tsCellArray{1}.TimeInfo.Length>0
        this.TimeInfo = tsCellArray{1}.TimeInfo;
        this.Time = tsCellArray{1}.Time;
        this = this.addts(tsCellArray);
    else
        error(message('MATLAB:tscollection:init:emptytimeseries'))
    end
elseif isnumeric(varargin{1}) || iscell(varargin{1}) || (ischar(varargin{1}) && ...
        min(size(varargin{1}))>1) || (isstring(varargin{1}) && ~isscalar(varargin{1}))
    % varargin{1} is a true char array, true string array, cell array, or numeric
    this.TimeInfo = tsdata.timemetadata;
    %this.TimeInfo = setlength(this.TimeInfo,NaN);
    % Common time vector
    time = varargin{1};
    if ischar(time) || isstring(time)
        time = cellstr(time);
    end

    % Sort time when necessary
    if ~isempty(time) 
        % Validate time vector
        if isnumeric(time)
            try
               time = tsChkTime(time);
            catch me
                rethrow(me)
            end
        end
        if isnumeric(time)
            I = tssorttime(time);
        else
            I = (1:length(time))';
        end
        % Assign the time vector
        if ~isempty(isdatenumprovided) && isdatenumprovided
            try
                time = datestr(time);
            catch me
                rethrow(me)
            end
            this.TimeInfo.Units = 'days';
            this.TimeInfo = setlength(this.TimeInfo,length(time));
            this = this.setabstime(time);	
        % If date strings are provided        
        elseif iscell(time) || isstring(time)
            if isstring(time) || any(cellfun('isclass',time,'string'))
                % Convert string arrays or cell arrays of strings to a
                % cellstr
                I = tssorttime(datenum(cellstr(time))); 
            else
                I = tssorttime(datenum(time)); 
            end
            this.TimeInfo.Units = 'days';
            this.TimeInfo = setlength(this.TimeInfo,length(I));
            this = this.setabstime(time(I));	
        else
            this.TimeInfo = setlength(this.TimeInfo,length(I));
            this.Time = time(I);
        end
    else
        error(message('MATLAB:tscollection:init:nosingleton'))
    end
    
else
    error(message('MATLAB:tscollection:init:notimevectornocellarray'))
end
this.BeingBuilt = false;   


