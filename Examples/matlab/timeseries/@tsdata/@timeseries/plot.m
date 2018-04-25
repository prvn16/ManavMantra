function varargout = plot(h,varargin)
%PLOT  Plot time series data
%
%   PLOT(TS) plot the timeseries data against its time using either
%   zero-order-hold or linear interpolation. If the interpolation behavior
%   of the timeseries data is 'zoh', a stair plot is generated, otherwise a
%   regular plot is created.
%
%   Timeseries events, if present, are marked in the plot using a red
%   circular marker.  
%
%   PLOT accepts the modifiers used by MATLAB's PLOT utility for numerical
%   arrays. These modifiers can be specified as auxiliary inputs for
%   modifying the appearance of the plot.
%
%   Examples:
%   plot(ts,'-r*') plots using a regular line with color red and marker '*'.
%   plot(ts,'ko','MarkerSize',3) uses black circular markers of size 3 to
%   render the plot.
%
%   See also PLOT, TSDATA/TIMESERIES, TIMESERIES/ADDEVENT
%

%   Copyright 2005-2012 The MathWorks, Inc.

if nargout>0
    [varargout{1:nargout}] = plot(h.TsValue,varargin{:});
else
    plot(h.TsValue,varargin{:});
end