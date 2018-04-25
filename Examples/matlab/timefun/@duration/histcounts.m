function [n,edges,bin] = histcounts(x, varargin)
%HISTCOUNTS  Histogram Bin Counts of duration.
%   [N,EDGES] = HISTCOUNTS(X) partitions the values in duration array X  
%   into bins, and returns the count in each bin, as well as the bin edges. 
%   HISTCOUNTS uses an automatic binning algorithm that returns bins with a 
%   uniform width, chosen to cover the range of elements in X and reveal 
%   the underlying shape of the distribution. X can be a vector, matrix, or 
%   multidimensional array. If X is not a vector, then HISTCOUNTS treats it 
%   as a single column vector, X(:).
%
%   N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1). The 
%   last bin will also include the right edge such that N(end) will count
%   X(i) if EDGES(end-1) <= X(i) <= EDGES(end).
%
%   [N,EDGES] = HISTCOUNTS(X,M), where M is a scalar, uses M bins.
%
%   [N,EDGES] = HISTCOUNTS(X,EDGES), where EDGES is a duration vector in 
%   sorted order, specifies the edges of the bins.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinWidth',BW) uses bins of width BW, which is 
%   a scalar duration. To prevent from accidentally creating too many bins, 
%   a maximum of 65536 bins can be created when specifying 'BinWidth'. 
%   If BW is too small such that more bins are needed, HISTCOUNTS uses a 
%   larger bin width corresponding to the maximum number of bins.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinLimits',[BMIN,BMAX]) bins only elements 
%   in X between BMIN and BMAX inclusive, X(X>=BMIN & X<=BMAX).
%
%   [N,EDGES] = HISTCOUNTS(...,'Normalization',NM) specifies the
%   normalization scheme of the histogram values returned in N. NM can be:
%                  'count'   Each N value is the number of observations in 
%                            each bin. SUM(N) is generally equal to NUMEL(X),
%                            but is less than if some of the input data 
%                            is not included in the bins.
%                            This is the default.
%            'probability'   Each N value is the relative number of 
%                            observations (number of observations in bin / 
%                            total number of observations), and SUM(N) is  
%                            less than or equal to 1. 
%               'cumcount'   Each N value is the cumulative number of 
%                            observations in each bin and all previous bins. 
%                            N(end) is less than or equal to NUMEL(X).
%                    'cdf'   Cumulative density function estimate. Each N 
%                            value is the cumulative relative number of 
%                            observations in each bin and all previous bins. 
%                            N(end) is less than or equal to 1.
%
%   [N,EDGES] = HISTCOUNTS(...,'BinMethod',BM), uses the specified automatic 
%   binning algorithm to determine the number and width of the bins. BM can
%   be the following time units: 'second', 'minute', 'hour', 'day', 'year', 
%   which places bin edges at boundaries of the time unit. BM can also be:
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
%                'sturges'   Sturges' rule is a simple rule that is popular
%                            due to its simplicity. It chooses the number of
%                            bins to be CEIL(1 + LOG2(NUMEL(X))).
%                   'sqrt'   The Square Root rule is another simple rule 
%                            widely used in other software packages. It 
%                            chooses the number of bins to be 
%                            CEIL(SQRT(NUMEL(X))).
%   To prevent from accidentally creating too many bins, a maximum of 65536 
%   bins can be created when specifying 'BinMethod'. If the data range is 
%   too large and more bins are needed, HISTCOUNTS uses a larger bin width 
%   corresponding to the maximum number of bins.
%
%   [N,EDGES,BIN] = HISTCOUNTS(...) also returns an index array BIN, using 
%   any of the previous syntaxes. BIN is an array of the same size as X 
%   whose elements are the bin indices for the corresponding elements in X. 
%   The number of elements in the kth bin is NNZ(BIN==k), which is the same 
%   as N(k). A value of 0 in BIN indicates an element which does not belong 
%   to any of the bins (for example, a NaN value).
%
%   See also HISTOGRAM, DURATION/DISCRETIZE

%   Copyright 2016-2017 The MathWorks, Inc.

nin = nargin;

if ~isduration(x)
    error(message('MATLAB:duration:histcounts:NonDurationInput'))
