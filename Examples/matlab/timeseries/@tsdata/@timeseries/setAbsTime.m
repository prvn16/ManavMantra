function setAbsTime(this,timeArray,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = setabstime(this.TsValue,timeArray,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'setAbsTime',[]));


