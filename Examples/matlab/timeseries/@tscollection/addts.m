function h = addts(h, data, varargin)
%ADDTS  Add data vector or time series object into tscollection.
%
% TSC = ADDTS(TSC,TS) adds a time series TS into tscollection TSC.
%
% TSC = ADDTS(TSC,TS), where TS is a cell array of time series, adds all the time
% series into tscollection TSC. 
%
% TSC = ADDTS(TSC,TS,NAME), where TS is a cell array of time series and NAME is a
% cell array of strings, adds all the time series into tscollection TSC
% using the name NAME.
%
% TSC = ADDTS(TSC,DATA,NAME), where DATA is a numerical array and NAME is a string,
% creates a new time series using DATA and NAME, and then adds it into tscollection TSC
%

%   Copyright 2005-2016 The MathWorks, Inc.

% Validate the number of the input arguments
N = nargin;
narginchk(2,4);
% errmsg = nargchk(2,4,N); %#ok<NCHK>
% if ~isempty(errmsg)
%      error('tscollection:addts:inargs',errmsg);
% end
% deal with name
if N==2
    if iscell(data)
        if isvector(data) && all(cellfun(@(x) isa(x,'timeseries'),data))
            name = cell(1,length(data));
            for i=1:length(data)
                name(i) = {localGenVarName(data{i}.Name)};
            end
        else
            error(message('MATLAB:tscollection:addts:badcell'));
        end
    elseif isa(data,'timeseries')
        name = localGenVarName(data.Name);
    else
        error(message('MATLAB:tscollection:addts:badinput')) 
    end
else
    if iscell(varargin{1}) % Cell array of strings or char vectors
        if any(cellfun('isclass',varargin{1},'string'))
            % Convert cell arrays of string to cellstr
            varargin{1} = cellstr(varargin{1});
        elseif ~iscellstr(varargin{1})
            % If varargin{1} not a cell array of strings then we assume
            % that its a cell array of char vectors
            error(message('MATLAB:tscollection:addts:badname'))
        end
        name = cell(1,length(data));
        for i=1:length(varargin{1})
            name(i) = {localGenVarName(varargin{1}{i})};
        end
    elseif isstring(varargin{1}) && length(varargin{1})>1
        % varargin{1} is a true array of strings
        name = cell(1,length(data));
        for i=1:length(varargin{1})
            name(i) = {localGenVarName(varargin{1}(i))};
        end        
    elseif ischar(varargin{1}) || isstring(varargin{1})
        % varargin{1} is a single string or char vector
        name = localGenVarName(varargin{1});
    else
        error(message('MATLAB:tscollection:addts:badname')) 
    end
end

% Prepare name string
if iscellstr(name)
    if length(unique(name))<length(name)
        error(message('MATLAB:tscollection:addts:dupinputnames'));
    end
    for i=1:length(name)
        if any(strcmpi(name{i},gettimeseriesnames(h)))
            error(message('MATLAB:tscollection:addts:dupexistingname')) 
        end
    end
elseif any(strcmpi(name,gettimeseriesnames(h)))
    error(message('MATLAB:tscollection:addts:dupexistingname'))
end

% If tscollection object is initially empty (truly case)
if iscell(data)
    if isvector(data) && all(cellfun(@(x) isa(x,'timeseries'),data))
        for i=1:length(data)
            localCheckTS(h,data{i});
            h = localUpdateTS(h,data{i},name{i});
        end
    end
else
    % Create a local ts object based on data
    if isa(data,'timeseries')
        localCheckTS(h,data);
        ts = data;
    else
        s = size(data);
        if s(1) == h.Length
            ts = timeseries(data,h.Time,'IsTimeFirst',true);
        elseif s(end)==h.Length
            ts = timeseries(data,h.Time,'IsTimeFirst',false);
        elseif h.Length==1
            tsnames = gettimeseriesnames(h);
            defaultInterpretSingleRowDataAs3D = true;
            for k=1:length(tsnames)
                thists = getts(h,tsnames{k});
                if (thists.DataInfo.InterpretSingleRowDataAs3D~=defaultInterpretSingleRowDataAs3D)
                    defaultInterpretSingleRowDataAs3D = false;
                    break;
                end
            end
            ts = timeseries(data,h.Time,'InterpretSingleRowDataAs3D',defaultInterpretSingleRowDataAs3D);
        else
            error(message('MATLAB:tscollection:addts:baddata'))
        end 
    end
    % Check if datainfo is available
    if N==4 && isa(varargin{2},'tsdata.datametadata')
        ts.DataInfo = varargin{2};
        h = localUpdateTS(h,ts,name);
    else
        h = localUpdateTS(h,ts,name);
    end
end



%------------------------------------------------------------------------
function localCheckTS(h,ts)

% Allow time vectors to mismatch when adding a timeseries to an
% empty tscollection
if isempty(h.Members_) && isempty(h.Time)
    return
end

tsIntimevec = tsunitconv(h.TimeInfo.Units,ts.TimeInfo.Units)*ts.Time;

% If the tscollection has an absolute time vector any added time series
% must have a matching abs time vector
if ~isempty(h.TimeInfo.StartDate) 
    if isempty(ts.TimeInfo.StartDate) 
        error(message('MATLAB:tscollection:localCheckTS:badstartdate'))
    end
    % Account for differences in References of the tscollection and the
    % added timeseries
    tmpT = tsgetrelativetime(ts.TimeInfo.StartDate,h.TimeInfo.StartDate,h.TimeInfo.Units);    
    tsIntimevec = tsIntimevec+tmpT;
else
    if ~isempty(ts.TimeInfo.StartDate) 
        warning(message('MATLAB:tscollection:localCheckTS:ignorestartdate'))
    end    
end

% Does the time vector match
if ~tsIsSameTime(tsIntimevec,h.Time)
    error(message('MATLAB:tscollection:localCheckTS:badtime'))
end

% Does the timemetadata class change
if ~strcmp(class(ts.TimeInfo),class(h.TimeInfo))
    warning(message('MATLAB:tscollection:localCheckTS:classchange'))
end

%--------------------------------------------------------------------------
function h = localUpdateTS(h,ts,name)

% Update this tscollection object with the new time series if it does not
% have an invalid name

ts.Name = name;

if any(strcmpi(name,methods(h)))
    error(message('MATLAB:tscollection:localUpdateTS:badmethod', name))
end
if strcmpi(ts.Name,'timeseries')
    error(message('MATLAB:tscollection:localUpdateTS:badproperty', name))
end

% Add this ts object into the collection
% Allow time vectors to mismatch when adding a timetimereis to an
% empty tscollection
if isempty(h.Members_) && isempty(h.Time)
    h.Time = ts.Time;
end
h = setts(h,ts,ts.Name);

%--------------------------------------------------------------------------
function varName = localGenVarName(S)
% Return the variable name as a char vector
varName = char(matlab.lang.makeUniqueStrings(...
	matlab.lang.makeValidName(S), {}, namelengthmax));
