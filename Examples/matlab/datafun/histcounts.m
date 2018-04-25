function [n,edges,bin] = histcounts(x, varargin)
%HISTCOUNTS  Histogram Bin Counts.
%   [N,EDGES] = HISTCOUNTS(X) partitions the values in X into bins, and 
%   returns the count in each bin, as well as the bin edges. HISTCOUNTS uses 
%   an automatic binning algorithm that returns bins with a uniform width, 
%   chosen to cover the range of elements in X and reveal the underlying 
%   shape of the distribution. X can be a vector, matrix, or multidimensional 
%   array. If X is not a vector, then HISTCOUNTS treats it as a single column 
%   vector, X(:).
%
%   N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1). The 
%   last bin will also include the right edge such that N(end) will count
%   X(i) if EDGES(end-1) <= X(i) <= EDGES(end).
%
%   [N,EDGES] = HISTCOUNTS(X,M), where M is a scalar, uses M bins.
%
%   [N,EDGES] = HISTCOUNTS(X,EDGES), where EDGES is a vector, specifies the 
%   edges of the bins.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinWidth',BW) uses bins of width BW. To 
%   prevent from accidentally creating too many bins, a limit of 65536 bins
%   can be created when specifying 'BinWidth'. If BW is too small such that 
%   more than 65536 bins are needed, HISTCOUNTS uses wider bins instead.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinLimits',[BMIN,BMAX]) bins only elements 
%   in X between BMIN and BMAX inclusive, X(X>=BMIN & X<=BMAX).
%
%   [N,EDGES] = HISTCOUNTS(...,'Normalization',NM) specifies the
%   normalization scheme of the histogram values returned in N. NM can be:
%                  'count'   Each N value is the number of observations in 
%                            each bin. SUM(N) is generally equal to 
%                            NUMEL(X), but is less than if some of 
%                            the input data is not included in the bins. 
%                            This is the default.
%            'probability'   Each N value is the relative number of 
%                            observations (number of observations in bin / 
%                            total number of observations), and SUM(N) is 
%                            less than or equal to 1.
%           'countdensity'   Each N value is the number of observations in 
%                            each bin divided by the width of the bin. 
%                    'pdf'   Probability density function estimate. Each N 
%                            value is, (number of observations in bin) / 
%                            (total number of observations * width of bin).
%               'cumcount'   Each N value is the cumulative number of 
%                            observations in each bin and all previous bins. 
%                            N(end) is less than or equal to NUMEL(X).
%                    'cdf'   Cumulative density function estimate. Each N 
%                            value is the cumulative relative number of 
%                            observations in each bin and all previous bins. 
%                            N(end) is less than or equal to 1.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinMethod',BM), uses the specified automatic 
%   binning algorithm to determine the number and width of the bins.  BM can be:
%                   'auto'   The default 'auto' algorithm chooses a bin 
%                            width to cover the data range and reveal the 
%                            shape of the underlying distribution.
%                  'scott'   Scott's rule is optimal if X is close to being 
%                            normally distributed, but is also appropriate
%                            for most other distributions. It uses a bin width
%                            of 3.5*STD(X(:))*NUMEL(X)^(-1/3).
%                     'fd'   The Freedman-Diaconis rule is less sensitive to 
%                            outliers in the data, and may be more suitable 
%                            for data with heavy-tailed distributions. It 
%                            uses a bin width of 2*IQR(X(:))*NUMEL(X)^(-1/3), 
%                            where IQR is the interquartile range.
%               'integers'   The integer rule is useful with integer data, 
%                            as it creates a bin for each integer. It uses 
%                            a bin width of 1 and places bin edges halfway 
%                            between integers. To prevent from accidentally 
%                            creating too many bins, a limit of 65536 bins 
%                            can be created with this rule. If the data 
%                            range is greater than 65536, then wider bins 
%                            are used instead.
%                'sturges'   Sturges' rule is a simple rule that is popular
%                            due to its simplicity. It chooses the number of
%                            bins to be CEIL(1 + LOG2(NUMEL(X))).
%                   'sqrt'   The Square Root rule is another simple rule 
%                            widely used in other software packages. It 
%                            chooses the number of bins to be 
%                            CEIL(SQRT(NUMEL(X))).
%
%   [N,EDGES,BIN] = HISTCOUNTS(...) also returns an index array BIN, using 
%   any of the previous syntaxes. BIN is an array of the same size as X 
%   whose elements are the bin indices for the corresponding elements in X. 
%   The number of elements in the kth bin is NNZ(BIN==k), which is the same 
%   as N(k). A value of 0 in BIN indicates an element which does not belong 
%   to any of the bins (for example, a NaN value).
%
%   Class support for inputs X, EDGES:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      logical
%
%   See also HISTOGRAM, HISTCOUNTS2, HISTOGRAM2, DISCRETIZE

