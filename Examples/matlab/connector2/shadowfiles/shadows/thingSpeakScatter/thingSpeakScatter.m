function thingSpeakScatter( varargin )
%THINGSPEAKSCATTER Scatter/bubble plot.
%   THINGSPEAKSCATTER(X,Y) draws the markers in the default size and color.
%
%   THINGSPEAKSCATTER(X,Y,S,C) displays colored circles at the locations specified
%   by the vectors X and Y (which must be the same size).  
%
%   S determines the area of each marker (in points^2). S can be a
%   vector the same length a X and Y or a scalar. If S is a scalar, 
%   MATLAB draws all the markers the same size. If S is empty, the
%   default size is used.
%   
%   C determines the colors of the markers. When C is a vector the
%   same length as X and Y, the values in C are linearly mapped
%   to the colors in the current colormap. C can also be a color string. 
%   See ColorSpec.
%
%   THINGSPEAKSCATTER(X,Y,S) draws the markers at the specified sizes (S)
%   with a single color. This type of graph is also known as
%   a bubble plot.
%
%   THINGSPEAKSCATTER(X,Y,[],C) draws the markers with the specified colors (C)
%   with a single marker. 
%
%   THINGSPEAKSCATTER(...,'filled') fills the markers.


%   Copyright 2015 The MathWorks, Inc. 

    % Don't expose stack trace in warnings inside webplots
    status = warning('off', 'backtrace');
    cleanup = onCleanup(@() warning(status));
 
    try
        chart = thingspeak.ScatterChart(varargin{:});
        thingspeak.ChartService.addChart(chart);
    catch ME
        error(ME.identifier, ME.message);
    end

end

