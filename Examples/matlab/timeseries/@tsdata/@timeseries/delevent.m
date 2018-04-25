function delevent(this,event,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

this.TsValue = delevent(this.Tsvalue,event,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'delevent',[]));


