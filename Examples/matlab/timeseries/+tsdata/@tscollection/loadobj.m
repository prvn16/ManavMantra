function h = loadobj(s)
%LOADOBJ Overloaded load

%   Copyright 2004-2017 The MathWorks, Inc.

h = tsdata.tscollection;

if isstruct(s) % Object is former udd object
    props = fieldnames(s);
    h.TsValue = tscollection;
    for k=1:length(props)
        if isa(s.(props{k}),'tsdata.timeseriesArray') && ...
                strcmpi(s.(props{k}).LoadedData.Variable.Name,'time')
            h.TsValue.TimeInfo = s.(props{k}).LoadedData.MetaData;
            if ~isempty(s.(props{k}).LoadedData.Data)
                h.TsValue.Time = s.(props{k}).LoadedData.Data;
            end
        elseif isa(s.(props{k}),'tsdata.timeseries')
            h.TsValue = addts(h.TsValue,s.(props{k}).TsValue);
        else
            h.(props{k}) = s.(props{k});
        end
    end
    h.TsValue.BeingBuilt = false;
elseif isa(s,'tsdata.tscollection')
    h = s;
else
    h = [];
end