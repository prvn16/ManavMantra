function thingSpeakPlot( varargin )
%THINGSPEAKPLOT Linear plot.
%   THINGSPEAKPLOT(X,Y) plots vector Y versus vector X. If X or Y is a matrix,
%   then the vector is plotted versus the rows or columns of the matrix,
%   whichever line up.  If X is a scalar and Y is a vector, disconnected
%   line objects are created and plotted as discrete points vertically at
%   X.
%
%   THINGSPEAKPLOT(Y) plots the columns of Y versus their index.
%   
%   Various line types, plot symbols and colors may be obtained with
%   THINGSPEAKPLOT(X,Y,S) where S is a character string made from one element
%   from any or all the following 3 columns:
%
%          b     blue          .     point              -     solid
%          g     green         o     circle             :     dotted
%          r     red           x     x-mark             -.    dashdot 
%          c     cyan          +     plus               --    dashed   
%          m     magenta       *     star             (none)  no line
%          y     yellow        s     square
%          k     black         d     diamond
%          w     white         v     triangle (down)
%                              ^     triangle (up)
%                              <     triangle (left)
%                              >     triangle (right)
%                              p     pentagram
%                              h     hexagram
%                         
%   For example, THINGSPEAKPLOT(X,Y,'c+:') plots a cyan dotted line with a plus 
%   at each data point; THINGSPEAKPLOT(X,Y,'bd') plots blue diamond at each data 
%   point but does not draw any line.
%
%   The THINGSPEAKPLOT command, if no color is specified, makes automatic use of
%   the colors specified by the axes ColorOrder property.  By default,
%   THINGSPEAKPLOT cycles through the colors in the ColorOrder property.
%
%   Note that RGB colors in the ColorOrder property may differ from
%   similarly-named colors in the (X,Y,S) triples.  For example, the 
%   second axes ColorOrder property is medium green with RGB [0 .5 0],
%   while THINGSPEAKPLOT(X,Y,'g') plots a green line with RGB [0 1 0].
%
%   If you do not specify a marker type, THINGSPEAKPLOT uses no marker. 
%   If you do not specify a line style, THINGSPEAKPLOT uses a solid line.
%
%   The X,Y pairs can be followed by parameter/value pairs to specify additional 
%   properties of the lines. For example, THINGSPEAKPLOT(X,Y,'LineWidth',2,'Color',[.6 0 0]) 
%   will create a plot with a dark red line width of 2 points.

%   Copyright 2015 The MathWorks, Inc. 

    % Don't expose stack trace in warnings inside webplots
    status = warning('off', 'backtrace');
    cleanup = onCleanup(@() warning(status));
    
    try
        chart = thingspeak.LineChart(varargin{:});
        thingspeak.ChartService.addChart(chart);
    catch ME
        error(ME.identifier, ME.message);
    end

end
