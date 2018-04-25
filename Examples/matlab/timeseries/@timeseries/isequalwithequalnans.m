function iseq = isequalwithequalnans(ts1,ts2)

% Copyright 2007-2014 The MathWorks, Inc.

narginchk(2,2);
if numel(ts1)~=1 || numel(ts2)~=1
    error(message('MATLAB:timeseries:isequalwithequalnans:noarray'));
end

% Make sure we have two timeseries
if ~isa(ts1, 'timeseries') || ~isa(ts2, 'timeseries')
    iseq = false;
    return;
end

iseq = isequalwithequalnans(ts1.Data,ts2.Data) && ...
       isequal(ts1.Time,ts2.Time) && ...
       isequal(ts1.Quality,ts2.Quality) && ...
       isequal(ts1.DataInfo,ts2.DataInfo) && ...
       isequal(ts1.TimeInfo,ts2.TimeInfo) && ...
       isequal(ts1.QualityInfo,ts2.QualityInfo) && ...
       isequal(ts1.Name,ts2.Name) && ...
       isequal(ts1.TreatNaNasMissing,ts2.TreatNaNasMissing) && ...
       isequal(ts1.IsTimeFirst,ts2.IsTimeFirst) && ...
       isequal(ts1.Events,ts2.Events);