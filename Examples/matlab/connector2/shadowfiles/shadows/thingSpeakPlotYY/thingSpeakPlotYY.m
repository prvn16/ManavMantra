function thingSpeakPlotYY( varargin )
%THINGSPEAKPLOTYY Graphs with y tick labels on the left and right
%
%   THINGSPEAKPLOTYY(X1,Y1,X2,Y2) plots Y1 versus X1 with y-axis labeling
%   on the left and plots Y2 versus X2 with y-axis labeling on
%   the right.

%   Copyright 2015 The MathWorks, Inc. 

    % Don't expose stack trace in warnings inside webplots
    status = warning('off', 'backtrace');
    cleanup = onCleanup(@() warning(status));
 
    try
        chart = thingspeak.YYChart(varargin{:});
        thingspeak.ChartService.addChart(chart);
    catch ME
        error(ME.identifier, ME.message);
    end

end

