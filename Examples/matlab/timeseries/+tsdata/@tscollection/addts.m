function addts(this,data,varargin)

% Copyright 2004-2017 The MathWorks, Inc.

if isa(data,'tsdata.timeseries')
    this.TsValue = addts(this.TsValue,data.TsValue,varargin{:});
else
    this.TsValue = addts(this.TsValue,data,varargin{:});
end