%   Copyright 1984-2016 The MathWorks, Inc.

import matlab.internal.math.binpicker

nin = nargin;

validateattributes(x,{'numeric','logical'},{'real'}, mfilename, 'x', 1)
edgestransposed = false;

if nin < 3 
    % optimized code path for no name-value pair inputs
    opts = [];
    if nin == 2 && ~isscalar(varargin{1})
        % bin edges code path
        in = varargin{1};
        validateattributes(in,{'numeric','logical'},{'vector','nonempty', ...
            'real', 'nondecreasing'}, mfilename, 'edges', 2)
        if iscolumn(in)
            edges = in.';
            edgestransposed = true;
        else
            edges = in;
        end
    else
        % default 'auto' BinMethod and numbins code path
        if ~isfloat(x)
            % for integers, the edges are doubles
            xc = x(:);
            minx = double(min(xc));
            maxx = double(max(xc));
        else
            xc = x(:);
            minx = min(xc,[],'includenan');
            maxx = max(xc,[],'includenan');
            if ~isempty(x) && ~(isfinite(minx) && isfinite(maxx))
                % exclude Inf and NaN
                xc = x(isfinite(x));
                minx = min(xc);
                maxx = max(xc);
            end
        end
        if nin == 1  % auto bin method
            edges = autorule(xc, minx, maxx, false);
        else   % numbins
            in = varargin{1};
            validateattributes(in,{'numeric','logical'},{'integer', 'positive'}, ...
                mfilename, 'm', 2)
            xrange = maxx - minx;
            numbins = double(in);
            edges = binpicker(minx,maxx,numbins,xrange/numbins);
        end
    end
