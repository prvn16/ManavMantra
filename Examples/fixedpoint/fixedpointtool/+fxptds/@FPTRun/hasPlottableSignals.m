function b = hasPlottableSignals(this)
% HASPLOTTABLESIGNALS return true if contained results have time series data.

% Copyright 2016-2017 The MathWorks, Inc.

timeseriesId = this.getTimeSeriesRunID;
b = ~isempty(timeseriesId);
