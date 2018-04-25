function idealfilter(this,intervals,type,varargin) 

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = idealfilter(this.Tsvalue,intervals,type,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'idealfilter',[]));