else
    % parse through inputs including name-value pairs
    opts = parseinput(varargin);
    
    if isempty(opts.BinLimits)  % Bin Limits is not specified
        if ~isempty(opts.BinEdges)
            if iscolumn(opts.BinEdges)
                edges = opts.BinEdges.';
                edgestransposed = true;
            else
                edges = opts.BinEdges;
            end
        else
            if ~isfloat(x)
                % for integers, the edges are doubles
                xc = x(:);
                minx = double(min(xc));
                maxx = double(max(xc));
            else
                xc = x(:);
                minx = min(xc,[],'includenan');
                maxx = max(xc,[],'includenan');
                if ~isempty(x) && ~(isfinite(minx) && isfinite(maxx))
                    % exclude Inf and NaN
                    xc = x(isfinite(x));
                    minx = min(xc);
                    maxx = max(xc);
                end
            end
            if ~isempty(opts.NumBins)
                numbins = double(opts.NumBins);
                xrange = maxx - minx;
                edges = binpicker(minx,maxx,numbins,xrange/numbins);
            elseif ~isempty(opts.BinWidth)
                if ~isfloat(opts.BinWidth)
                    opts.BinWidth = double(opts.BinWidth);
                end
                xrange = maxx - minx;
                if ~isempty(minx)
                    binWidth = opts.BinWidth;
                    leftEdge = binWidth*floor(minx/binWidth);
                    nbins = max(1,ceil((maxx-leftEdge) ./ binWidth));
                    % Do not create more than maximum bins.
                    MaximumBins = getmaxnumbins();
                    if nbins > MaximumBins  % maximum exceeded, recompute
                        % Try setting bin width to xrange/(MaximumBins-1).
                        % In cases where minx is exactly a multiple of 
                        % xrange/MaximumBins, then we can set bin width to
                        % xrange/MaximumBins-1 instead.
                        nbins = MaximumBins;
                        binWidth = xrange/(MaximumBins-1);
                        leftEdge = binWidth*floor(minx/binWidth);
                       
                        if maxx <= leftEdge + (nbins-1) * binWidth
                            binWidth = xrange/MaximumBins;
                            leftEdge = minx;
                        end
                    end    
                    edges = leftEdge + (0:nbins) .* binWidth; % get exact multiples        
                else
                    edges = cast([0 opts.BinWidth], 'like', xrange);
                end
            else    % BinMethod specified
                if strcmp(opts.BinMethod, 'auto')
                    edges = autorule(xc, minx, maxx, false);
                else
                    switch opts.BinMethod
                        case 'scott'
                            edges = scottsrule(xc,minx,maxx,false);
                        case 'fd'
                            edges = fdrule(xc,minx,maxx,false);
                        case 'integers'
                            edges = integerrule(xc,minx,maxx,false,getmaxnumbins());
                        case 'sqrt'
                            edges = sqrtrule(xc,minx,maxx,false);
                        case 'sturges'
                            edges = sturgesrule(xc,minx,maxx,false);    
                    end
                end
            end
        end
        
    else   % BinLimits specified
        if ~isfloat(opts.BinLimits)
            % for integers, the edges are doubles
            minx = double(opts.BinLimits(1));
            maxx = double(opts.BinLimits(2));
        else
            minx = opts.BinLimits(1);
            maxx = opts.BinLimits(2);
        end
        if ~isempty(opts.NumBins)
            numbins = double(opts.NumBins);
            edges = [minx + (0:numbins-1).*((maxx-minx)/numbins), maxx];
        elseif ~isempty(opts.BinWidth)
            if ~isfloat(opts.BinWidth)
                opts.BinWidth = double(opts.BinWidth);
            end
            % Do not create more than maximum bins.
            MaximumBins = getmaxnumbins();
            binWidth = max(opts.BinWidth, (maxx-minx)/MaximumBins);
            edges = minx:binWidth:maxx;
            if edges(end) < maxx || isscalar(edges)
                edges = [edges maxx];
            end
            
        else    % BinMethod specified
            xc = x(x>=minx & x<=maxx);
            if strcmp(opts.BinMethod, 'auto')
                edges = autorule(xc, minx, maxx, true);
            else
                switch opts.BinMethod
                    case 'scott'
                        edges = scottsrule(xc,minx,maxx,true);
                    case 'fd'
                        edges = fdrule(xc,minx,maxx,true);
                    case 'integers'
                        edges = integerrule(xc,minx,maxx,true,getmaxnumbins());
                    case 'sqrt'
                        edges = sqrtrule(xc,minx,maxx,true);
                    case 'sturges'
                        edges = sturgesrule(xc,minx,maxx,true);
                end
            end
        end
    end
end

edges = full(edges); % make sure edges are non-sparse
if nargout <= 2
    n = histcountsmex(x,edges);
else
    [n,bin] = histcountsmex(x,edges);
end

if ~isempty(opts)
    switch opts.Normalization
        case 'countdensity'
            n = n./double(diff(edges));
        case 'cumcount'
            n = cumsum(n);
        case 'probability'
            n = n / numel(x);
        case 'pdf'
            n = n/numel(x)./double(diff(edges));
        case 'cdf'
            n = cumsum(n / numel(x));
    end
end

if nargin > 1 && edgestransposed
    % make sure the returned bin edges have the same shape as inputs
    edges = edges.';   
end
end

function opts = parseinput(input)

opts = struct('NumBins',[],'BinEdges',[],'BinLimits',[],...
    'BinWidth',[],'Normalization','count','BinMethod','auto');
funcname = mfilename;

