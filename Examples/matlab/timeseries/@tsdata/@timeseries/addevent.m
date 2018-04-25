function addevent(h,e,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

h.Tsvalue = addevent(h.TsValue,e,varargin{:});
h.fireDataChangeEvent(tsdata.dataChangeEvent(h,'addevent',[]));