function ts = gettsafterevent(this,event,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

ts = this.copy;
ts.TsValue = gettsafterevent(this.Tsvalue,event,varargin{:});



