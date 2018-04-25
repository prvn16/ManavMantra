function detrend(this,type,varargin) 

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = detrend(this.Tsvalue,type,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'detrend',[]));


