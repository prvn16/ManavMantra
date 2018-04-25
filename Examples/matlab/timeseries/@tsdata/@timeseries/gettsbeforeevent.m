function ts = gettsbeforeevent(this,event,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

ts = this.copy;
ts.TsValue = gettsbeforeevent(this.Tsvalue,event,varargin{:});



