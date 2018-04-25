function hout = copy(h)

% Copyright 2004-2006 The MathWorks, Inc.

hout = tsdata.timeseries;
hout.TsValue = h.TsValue;
hout.Name = h.Name;
hout.DataChangeEventsEnabled = h.DataChangeEventsEnabled;


