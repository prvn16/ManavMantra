function h = polarhistogram( varargin )
%POLARHISTOGRAM  Plots a histogram in polar coordinates.
%   POLARHISTOGRAM(THETA) plots an angluar histogram of THETA. The angles 
%   in the vector THETA must be specified in radians. POLARHISTOGRAM 
%   determines the bin edges using an automatic binning algorithm that 
%   returns uniform bins of a width that is chosen to cover the range 
%   of values in THETA and reveal the shape of the underlying distribution. 
%
%   POLARHISTOGRAM(THETA,M), where M is a scalar, uses M bins.
%
%   HISTOGRAM(THETA,EDGES), where EDGES is a vector, specifies the edges of 
%   the bins.
%
%   The value THETA(i) is in the kth bin if 
%   EDGES(k) <= THETA(i) < EDGES(k+1). The last bin will also include the 
%   right edge such that it will contain THETA(i) if 
%   EDGES(end-1) <= THETA(i) <= EDGES(end).
%
%   POLARHISTOGRAM(...,'BinWidth',BW) uses bins of width BW. To prevent from 
%   accidentally creating too many bins, a limit of 65536 bins can be 
%   created when specifying 'BinWidth'. If BW is too small such that more 
%   than 65536 bins are needed, HISTOGRAM uses wider bins instead.
%
%   POLARHISTOGRAM(...,'BinLimits',[BMIN,BMAX]) plots a histogram choosing
%   bins only within the range of BMIN to BMAX.
%
%   POLARHISTOGRAM(...,'Normalization',NM) specifies the normalization scheme 
%   of the histogram values. The normalization scheme affects the scaling 
%   of the histogram along the radial axis. NM can be:
%                  'count'   The height of each bar is the number of 
%                            observations in each bin, and the sum of the
%                            bar heights is NUMEL(THETA).
%            'probability'   The height of each bar is the relative 
%                            number of observations (number of observations
%                            in bin / total number of observations), and
%                            the sum of the bar heights is 1.
%           'countdensity'   The height of each bar is the number of 
%                            observations in each bin / width of bin. The 
%                            area (height * width) of each bar is the number
%                            of observations in the bin, and the sum of
%                            the bar areas is NUMEL(THETA).
%                    'pdf'   Probability density function estimate. The height 
%                            of each bar is, (number of observations in bin)
%                            / (total number of observations * width of bin).%                            
%               'cumcount'   The height of each bar is the cumulative 
%                            number of observations in each bin and all
%                            previous bins. The height of the last bar
%                            is NUMEL(THETA).
%                    'cdf'   Cumulative density function estimate. The height 
%                            of each bar is the cumulative relative number
%                            of observations in each bin and all previous bins.
%                            The height of the last bar is 1.
%
%   POLARHISTOGRAM(...,'DisplayStyle',STYLE) specifies the display style of the 
%   histogram. STYLE can be:
%                    'bar'   Display a histogram bar plot. This is the default.
%                 'stairs'   Display a stairstep plot, which shows the 
%                            outlines of the histogram without filling the 
%                            interior. 
%
%   POLARHISTOGRAM(...,'BinMethod',BM), uses the specified automatic binning 
%   algorithm to determine the number and width of the bins. BM can be:
%                   'auto'   The default 'auto' algorithm chooses a bin 
%                            width to cover the data range and reveal the 
%                            shape of the underlying distribution.
%                  'scott'   Scott's rule is optimal if the data is close  
%                            to being normally distributed, but is also 
%                            appropriate for most other distributions. It 
%                            uses a bin width of 
%                            3.5*STD(THETA(:))*NUMEL(THETA)^(-1/3).
%                     'fd'   The Freedman-Diaconis rule is less sensitive  
%                            to outliers in the data, and may be more 
%                            suitable for data with heavy-tailed 
%                            distributions. It uses a bin width of 
%                            2*IQR(THETA(:))*NUMEL(THETA)^(-1/3), where IQR is the 
%                            interquartile range.
%               'integers'   The integer rule is useful with integer data, 
%                            as it creates a bin for each integer. It uses 
%                            a bin width of 1 and places bin edges halfway 
%                            between integers. To prevent from accidentally 
%                            creating too many bins, a limit of 65536 bins 
%                            can be created with this rule. If the data 
%                            range is greater than 65536, then wider bins
%                            are used instead.
%                'sturges'   Sturges' rule is a simple rule that is popular
%                            due to its simplicity. It chooses the number 
%                            of bins to be CEIL(1 + LOG2(NUMEL(THETA))).
%                   'sqrt'   The Square Root rule is another simple rule 
%                            widely used in other software packages. It 
%                            chooses the number of bins to be
%                            CEIL(SQRT(NUMEL(THETA))).
%
%   POLARHISTOGRAM(...,NAME,VALUE) set the property NAME to VALUE. 
%     
%   POLARHISTOGRAM('BinEdges', EDGES, 'BinCounts', COUNTS) where COUNTS is a 
%   vector of length equal to length(EDGES)-1, manually specifies
%   the bin counts. POLARHISTOGRAM plots the counts and does not do any data binning.
%
%   POLARHISTOGRAM(AX,...) plots into AX instead of the current axes.
%       
%   H = POLARHISTOGRAM(...) also returns a histogram object. Use this to inspect 
%   and adjust the properties of the histogram.
%
%   Class support for inputs THETA, EDGES:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      logical
%
%   See also HISTCOUNTS, HISTOGRAM2, HISTCOUNTS2, DISCRETIZE, matlab.graphics.chart.primitive.Histogram

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,inf)
[cax, args] = axescheck(varargin{:});
if ~isempty(cax) && ~isa(cax, 'matlab.graphics.axis.PolarAxes')
    error(message('MATLAB:polarplot:AxesInput'));
