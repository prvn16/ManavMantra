function merge(ts1,ts2,method,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

[ts1.TsValue,ts2.TsValue] = synchronize(ts1.TsValue,ts2.TsValue,method,varargin{:});
ts1.fireDataChangeEvent(tsdata.dataChangeEvent(ts1,'merge',[]));
ts2.fireDataChangeEvent(tsdata.dataChangeEvent(ts2,'merge',[]));



