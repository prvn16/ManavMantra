function h = loadobj(s)
% LOADOBJ  Overloaded load command

%   Copyright 2004-2010 The MathWorks, Inc.

% When attempting to load sp2 time series objects, reconstruct the time
% series (for Sys Bio)
if isstruct(s)
    h = tsdata.timeseries;
    h.TsValue = localLoadObj(s);
elseif isa(s,'tsdata.timeseries')
    h = s;
else 
    h = [];
end

function h = localLoadObj(s)

h = timeseries;
% Get the data, time and quality
for k=1:length(s.Data_)
    switch s.Data_(k).LoadedData.Variable.Name
        case 'Data'
            data = s.Data_(k).LoadedData.Data;
            interpObj = [];
            if ishandle(s.Data_(k).LoadedData.MetaData) || isobject(s.Data_(k).LoadedData.MetaData)
                dataunits = s.Data_(k).LoadedData.MetaData.Units;
                datauserdata = s.Data_(k).LoadedData.MetaData.UserData;
                if ~isempty(s.Data_(k).LoadedData.MetaData.Interpolation) && ...
                        ishandle(s.Data_(k).LoadedData.MetaData.Interpolation)
                    interpObj = s.Data_(k).LoadedData.MetaData.Interpolation;
                end
            else
                dataunits = '';
                datauserdata = [];
            end
            isTimeFirst = s.Data_(k).LoadedData.GridFirst;      
        case 'Time'
            time = s.Data_(k).LoadedData.Data;
            if isempty(time)
                time = s.Data_(2).LoadedData.MetaData.getData;
            end
            try
                timeunits = s.Data_(k).LoadedData.MetaData.Units;
            catch %#ok<CTCH>
                timeunits = 'seconds';
            end
            try
                startdate = s.Data_(k).LoadedData.MetaData.StartDate;
            catch %#ok<CTCH>
                startdate = '';
            end
        case 'Quality'
            try
                qual = s.Data_(k).LoadedData.Data;
                qualInfoCodes = s.Data_(k).LoadedData.MetaData.Code;
                qualInfoDesr = s.Data_(k).LoadedData.MetaData.Description;
            catch %#ok<CTCH>
                qual = [];
                qualInfoCodes = [];
                qualInfoDesr = {};
            end
    end
end

% Initialize the object
if isempty(data) && ~isempty(time)
    if isTimeFirst
        data = zeros(length(time),0);
    else
        data = zeros(0,length(time));
    end
end
h = init(h,data,time,qual,'Name',s.Name,'IsTimeFirst',isTimeFirst);

% DataInfo: units & userdata
dataInfo = h.DataInfo; 
dataInfo.Units = dataunits;
dataInfo.UserData = datauserdata;
if ~isempty(interpObj)
    dataInfo.Interpolation = interpObj;
end
h.dataInfo = dataInfo;
% TimeInfo: units and StartDate
timeInfo = h.TimeInfo;
timeInfo.Units = timeunits;
timeInfo.StartDate = startdate;
h.TimeInfo = timeInfo;
% Qualityinfo: code and description
qualInfo = h.QualityInfo;
qualInfo.Code = qualInfoCodes;
qualInfo.Description = qualInfoDesr; 
h.QualityInfo = qualInfo;
% Events
if isfield(s,'Events')
    h.Events = s.Events;
end
% Instance props from 2006a 2006b
 % Any fieldnames which do not correspond to timeseries
 % properties (except Grid_,InstancePropValues_,
 % InstancePropNames are instance properties). Add them as
 % a struct in the UserData property.
cTimeSeries = ?timeseries;
instanceProps = setdiff(fields(s),cellfun(@(x) {x.Name},cTimeSeries.Properties));
instanceProps = setdiff(instanceProps,{'Grid_','InstancePropNames_',...
    'InstancePropValues_'});
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