classdef Histogram2< matlab.graphics.primitive.Data & matlab.graphics.mixin.Legendable & matlab.graphics.chart.interaction.DataAnnotatable & matlab.graphics.mixin.Selectable & matlab.graphics.mixin.AxesParentable & matlab.graphics.mixin.UIAxesParentable & matlab.graphics.internal.Legacy
    methods
        function out=Histogram2
        end

        function doGetDataDescriptors(in) %#ok<MANU>
        end

        function doGetDisplayAnchorPoint(in) %#ok<MANU>
        end

        function doGetEnclosedPoints(in) %#ok<MANU>
        end

        function doGetInterpolatedPoint(in) %#ok<MANU>
        end

        function doGetInterpolatedPointInDataUnits(in) %#ok<MANU>
        end

        function doGetNearestIndex(in) %#ok<MANU>
        end

        function doGetNearestPoint(in) %#ok<MANU>
        end

        function doGetNearestPointInDataUnits(in) %#ok<MANU>
        end

        function doGetReportedPosition(in) %#ok<MANU>
        end

        function doIncrementIndex(in) %#ok<MANU>
        end

        function fewerbins(in) %#ok<MANU>
            % FEWERBINS   Decrease the number of histogram bins
            %    N = FEWERBINS(H) decreases the number of histogram bins 
            %    along each dimension by 10%, rounding down to the next 
            %    integers, and returns the new numbers.
            %
            %    N = FEWERBINS(H,'x') decreases along the X dimension only.
            %
            %    N = FEWERBINS(H,'y') decreases along the Y dimension only.
            %
            %    N = FEWERBINS(H,'both') is the same as FEWERBINS(H).
            %
            % See also matlab.graphics.chart.primitive.Histogram2/morebins
        end

        function getPropertyGroups(in) %#ok<MANU>
        end

        function morebins(in) %#ok<MANU>
            % MOREBINS   Increase the number of histogram bins
            %    N = MOREBINS(H) increases the number of histogram bins 
            %    along each dimension by 10%, rounding up to the next 
            %    integers, and returns the new numbers.
            %
            %    N = MOREBINS(H,'x') increases along the X dimension only.
            %
            %    N = MOREBINS(H,'y') increases along the Y dimension only.
            %
            %    N = MOREBINS(H,'both') is the same as MOREBINS(H).
            %
            % See also matlab.graphics.chart.primitive.Histogram2/fewerbins
        end

    end
    methods (Abstract)
    end
    properties
        % BinCounts - Bin Counts
        %    NBINSX-by-NBINSY matrix, where NBINSX and NBINSY are the number 
        %    of bins along X and Y dimensions respectively, specifies how 
        %    many elements of Data fall into each bin. Compared to the Values 
        %    property, BinCounts is not normalized. If Normalization is 
        %    'count', then BinCounts is equivalent to Values.
        BinCounts;

        % BinCountsMode - Selection mode for bin counts
        %    BinCountsMode can be 'auto' or 'manual'. When 'auto', the bin
        %    counts are automatically computed from Data, XBinEdges, and 
        %    YBinEdges. If you specify BinCounts, then BinCountsMode is
        %    automatically set to 'manual'. Similarly, if you specify Data, 
        %    then BinCountsMode is automatically set to 'auto'.
        BinCountsMode;

        % BinMethod - Binning algorithm
        %    BinMethod specifies a binning algorithm that automatically 
        %    determines the number and size of the bins. BinMethod can be:
        %       'auto' - The default 'auto' algorithm chooses a bin width
        %                to cover the data range and reveal the shape of 
        %                the underlying distribution.
        %       'scott' - Scott's rule is optimal if the data is close to 
        %                being jointly normally distributed, but is also 
        %                appropriate for most other distributions. It uses 
        %                a bin width of 3.5*STD(Data(:))*NUMEL(Data)^(-1/4). 
        %       'fd' - The Freedman-Diaconis rule is less sensitive to 
        %                outliers in the data, and may be more suitable for 
        %                data with heavy-tailed distributions. It uses a 
        %                bin width of 2*IQR(Data(:))*NUMEL(Data)^(-1/4), 
        %                where IQR is the interquartile range.  
        %       'integers' -  The integer rule is useful with integer data, 
        %                as it creates a bin for each pair of integer 
        %                X and Y. It uses a bin width of 1 along each 
        %                dimension and places bin edges halfway 
        %                between integers. To prevent from accidentally 
        %                creating too many bins, a limit of 1024 bins 
        %                can be created along each dimension with this 
        %                rule. If the data range along either dimension 
        %                is greater than 1024, then larger bins are used 
        %                instead.
        %
        %    If you set the NumBins, XBinEdges, YBinEdges, BinWidth, 
        %    or BinLimits property, then the BinMethod property is set 
        %    to 'manual'.
        BinMethod;

        % BinWidth - Size of bins
        %    Non-negative two-element vector specifying the size of the bins. 
        %    If you specify nonuniform bin edges using XBinEdges or 
        %    YBinEdges properties, then BinWidth is set to 'nonuniform'.
        BinWidth;

        % Data - The data to distribute among bins
        %    Data is a N-by-2 matrix where N is the number of data points.
        %    The first column denotes the X coordinates and the second 
        %    column the Y coordinates. 
        %
        %    Histogram2 ignores all data points that contain NaNs. Similarly, 
        %    Histogram2 ignores Inf and -Inf values unless the bin edges 
        %    explicitly include Inf or -Inf as a bin edge.
        Data;

        % DisplayStyle - Histogram display style
        %    DisplayStyle can be 'bar3', or 'tile'. With 'bar3', the 
        %    histogram is displayed as 3-D bars. With 'tile', the 
        %    histogram is displayed as a rectangular array of tiles with 
        %    colors indicating the bin values.
        DisplayStyle;

        % EdgeAlpha - Transparency of histogram bar edges        
        % 	 Scalar between 0 and 1 inclusive, which specifies the 
        %    transparency of the bar edges. A value of 1 means fully opaque 
        %    and 0 means completely transparent. Default value is 1. 
        EdgeAlpha;

        % EdgeColor - Histogram edge color
        %    EdgeColor can be one of the following:
        %       'auto' - The histogram bar edge colors are chosen automatically.
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
        %       'flat' - The histogram bar colors varies with height. Bars 
        %                with different height will have different color. 
        %                The colors are selected from the figure or axes 
        %                colormap. 
        %       'none' - The histogram bars are not filled.
        %       RGB triplet or color string - The histogram bars are filled
        %                with the specified color.                     
        FaceColor;

        % FaceLighting - Lighting effect on histogram bars
        %    FaceLighting can be one of the following:
        %       'lit' - Histogram bars displays pseudo-lighting effect, 
        %               where the sides of the bars use darker colors 
        %               relative to the tops. They are also unaffected 
        %               by other light sources in the axes. This is the 
        %               default when DisplayStyle is 'bar3'.
        %       'flat' - Histogram bars are not lit automatically, but in
        %                the presence of other light objects, lighting 
        %                effect is uniform across the bar faces.
        %       'none' - Lights do not affect the histogram bars.
        %    FaceLighting can only be 'none' when DisplayStyle is 'tile'. 
        FaceLighting;

        % LineStyle - Histogram edge line style
        %    Specifies the style of the bar edges. Default is solid lines. 
        LineStyle;

        % LineWidth - Histogram edge line width
        %    Positive scalar specifying the width of the bar edges. Default 
        %    value is 0.5. 
        LineWidth;

        % Normalization - Type of normalization
        %    The normalization scheme that affects the scaling of the 
        %    histogram along the Z axis. Normalization can be: 
        %       'count' - The height of each bar is the number of 
        %                 observations in each bin, and the sum of the
        %                 bar heights is NUMEL(X(:)) or NUMEL(Y(:)).
        %       'probability' - The height of each bar is the relative 
        %                 number of observations (number of observations
        %                 in bin / total number of observations), and
        %                 the sum of the bar heights <= 1.
        %       'countdensity' - The height of each bar is, (the number of 
        %                 observations in each bin) / (area of bin). The 
        %                 volume (height * area) of each bar is the number
        %                 of observations in the bin, and the sum of
        %                 the bar volumes is NUMEL(X) or NUMEL(Y).
        %       'pdf' - Probability density function estimate. The height 
        %                 of each bar is, (number of observations in bin)
        %                 / (total number of observations * area of bin).
        %                 The volume of each bar is the relative number of
        %                 observations, and the sum of the bar volumes <= 1.
        %       'cumcount' - The height of each bar is the cumulative 
        %                 number of observations in each bin and all
        %                 previous bins in both the X and Y dimensions. 
        %                 The height of the last bar is NUMEL(X) or 
        %                 NUMEL(Y).
        %       'cdf' - Cumulative density function estimate. The height 
        %                 of each bar is the cumulative relative number
        %                 of observations in each bin and all previous 
        %                 bins in both the X and Y dimensions. The height 
        %                 of the last bar <= 1.
        Normalization;

        % NumBins - Number of bins
        %    2-element vector that contains positive integers 
        %    specifying the number of bins used in the histogram
        %    along the two dimensions.
        NumBins;

        % ShowEmptyBins - Turn display of empty bins on or off
        %    'on' or 'off', specifies whether empty bins are displayed. 
        %    Default value is 'off'.
        ShowEmptyBins;

        % Values - Bin values
        %    Matrix of size NumBins(1)-by-NumBins(2) that specifies 
        %    how many elements of Data fall into each bin, or a 
        %    normalized variant depending on the Normalization propery. 
        %    Compared to BinCounts property, Values is normalized. 
        %    If Normalization is 'count', Values is equivalent to BinCounts.
        %    This property is read-only.
        Values;

        % XBinEdges - Edges of bins along X dimension
        %    Row vector specifying the edges of the bins along the X
        %    dimension. XBinEdges(1) is the lower edge of the first bin 
        %    and XBinEdges(end) is the upper edge of the last bin. 
        %    XBinEdges must be monotonically non-decreasing.
        %
        %    Data(k,:) is in the (i,j)th bin if XBinEdges(i) <= 
        %    Data(k,1) < XBinEdges(i+1) and YBinEdges(j) <= Data(k,2) <
        %    YBinEdges(j+1). The last column and rows of bins also include 
        %    the upper bin edge.
        XBinEdges;

        % XBinLimits - bin limits along the X dimension
        %    Two element vector [xbmin,xbmax] that specifies the first and 
        %    last bin edges along the X dimension. The histogram is only 
        %    plotted with data that falls between the limits inclusively, 
        %    Data(Data(:,1)>=xbmin & Data(:,1)<=xbmax
        XBinLimits;

        % XBinLimitsMode - Selection mode for bin limits along X dimension
        %    XBinLimitsMode can be 'auto' or 'manual'. When 'auto', the bin
        %    limits automatically adjust to the data along the X axis. If 
        %    you explicitly specify XBinLimits or XBinEdges, then 
        %    XBinLimitsMode is automatically set to 'manual'.
        XBinLimitsMode;

        % YBinEdges - Edges of bins along Y dimension
        %    Row vector specifying the edges of the bins along the Y
        %    dimension. YBinEdges(1) is the lower edge of the first bin 
        %    and YBinEdges(end) is the upper edge of the last bin. 
        %    YBinEdges must be monotonically non-decreasing.
        %
        %    Data(k,:) is in the (i,j)th bin if XBinEdges(i) <= 
        %    Data(k,1) < XBinEdges(i+1) and YBinEdges(j) <= Data(k,2) <
        %    YBinEdges(j+1). The last column and rows of bins also include 
        %    the upper bin edge.
        YBinEdges;

        % YBinLimits - bin limits along the Y dimension
        %    Two element vector [ybmin,ybmax] that specifies the first and 
        %    last bin edges along the Y dimension. The histogram is only 
        %    plotted with data that falls between the limits inclusively, 
        %    Data(Data(:,2)>=ybmin & Data(:,2)<=ybmax                
        YBinLimits;

        % YBinLimitsMode - Selection mode for bin limits along Y dimension
        %    YBinLimitsMode can be 'auto' or 'manual'. When 'auto', the bin
        %    limits automatically adjust to the data along the Y axis. If 
        %    you explicitly specify YBinLimits or YBinEdges, then 
        %    YBinLimitsMode is automatically set to 'manual'.        
        YBinLimitsMode;

    end
end

     
    %   Copyright 2015-2017 The MathWorks, Inc.

