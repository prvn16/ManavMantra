function tsout = plus(ts1, ts2, varargin)

% Copyright 2004-2014 The MathWorks, Inc.

if isnumeric(ts2)
    tsout = copy(ts1);
    tsout.TsValue = plus(ts1.TsValue,ts2,varargin{:});
elseif isnumeric(ts1)
    tsout = copy(ts2);
    tsout.TsValue = plus(ts1,ts2.TsValue,varargin{:});    
else
    tsout = copy(ts1);
    tsout.TsValue = plus(ts1.TsValue,ts2.TsValue,varargin{:});
end