end

% Check whether the first input is an axes input, which would have been
% stripped by the axescheck function
firstaxesinput = (rem(length(varargin) - length(args),2) == 1);
if ~isempty(args) && ~matlab.graphics.internal.isCharOrString(args{1})
    varName = inputname(1+firstaxesinput);
else
    varName = '';
end

if ~isempty(args) %validate first non-axes non-string arg (data)
    args = matlab.graphics.internal.convertStringToCharArgs(args);
    if ~matlab.graphics.internal.isCharOrString(args{1})
        data = args{1};
        validateattributes(data, {'numeric','logical'}, {'real'}, ...
        'polarhistogram', 'theta values');
    else % validate values in Data p-v pairs
        dataindex = find(strcmpi(args,'Data'));
        for i=1:length(dataindex)
            data = args{dataindex(i)+1};
            validateattributes(data, {'numeric','logical'}, {'real'}, ...
        'polarhistogram', 'theta values');
        end
    end
    
end

try
    cax = matlab.graphics.internal.prepareCoordinateSystem('polar', cax);

    obj = histogram(args{:},'Parent',cax);
    
    %set up data linking
    if ~isempty(varName)
        hlink = hggetbehavior(obj,'Linked');
        % Only enable linking if the data is a vector and BinCounts not specified.
        % Brushing behavior is designed for vector data and does not work well
        % with matrix data
        
        if isvector(obj.Data) && strcmpi(obj.BinCountsMode,'auto')
            hlink.YDataSource = varName;
        end
        if isempty(get(obj,'DisplayName'))
            obj.DisplayName = hlink.YDataSource;
        end
        
        % If applying to a linked plot the linked plot graphics cache must
        % be updated manually since there are not yet eventmanager listeners
        % to do this automatically.
        f = ancestor(obj,'figure');
        if ~isempty(f.findprop('LinkPlot')) && f.LinkPlot
            datamanager.updateLinkedGraphics(f);
        end
    end

catch e
    throw(e);
end

if nargout > 0
    h = obj;
end

end

