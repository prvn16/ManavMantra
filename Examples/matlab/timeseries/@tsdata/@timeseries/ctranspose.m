function ctranspose(this)

%   Copyright 2005-2011 The MathWorks, Inc.

this.TsValue = ctranspose(this.Tsvalue);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'ctranspose',[]));