end
edgestransposed = false;
maxnbins = 65536;  %2^16
if nin < 3 
    % optimized code path for no name-value pair inputs
    opts = [];
    if nin == 2 && ~isscalar(varargin{1})
        % bin edges code path
        in = varargin{1};  
        if isduration(in)
            if ~(isvector(in) && length(in)>=2) 
                error(message('MATLAB:duration:histcounts:InvalidEdges'))
            elseif ~issorted(in) || any(isnan(in))
                error(message('MATLAB:duration:histcounts:UnsortedEdges'))
            end
            if iscolumn(in)
                edges = in.';
                edgestransposed = true;
            else
                edges = in;
            end
            [xdata,edgesdata] = duration.compareUtil(x,edges);
        else
            error(message('MATLAB:duration:histcounts:NonDurationEdges'))
        end
    else
        % default 'auto' BinMethod and numbins code path
        xc = x;
        xc.millis = xc.millis(:);
        minx = min(xc,[],'includenan');
        maxx = max(xc,[],'includenan');
        if ~isempty(x) && ~(isfinite(minx) && isfinite(maxx))
            % exclude Inf and NaN
            xc.millis = x.millis(isfinite(x));
            minx = min(xc);
            maxx = max(xc);
        end
        if isempty(xc) % check for empty data
            minx = seconds(0);  % just use 0 as reference
            maxx = minx;
        end

        if nin == 1  % auto bin method
            edges = autorule(xc, minx, maxx, false);
        else   % numbins
            numbins = varargin{1};
            validateattributes(numbins,{'numeric','logical'},{'integer', 'positive'}, ...
                mfilename, 'm', 2)
            edges = generateBinEdgesFromNumBins(numbins,minx,maxx,false);
        end
        xdata = x.millis;
        edgesdata = edges.millis;
    end
else
    % parse through inputs including name-value pairs
    opts = parseinput(varargin);
    
    if ~isempty(opts.BinEdges)
        if iscolumn(opts.BinEdges)
            edges = opts.BinEdges.';
            edgestransposed = true;
        else
            edges = opts.BinEdges;
        end
        [xdata,edgesdata] = duration.compareUtil(x,edges);
    else
        if isempty(opts.BinLimits)  % Bin Limits is not specified
            xc = x;
            xc.millis = xc.millis(:);
            minx = min(xc,[],'includenan');
            maxx = max(xc,[],'includenan');
            if ~isempty(x) && ~(isfinite(minx) && isfinite(maxx))
                % exclude Inf and NaN
                xc.millis = x.millis(isfinite(x));
                minx = min(xc);
                maxx = max(xc);
            end
            if isempty(xc) % check for empty data
                minx = seconds(0);  % just use 0 as reference
                maxx = minx;
            end
            hardlimits = false;
        else   % BinLimits specified
            minx = opts.BinLimits;
            minx.millis = minx.millis(1);
            maxx = opts.BinLimits;
            maxx.millis = maxx.millis(2);
            xc = x;
            xc.millis = xc.millis(xc>=minx & xc<=maxx);
            hardlimits = true;
        end
        
        
        if ~isempty(opts.NumBins)
            edges = generateBinEdgesFromNumBins(opts.NumBins,minx,maxx,hardlimits);
        elseif ~isempty(opts.BinWidth)
            edges = generateBinEdgesFromDuration(opts.BinWidth,minx,maxx,hardlimits,maxnbins);
        else    % BinMethod specified
            switch opts.BinMethod
                case 'auto'
                    edges = autorule(xc, minx, maxx, hardlimits);
                case 'scott'
                    edges = scottsrule(xc,minx,maxx,hardlimits);
                case 'fd'
                    edges = fdrule(xc,minx,maxx,hardlimits);
                case 'sqrt'
                    edges = sqrtrule(xc,minx,maxx,hardlimits);
                case 'sturges'
                    edges = sturgesrule(xc,minx,maxx,hardlimits);
                otherwise
                    edges = generateBinEdgesFromBinMethod(opts.BinMethod,...
                        minx,maxx,hardlimits,maxnbins);
            end
        end
        xdata = x.millis;
        edgesdata = edges.millis;
    end
end

if nargout <= 2
    n = durationHistcounts(xdata, edgesdata);
else
    [n,bin] = durationHistcounts(xdata,edgesdata);
end

