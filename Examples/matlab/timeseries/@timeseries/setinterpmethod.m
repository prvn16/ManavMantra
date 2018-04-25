function ts = setinterpmethod(ts,varargin)
%SETINTERPMETHOD  Set default interpolation method in a time series.
%
%   TS = SETINTERPMETHOD(TS,METHOD), where METHOD is a string, sets the default
%   interpolation method, METHOD, in TS. METHOD can be either 'linear' or
%   'zoh' (zero-order hold). For example: 
%       ts = timeseries(rand(100,1),1:100);
%       ts = setinterpmethod(ts,'zoh')
%
%   TS = SETINTERPMETHOD(TS,FHANDLE), where FHANDLE is a function handle, sets
%   the interpolation method in TS to a special interpolation method
%   defined in the function handle FHANDLE.  For example:
%       ts = timeseries(rand(100,1),1:100);
%       myFuncHandle = @(new_Time,Time,Data) interp1(Time,Data,new_Time,'linear','extrap');
%       ts = setinterpmethod(ts,myFuncHandle);
%       ts = resample(ts,[-5:0.1:10]);
%       plot(ts);
%   Note: for FHANDLE, (1) the number of input arguments must be three; (2)
%   the order of input arguments must be new_Time, Time, and Data; (3) the
%   single output argument must be the interpolated data only. 
%
%   TS = SETINTERPMETHOD(TS,INTERPOBJ), where INTERPOBJ is a
%   tsdata.interpolation object, directly replaces the interpolation object
%   stored in time series TS. For example:
%       ts = timeseries(rand(100,1),1:100);
%       myFuncHandle = @(new_Time,Time,Data) interp1(Time,Data,new_Time,'linear','extrap');
%       myInterpObj = tsdata.interpolation(myFuncHandle);
%       ts = setinterpmethod(ts,myInterpObj);
%
%   See also TIMESERIES/GETINTERPMETHOD, TIMESERIES/TIMESERIES

%   Copyright 2005-2011 The MathWorks, Inc.

narginchk(2,3);
if numel(ts)~=1
    error(message('MATLAB:timeseries:setinterpmethod:noarray'));
end

ts.DataInfo.interpolation = varargin{:};

