function setInterpMethod(this,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = setinterpmethod(this.TsValue,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'setInterpMethod',[]));


