function delsample(this,method,value)

% Copyright 2004-2006 The MathWorks, Inc.

cacheTimes = this.TsValue.Time;
this.TsValue = delsample(this.Tsvalue,method,value);
[junk,I] = setdiff(cacheTimes,this.TsValue.Time);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'delsample',I));
 
 
