function thingSpeakStem( varargin )
%THINGSPEAKSTEM Discrete sequence or "stem" plot.
%   THINGSPEAKSTEM(Y) plots the data sequence Y as stems from the x axis
%   terminated with circles for the data value. If Y is a matrix then
%   each column is plotted as a separate series.
%
%   THINGSPEAKSTEM(X,Y) plots the data sequence Y at the values specified
%   in X.
%
%   THINGSPEAKSTEM(...,'filled') produces a stem plot with filled markers.
%
%   THINGSPEAKSTEM(...,'LINESPEC') uses the color specified for the stems and
%   markers. 

%   Copyright 2015 The MathWorks, Inc.

    % Don't expose stack trace in warnings inside webplots
    status = warning('off', 'backtrace');
    cleanup = onCleanup(@() warning(status));
 
    try
        chart = thingspeak.StemChart(varargin{:});
        thingspeak.ChartService.addChart(chart);
    catch ME
        error(ME.identifier, ME.message);
    end

end

