function ts = getsampleusingtime(this,StartTime,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

ts = tsdata.timeseries;
ts.TsValue = getsampleusingtime(this.Tsvalue,StartTime,varargin{:});


