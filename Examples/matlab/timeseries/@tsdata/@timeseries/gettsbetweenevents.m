function ts = gettsbetweenevents(this,event1,event2,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

ts = this.copy;
ts.TsValue = gettsbetweenevents(this.Tsvalue,event1,event2,varargin{:});



