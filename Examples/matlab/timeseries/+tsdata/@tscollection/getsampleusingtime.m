function tscout = getsampleusingtime(this,StartTime,varargin)

% Copyright 2005-2017 The MathWorks, Inc.

tscout = tsdata.tscollection;
tscout.TsValue = getsampleusingtime(tsc.TsValue,StartTime,varargin{:});