function resample(this,timevec,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = resample(this.TsValue,timevec,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'resample',[]));


