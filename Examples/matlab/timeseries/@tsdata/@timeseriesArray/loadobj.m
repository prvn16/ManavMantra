function h = loadobj(s)

% Place holder for obsolete @timeseries classes

%   Copyright 2006 The MathWorks, Inc.

h = tsdata.timeseriesArray;
if isstruct(s)
    if ~isfield(s,'Data') % Loaded @timeseriesArray may be empty
        s.Data = [];
    end
    if ~isfield(s,'GridFirst') % Loaded @timeseriesArray may be empty
        s.GridFirst = true;
    end
    h.LoadedData = s;
else
    h = s;
end
