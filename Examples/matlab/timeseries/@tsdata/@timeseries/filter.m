function filter(this,n,d,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

this.Tsvalue = filter(this.Tsvalue,n,d,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'filter',[]));


