function init(this,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

this.TsValue = init(this.TsValue,varargin{:});
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'init',[]));