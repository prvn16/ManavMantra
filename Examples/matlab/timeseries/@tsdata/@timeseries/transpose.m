function transpose(this)

% Copyright 2005-2006 The MathWorks, Inc.

this.TsValue = transpose(this.Tsvalue);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'transpose',[]));