if ~isempty(opts)
    switch opts.Normalization
        case 'countdensity'
            n = n./double(diff(edges));
        case 'cumcount'
            n = cumsum(n);
        case 'probability'
            n = n / sum(n);
        case 'cdf'
            n = cumsum(n / sum(n));
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
            error(message('MATLAB:duration:histcounts:NonDurationEdges'))
        end
        input(1) = [];
        inputoffset = 1;
    elseif isduration(in)
        if ~(isvector(in) && length(in)>=2)
            error(message('MATLAB:duration:histcounts:InvalidEdges'))
        elseif ~issorted(in) || any(isnan(in))
            error(message('MATLAB:duration:histcounts:UnsortedEdges'))
        end
        opts.BinEdges = in;
        opts.BinMethod = [];
        input(1) = [];
        inputoffset = 1;
    end
    
    % All the rest are name-value pairs
    inputlen = length(input);
    if rem(inputlen,2) ~= 0
        error(message('MATLAB:duration:histcounts:ArgNameValueMismatch'))
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
                    error(message('MATLAB:duration:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.BinWidth = [];
            case 'BinEdges'
                if ~(isduration(value) && isvector(value) && length(value)>=2)
                    error(message('MATLAB:duration:histcounts:InvalidEdges'))
                elseif ~issorted(value) || any(isnan(value))
                    error(message('MATLAB:duration:histcounts:UnsortedEdges'))
                end
                opts.BinEdges = value;
                opts.BinMethod = [];
                opts.NumBins = [];
                opts.BinWidth = [];
                opts.BinLimits = [];
            case 'BinWidth'
                if isduration(value)
                    if ~(isscalar(value) && isfinite(value) && value > 0)
                        error(message('MATLAB:duration:histcounts:InvalidBinWidth'));
                    end
                else
                    error(message('MATLAB:duration:histcounts:InvalidBinWidth'));
                end
    
                opts.BinWidth = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:duration:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.NumBins = [];
            case 'BinLimits'
                if ~(isduration(value) && numel(value)==2 && issorted(value) && ...
                        all(isfinite(value)))
                    error(message('MATLAB:duration:histcounts:InvalidBinLimits'))
                end
                opts.BinLimits = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:duration:histcounts:InvalidMixedBinInputs'))
                end
            case 'Normalization'
                opts.Normalization = validatestring(value, {'count', 'cumcount',...
                    'probability', 'cdf'}, funcname, 'Normalization', i+2+inputoffset);
            otherwise % 'BinMethod'
                opts.BinMethod = validatestring(value, {'second', 'minute', ...
                    'hour', 'day', 'year', 'auto','scott', 'fd', ...
                    'sturges', 'sqrt'}, funcname, 'BinMethod', i+2+inputoffset);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:duration:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinWidth = [];
                opts.NumBins = [];
        end
    end
end  
end

function edges = autorule(x, minx, maxx, hardlimits)
edges = scottsrule(x,minx,maxx,hardlimits);
end

function edges = scottsrule(x, minx, maxx, hardlimits)
% Scott's normal reference rule
binwidth = 3.5*std(x)/(numel(x)^(1/3));

% guard against constant or empty data
if binwidth > 0
    nbins = max(ceil((maxx-minx)/binwidth),1);
else
    nbins = 1;
end
edges = generateBinEdgesFromNumBins(nbins, minx, maxx, hardlimits);
end

function iq = localiqr(x)
n = numel(x);
F = ((1:n)'-.5) / n;
if n > 0
    iq = diff(interp1(F, sort(x), [.25; .75]));
else
    iq = seconds(NaN);
end
end

function edges = fdrule(x, minx, maxx, hardlimits)
n = numel(x);
xcol = reshape(x,[],1);
xrange = max(xcol) - min(xcol);
% guard against constant or empty data
if n > 1 && xrange > 0
    % Guard against too small an IQR.  This may be because there
    % are some extreme outliers.
    iq = max(localiqr(xcol),xrange/10);
    binwidth = 2 * iq * n^(-1/3);
    nbins = max(ceil((maxx-minx)/binwidth),1);
else
    nbins = 1;
end
edges = generateBinEdgesFromNumBins(nbins, minx, maxx, hardlimits);
end

function edges = sturgesrule(x, minx, maxx, hardlimits)
nbins = max(ceil(log2(numel(x))+1),1);
edges = generateBinEdgesFromNumBins(nbins, minx, maxx, hardlimits);
end

function edges = sqrtrule(x, minx, maxx, hardlimits)
nbins = max(ceil(sqrt(numel(x))),1);
edges = generateBinEdgesFromNumBins(nbins, minx, maxx, hardlimits);
end
