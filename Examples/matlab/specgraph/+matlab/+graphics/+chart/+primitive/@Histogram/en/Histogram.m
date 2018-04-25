classdef Histogram< matlab.graphics.primitive.Data & matlab.graphics.mixin.Legendable & matlab.graphics.chart.interaction.DataAnnotatable & matlab.graphics.mixin.Selectable & matlab.graphics.mixin.AxesParentable & matlab.graphics.mixin.PolarAxesParentable & matlab.graphics.mixin.UIAxesParentable & matlab.graphics.internal.Legacy
    methods
        function out=Histogram
        end

        function fewerbins(in) %#ok<MANU>
            % FEWERBINS   Decrease the number of histogram bins
            %    N = FEWERBINS(H) decreases the number of histogram bins in H by 10%,
            %    rounding down to the next integer, and returns the new number.
            %
            % See also matlab.graphics.chart.primitive.Histogram/morebins
        end

        function morebins(in) %#ok<MANU>
            % MOREBINS   Increase the number of histogram bins
            %    N = MOREBINS(H) increases the number of histogram bins in H by 10%,
            %    rounding up to the next integer, and returns the new number.
            %
            % See also matlab.graphics.chart.primitive.Histogram/fewerbins
        end

    end
    methods (Abstract)
    end
    properties
        % BinCounts - Bin Counts
        %    Row vector that specifies how many elements of Data fall into
        %    each bin. Compared to the Values property, BinCounts is not 
        %    normalized. If Normalization is 'count', then BinCounts is 
        %    equivalent to Values.
        BinCounts;

        % BinCountsMode - Selection mode for bin counts
        %    BinCountsMode can be 'auto' or 'manual'. When 'auto', the bin
        %    counts are automatically computed from Data and BinEdges. If 
        %    you specify BinCounts, then BinCountsMode is automatically set 
        %    to 'manual'. Similarly, if you specify Data, then BinCountsMode 
        %    is automatically set to 'auto'.
        BinCountsMode;

        % BinEdges - Edges of bins
        %    Row vector specifying the edges of the bins. BinEdges(1) is
        %    the left edge of the first bin and BinEdges(end) is the right
        %    edge of the last bin. BinEdges must be monotonically
        %    non-decreasing.
        %
        %    Data(i) is in the kth bin if BinEdges(k) <= Data(i) <
        %    BinEdges(k+1). The last bin also include the right bin edge,
        %    so that it contains Data(i) if BinEdges(end-1) <= Data(i) <=
        %    BinEdges(end).
        BinEdges;

        % BinLimits - bin limits
        %    Two element vector [bmin,bmax] that specifies the leftmost and
        %    rightmost bin edges. The histogram is only plotted with data
        %    that falls between bmin and bmax inclusive, Data(Data>=bmin &
        %    Data<=bmax).
        BinLimits;

        % BinLimitsMode - Selection mode for bin limits
        %    BinLimitsMode can be 'auto' or 'manual'. When 'auto', the bin
        %    limits automatically adjust to the data. If you explicitly 
        %    specify either BinLimits or BinEdges, then BinLimitsMode is
        %    automatically set to 'manual'.
        BinLimitsMode;

        % BinMethod - Binning algorithm
        %    BinMethod specifies a binning algorithm that automatically 
        %    determines the number and width of the bins. BinMethod can be:
        %       'auto' - The default 'auto' algorithm chooses a bin width
        %                to cover the data range and reveal the shape of 
        %                the underlying distribution.
        %       'scott' - Scott's rule is optimal if the data is close to 
        %                being normally distributed, but is also appropriate
        %                for most other distributions. It uses a bin width
        %                of 3.49*STD(Data(:))*NUMEL(Data)^(-1/3). 
        %       'fd' - The Freedman-Diaconis rule is less sensitive to 
        %                outliers in the data, and may be more suitable for 
        %                data with heavy-tailed distributions. It uses a 
        %                bin width of 2*IQR(Data(:))*NUMEL(Data)^(-1/3), 
        %                where IQR is the interquartile range.  
        %       'integers' - The integer rule is useful with integer data, 
        %                as it creates a bin for each integer. It uses a 
        %                bin width of 1 and places bin edges halfway between
        %                integers. To prevent from accidentally creating 
        %                too many bins, a limit of 65536 bins can be created
        %                with this rule. If the data range is greater than 
        %                65536, then wider bins are used instead. This option 
        %                is not supported for datetime or duration data.
        %       'sturges' - Sturges' rule is a simple rule that is popular
        %                due to its simplicity. It chooses the number of 
        %                bins to be CEIL(1 + LOG2(NUMEL(Data))). 
        %       'sqrt' - The Square Root rule is another simple rule widely 
        %                used in other software packages. It chooses the 
        %                number of bins to be CEIL(SQRT(NUMEL(Data))).
        %    For datetime data, BinMethod can also be the following time units: 
        %    'second', 'minute', 'hour', 'day', 'week', 'month', 'quarter', 
        %    'year', 'decade', or 'century'. For duration data, BinMethod 
        %    can be these time units: 'second', 'minute', 'hour', 'day', 
        %    'year'. If BinMethod is a time unit, histogram places 
        %     bin edges at boundaries of the time unit.
        %
        %    If you set the NumBins, BinEdges, BinWidth, or BinLimits 
        %    property, then the BinMethod property is set to 'manual'.
        BinMethod;

        % BinWidth - Width of bins
        %    Non-negative scalar specifying the width of the bins if the
        %    bins are uniform. If Data is datetime, BinWidth must be a 
        %    scalar duration or calendarDuration. If you specify nonuniform 
        %    bin edges using the BinEdges property, then BinWidth is set to 
        %    'nonuniform'.
        BinWidth;

        % Data - The data to distribute among bins
        %    Data is either a vector, matrix, or multidimensional 
        %    array, can be numeric, logical, datetime, or duration. If Data 
        %    is not a vector, then Histogram treats it as a single column 
        %    vector Data(:), and plots a single histogram. 
        %
        %    Histogram ignores all NaN values in Data. Similarly,
        %    Histogram ignores Inf and -Inf values unless the bin edges
        %    explicitly include Inf or -Inf as a bin edge.
        Data;

        % DisplayStyle - Histogram display style
        %    DisplayStyle can be 'bar' or 'stairs'. Specify 'stairs' to 
        %    display a stairstep plot, which displays the outline of the
        %    histogram without filling the interior. 
        %
        %    The default value of 'bar' displays a histogram bar plot.
        DisplayStyle;

        % EdgeAlpha - Transparency of histogram bar edges
        % 	 Scalar between 0 and 1 inclusive, which specifies the
        %    transparency of the bar edges. A value of 1 means fully opaque
        %    and 0 means completely transparent. Default value is 1.
        EdgeAlpha;

        % EdgeColor - Histogram edge color
        %    EdgeColor can be one of the following:
        %       'auto' - The histogram bar edge colors are chosen 
        %                automatically.
        %       'none' - The histogram bar edges are not drawn.
        %       RGB triplet or color string - The histogram bar edges use 
        %                the specified color.
        EdgeColor;

        % FaceAlpha - Transparency of histogram bars
        %    Scalar between 0 and 1 inclusive.  histogram uses the same 
        %    transparency for all the bars of the histogram. A value of 1 
        %    means fully opaque and 0 means completely transparent.
        FaceAlpha;

        % FaceColor - Histogram bar color
        %    FaceColor can be one of the following:
        %       'auto' - The histogram bar colors are chosen automatically.
        %       'none' - The histogram bars are not filled.
        %       RGB triplet or color string - The histogram bars are filled
        %                with the specified color.                     
        %
        %    FaceColor is ignored if DisplayStyle is 'stairs'.
        FaceColor;

        % LineStyle - Histogram edge line style
        %    Specifies the style of the bar edges. Default is solid lines. 
        LineStyle;

        % LineWidth - Histogram edge line width
        %    Positive scalar specifying the width of the bar edges. Default 
        %    value is 0.5. 
        LineWidth;

        % Normalization - Type of normalization
        %    The normalization scheme that affects the scaling of the 
        %    histogram along the vertical axis (or horizontal axis if 
        %    Orientation is 'horizontal'). Normalization can be:
        %       'count' - The height of each bar is the number of 
        %                 observations in each bin, and the sum of the
        %                 bar heights is NUMEL(Data).
        %       'probability' - The height of each bar is the relative 
        %                 number of observations (number of observations
        %                 in bin / total number of observations), and 
        %                 the sum of the bar heights <= 1. 
        %       'countdensity' - The height of each bar is the number of 
        %                 observations in each bin / width of bin. The area 
        %                 (height * width) of each bar is the number 
        %                 of observations in the bin, and the sum of 
        %                 the bar areas is NUMEL(Data). This option is not 
        %                 supported for datetime or duration data.
        %       'pdf' - Probability density function estimate. The height 
        %                 of each bar is, (number of observations in bin) 
        %                 / (total number of observations * width of bin). 
        %                 The area of each bar is the relative number of 
        %                 observations, and the sum of the bar areas <= 1.
        %                 This option is not supported for datetime or 
        %                 duration data.
        %       'cumcount' - The height of each bar is the cumulative 
        %                 number of observations in each bin and all
        %                 previous bins. The height of the last bar
        %                 is NUMEL(Data).
        %       'cdf' - Cumulative density function estimate. The height 
        %                 of each bar is the cumulative relative number 
        %                 of observations in the bin and all previous bins. 
        %                 The height of the last bar <= 1. 
        Normalization;

        % NumBins - Number of bins
        %    Positive integer scalar specifying the number of bins used
        %    in the histogram.
        NumBins;

        % Orientation - Orientation of histogram
        %    Orientation can be 'vertical' or 'horizontal', which specifies
        %    the orientation of the histogram bars.
        Orientation;

        % Values - Bin values
        %    Row vector that specifies how many elements of Data fall into
        %    each bin, or a normalized variant depending on the 
        %    Normalization property. Compared to BinCounts property, Values
        %    is normalized. If Normalization is 'count', Values is 
        %    equivalent to BinCounts. This property is read-only.
        Values;

    end
end

     
    %   Copyright 2014-2016 The MathWorks, Inc.

