function addsample(this,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

cacheTimes = this.TsValue.Time;
this.Tsvalue = addsample(this.TsValue,varargin{:});
[junk,I] = setdiff(this.TsValue.Time,cacheTimes);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'addsample',I));