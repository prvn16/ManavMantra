function iseq = eq(ts1,ts2)

% Copyright 2006-2014 The MathWorks, Inc.

% If one object is empty, return []
if isempty(ts1) || isempty(ts2)
    iseq = [];
    return;
end

% Make sure we have two timeseries
if ~isa(ts1, 'timeseries') || ~isa(ts2, 'timeseries')
    iseq = false;
    return;
end

% If object is scalar do an element-wise comparison against the scalar
% timeseries
if numel(ts1)==1 && ~isempty(ts2)
    iseq = false(size(ts2));
    for k=1:numel(ts2)
        iseq(k) = localeq(ts1,ts2(k));
    end
    return
end

% Check that the sizes agree
if ~isequal(size(ts1),size(ts2))
    error(message('MATLAB:timeseries:eq:sizemismatch'))
end

% Do an element-wise comparison
iseq = false(size(ts2));
for k=1:numel(ts1)
    iseq(k) = localeq(ts1(k),ts2(k));
end

function eqstate = localeq(ts1,ts2)

eqstate = isequal(ts1.Data,ts2.Data) && ...
       isequal(ts1.TimeInfo,ts2.TimeInfo) && ...
       isequal(ts1.Quality,ts2.Quality) && ...
       isequal(ts1.DataInfo,ts2.DataInfo) && ...       
       isequal(ts1.QualityInfo,ts2.QualityInfo) && ...
       isequal(ts1.Name,ts2.Name) && ...
       isequal(ts1.TreatNaNasMissing,ts2.TreatNaNasMissing) && ...
       isequal(ts1.IsTimeFirst,ts2.IsTimeFirst) && ...
       isequal(ts1.Events,ts2.Events);
    
    
    