% Parse second input in the function call
if ~isempty(input)
    in = input{1};
    inputoffset = 0;
    if isnumeric(in) || islogical(in)
        if isscalar(in)
            validateattributes(in,{'numeric','logical'},{'integer', 'positive'}, ...
                funcname, 'm', inputoffset+2)
            opts.NumBins = in;   
            opts.BinMethod = [];
        else
            validateattributes(in,{'numeric','logical'},{'vector','nonempty', ...
                'real', 'nondecreasing'}, funcname, 'edges', inputoffset+2)
            opts.BinEdges = in;
            opts.BinMethod = [];
        end
        input(1) = [];
        inputoffset = 1;
    end
    
    % All the rest are name-value pairs
    inputlen = length(input);
    if rem(inputlen,2) ~= 0
        error(message('MATLAB:histcounts:ArgNameValueMismatch'))
    end
    
    for i = 1:2:inputlen
        name = validatestring(input{i}, {'NumBins', 'BinEdges', 'BinWidth', 'BinLimits', ...
            'Normalization', 'BinMethod'}, i+1+inputoffset);
        
        value = input{i+1};
        switch name
            case 'NumBins'
                validateattributes(value,{'numeric','logical'},{'scalar', 'integer', ...
                    'positive'}, funcname, 'NumBins', i+2+inputoffset)
                opts.NumBins = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.BinWidth = [];
            case 'BinEdges'
                validateattributes(value,{'numeric','logical'},{'vector', ...
                    'real', 'nondecreasing'}, funcname, 'BinEdges', i+2+inputoffset);
                if length(value) < 2
                    error(message('MATLAB:histcounts:EmptyOrScalarBinEdges'));
                end
                opts.BinEdges = value;
                opts.BinMethod = [];
                opts.NumBins = [];
                opts.BinWidth = [];
                opts.BinLimits = [];
            case 'BinWidth'
                validateattributes(value, {'numeric','logical'}, {'scalar', 'real', ...
                    'positive', 'finite'}, funcname, 'BinWidth', i+2+inputoffset);
                opts.BinWidth = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.NumBins = [];
            case 'BinLimits'
                validateattributes(value, {'numeric','logical'}, {'numel', 2, 'vector', 'real', ...
                    'nondecreasing', 'finite'}, funcname, 'BinLimits', i+2+inputoffset)
                opts.BinLimits = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
            case 'Normalization'
                opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                    'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+2+inputoffset);
            otherwise % 'BinMethod'
                opts.BinMethod = validatestring(value, {'auto','scott', 'fd', ...
                    'integers', 'sturges', 'sqrt'}, funcname, 'BinMethod', i+2+inputoffset);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinWidth = [];
                opts.NumBins = [];
        end
    end
end  
end

function mb = getmaxnumbins
mb = 65536;  %2^16
end

function edges = autorule(x, minx, maxx, hardlimits)
xrange = maxx - minx;
if ~isempty(x) && (isinteger(x) || islogical(x) || isequal(round(x),x))...
        && xrange <= 50 && maxx <= flintmax(class(maxx))/2 ...
        && minx >= -flintmax(class(minx))/2
    edges = integerrule(x,minx,maxx,hardlimits,getmaxnumbins());
else
    edges = scottsrule(x,minx,maxx,hardlimits);
end
end

function edges = scottsrule(x, minx, maxx, hardlimits)
% Scott's normal reference rule
if ~isfloat(x)
    x = double(x);
end
binwidth = 3.5*std(x)/(numel(x)^(1/3));
if ~hardlimits
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
else
    edges = matlab.internal.math.binpickerbl(min(x(:)),max(x(:)),minx,maxx,binwidth);
end
end

function edges = fdrule(x, minx, maxx, hardlimits)
n = numel(x);
xrange = max(x(:)) - min(x(:));
if n > 1
    % Guard against too small an IQR.  This may be because there
    % are some extreme outliers.
    iq = max(datafuniqr(x(:)),double(xrange)/10);
    binwidth = 2 * iq * n^(-1/3);
else
    binwidth = 1;
end
if ~hardlimits
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
else
    edges = matlab.internal.math.binpickerbl(min(x(:)),max(x(:)),minx,maxx,binwidth);
end
end

function edges = sturgesrule(x, minx, maxx, hardlimits)
nbins = max(ceil(log2(numel(x))+1),1);
if ~hardlimits
    binwidth = (maxx-minx)/nbins;
    if isfinite(binwidth)
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);    
    else
        edges = matlab.internal.math.binpicker(minx,maxx,nbins,binwidth);
    end
else
    edges = linspace(minx,maxx,nbins+1);
end
end

function edges = sqrtrule(x, minx, maxx, hardlimits)
nbins = max(ceil(sqrt(numel(x))),1);
if ~hardlimits
    binwidth = (maxx-minx)/nbins;
    if isfinite(binwidth)
    edges = matlab.internal.math.binpicker(minx,maxx,[],binwidth);
    else
        edges = matlab.internal.math.binpicker(minx,maxx,nbins,binwidth);
    end
else
    edges = linspace(minx,maxx,nbins+1);
end
end
