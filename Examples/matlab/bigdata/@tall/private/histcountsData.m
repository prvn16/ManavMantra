function[counts, edges, bin] = histcountsData(tallX, varargin)
%histcounstsData - histcounts on a tall array

% Copyright 2016 The MathWorks, Inc.

try
    opts = parseinput(varargin);
catch e
    throwAsCaller(e);
end

% Force tallX into a partition ordered column, used to compute summary
% statistics for bin methods that need it.
% Must copy the original adaptor to propagate the underlying class but
% the size (if known) must be reset after reshaping.
tX = chunkfun(@(x) x(:), tallX);
tX.Adaptor = resetSizeInformation(tallX.Adaptor);

% Ouput is always a row vector but the number of columns may not be known
outputNumCols = NaN;

if ~isempty(opts.BinLimits)
    % only count the values that fall within BinLimits
    withinBinLimits = tX>=opts.BinLimits(1) & tX<=opts.BinLimits(2);
    tX = filterslices(withinBinLimits, tX);
end

if ismember(opts.BinMethod, {'auto', 'scott', 'maxnumbins'})
    % We need double values in Scott's rule for edge computation
    xStats = matlab.bigdata.internal.util.getArrayStatistics(elementfun(@iCastToDouble, tX));
else
    xStats = matlab.bigdata.internal.util.getArrayStatistics(tX);
end

if isempty(opts.BinEdges)
    % Compute edges according to inputs
    if ~isempty(opts.NumBins)
        [edgesFcn, edgesFcnArgs] = getNumBinsEdgeFun(opts.NumBins, xStats, opts.BinLimits);
        
        % Number of output columns matches the NumBins input
        outputNumCols = opts.NumBins;
    elseif ~isempty(opts.BinWidth)
        [edgesFcn, edgesFcnArgs] = getBinWidthEdgeFun(opts.BinWidth, xStats, opts.BinLimits);
    else
        % BinMethod code path
        [edgesFcn, edgesFcnArgs] = getBinMethodEdgeFun(tX, opts.BinMethod, xStats, opts.BinLimits, opts.MaxNumBins);
    end
    
    edges = clientfun(edgesFcn, edgesFcnArgs{:});
    edges = clientfun(@compressEdges, edges);
    
else
    % use supplied edge vector which also determines the number of output columns.
    edges = opts.BinEdges;
    outputNumCols = max(size(edges))-1;
    edges = compressEdges(edges);
end

[countIndices, counts] = aggregatefun(@partialHistcounts, @histcountsCombiner, tX, edges);
counts = clientfun(@reshapeHistcountsOutput, countIndices, counts, edges);

counts = normalizeCounts(counts, edges, opts.Normalization);

% Setup the adaptor on the counts result
% 1) The output class is always double
% 2) Size is always a row vector and # of columns should have been set for
%    cases when it is determinable from the input arguments.
import matlab.bigdata.internal.adaptors.getAdaptorForType

counts.Adaptor = setKnownSize(getAdaptorForType('double'), [1 outputNumCols]);

if nargout > 2
    % Compute the bin indices using the possibly compressed edges
    bin = elementfun(@getBinIndices, tallX, matlab.bigdata.internal.broadcast(edges));
    bin = setKnownType(bin, 'double');
end

if nargout > 1
    if isempty(opts.BinEdges)
        % Decompress the edges when they are requested as an output argument
        % but only *after* we've computed the bin indices (if also requested)
        edges = clientfun(@decompressEdges, edges);
        
        
        % Setup the adaptor on the lazily determined bin edges
        % 1) The output class will be double, except for single-prec input
        % 2) Size is always a row vector with an unknown # of columns
        if strcmpi(tallX.Adaptor.Class, 'single')
            edgesAdaptor = getAdaptorForType('single');
        else
            edgesAdaptor = getAdaptorForType('double');
        end
        
        edges.Adaptor = setKnownSize(edgesAdaptor, [1 NaN]);
    else
        % return the supplied local edges, unmodified.
        edges = opts.BinEdges;
    end
end

end

function x = iCastToDouble(x)
if ~isfloat(x)
    x = double(x);
end
end

% Implementation copied from toolbox/matlab/datafun/histcounts.m
function opts = parseinput(input)

opts = struct('NumBins',[], 'MaxNumBins', getmaxnumbins(), 'BinEdges',[],...
    'BinLimits',[],'BinWidth',[],'Normalization','count','BinMethod','auto');

% Must report histcounts in any exception ids that propagate out of here
funcName = 'histcounts';

% Parse second input in the function call
if ~isempty(input)
    in = input{1};
    inputoffset = 0;
    if isnumeric(in) || islogical(in)
        if isscalar(in)
            validateattributes(in,{'numeric','logical'},{'integer', 'positive'}, ...
                funcName, 'm', inputoffset+2)
            opts.NumBins = in;
            opts.BinMethod = '';
        else
            validateattributes(in,{'numeric','logical'},{'vector','nonempty', ...
                'real', 'nondecreasing'}, funcName, 'edges', inputoffset+2)
            opts.BinEdges = in;
            opts.BinMethod = '';
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
        name = validatestring(input{i}, {'NumBins', 'MaxNumBins', 'BinEdges', 'BinWidth', 'BinLimits', ...
            'Normalization', 'BinMethod'}, i+1+inputoffset);
        
        value = input{i+1};
        switch name
            case 'NumBins'
                validateattributes(value,{'numeric','logical'},{'scalar', 'integer', ...
                    'positive'}, funcName, 'NumBins', i+2+inputoffset)
                opts.NumBins = double(value);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = '';
                opts.BinWidth = [];
            case 'MaxNumBins'
                validateattributes(value,{'numeric','logical'},{'scalar', 'integer', ...
                    'positive', '<=', getmaxnumbins}, funcName, 'NumBins', i+2+inputoffset)
                opts.MaxNumBins = double(value);
                opts.BinMethod = 'maxnumbins';
            case 'BinEdges'
                validateattributes(value,{'numeric','logical'},{'vector', ...
                    'real', 'nondecreasing'}, funcName, 'BinEdges', i+2+inputoffset);
                if length(value) < 2
                    error(message('MATLAB:histcounts:EmptyOrScalarBinEdges'));
                end
                opts.BinEdges = value;
                opts.BinMethod = '';
                opts.NumBins = [];
                opts.BinWidth = [];
                opts.BinLimits = [];
            case 'BinWidth'
                validateattributes(value, {'numeric','logical'}, {'scalar', 'real', ...
                    'positive', 'finite'}, funcName, 'BinWidth', i+2+inputoffset);
                opts.BinWidth = double(value);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = '';
                opts.NumBins = [];
            case 'BinLimits'
                validateattributes(value, {'numeric','logical'}, {'numel', 2, 'vector', 'real', ...
                    'nondecreasing', 'finite'}, funcName, 'BinLimits', i+2+inputoffset)
                opts.BinLimits = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                
                if ~isfloat(opts.BinLimits)
                    % for integers, the edges are doubles
                    opts.BinLimits = double(opts.BinLimits);
                end
            case 'Normalization'
                opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                    'probability', 'pdf', 'cdf'}, funcName, 'Normalization', i+2+inputoffset);
            otherwise % 'BinMethod'
                opts.BinMethod = validatestring(value, {'auto','scott', ...
                    'integers', 'sturges', 'sqrt'}, funcName, 'BinMethod', i+2+inputoffset);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinWidth = [];
                opts.NumBins = [];
        end
    end
end
end

% Implementation copied from toolbox/matlab/datafun/histcounts.m
function mb = getmaxnumbins
mb = 65536;  %2^16
end

function [edgesFcn, edgesFcnArgs] = getNumBinsEdgeFun(N, xStats, limits)
edgesFcn = @matlab.bigdata.internal.binmethods.numbinsrule;
edgesFcnArgs = {N, xStats.min, xStats.max, limits};
end

function [edgesFcn, edgesFcnArgs] = getBinWidthEdgeFun(binWidth, xStats, limits)
edgesFcn = @matlab.bigdata.internal.binmethods.binwidthrule;
edgesFcnArgs = {binWidth, xStats.min, xStats.max, limits, getmaxnumbins()};
end

function [edgesFcn, edgesFcnArgs] = getBinMethodEdgeFun(tX, binMethod, xStats, limits, maxNumBins)
import matlab.bigdata.internal.binmethods.autorule
import matlab.bigdata.internal.binmethods.scottsrule
import matlab.bigdata.internal.binmethods.integersrule
import matlab.bigdata.internal.binmethods.sturgesrule
import matlab.bigdata.internal.binmethods.sqrtrule
import matlab.bigdata.internal.binmethods.maxnumbinsrule

switch binMethod   
    case 'auto'
        edgesFcn = @autorule;
        preferIntegerRule = lazyCheckAutoRulePreferIntegersRule(tX);
        edgesFcnArgs = {preferIntegerRule, xStats.min, ...
            xStats.max, xStats.std, xStats.numel, limits, maxNumBins};
    case 'scott'
        edgesFcn = @scottsrule;
        edgesFcnArgs = {xStats.std, xStats.numel, xStats.min, xStats.max, limits};
    case 'integers'
        edgesFcn = @integersrule;
        edgesFcnArgs = {xStats.min, xStats.max, limits, maxNumBins};
    case 'sqrt'
        edgesFcn = @sqrtrule;
        edgesFcnArgs = {xStats.numel, xStats.min, xStats.max, limits};
    case 'sturges'
        edgesFcn = @sturgesrule;
        edgesFcnArgs = {xStats.numel, xStats.min, xStats.max, limits};
    case 'maxnumbins'
        edgesFcn = @maxnumbinsrule;
        preferIntegerRule = lazyCheckAutoRulePreferIntegersRule(tX);
        edgesFcnArgs = {preferIntegerRule, xStats.min, ...
            xStats.max, xStats.std, xStats.numel, limits, maxNumBins};
end
end

function preferIntRule = lazyCheckAutoRulePreferIntegersRule(tX)
% Prefer to use scotts rule when the underlying type is either single or
% double, as opposed to some kind of int or logical, where the integers
% rule should be preferred instead.
% Otherwise, the integer rule is used when the input array is equal to the
% rounded one.

classCheckFcn = @(cX) ~ismember(cX, {'single', 'double'});
hasCorrectClass = clientfun(classCheckFcn, classUnderlying(tX));
roundsToInt = aggregatefun(@(x) isequal(x, round(x)), @all, tX);
preferIntRule = clientfun(@(a,b) (a||b), hasCorrectClass, roundsToInt);
end

function [countIndices, counts] = partialHistcounts(x, edges)
edges = decompressEdges(edges);
counts = histcounts(x, edges)';
countIndices = find(counts ~= 0);
counts = counts(countIndices);
end

function [countIndices, counts] = histcountsCombiner(countIndices, counts)
[countIndices, ~, idx] = unique(countIndices(:));
counts = accumarray(idx, counts(:));
end

function allCounts = reshapeHistcountsOutput(countIndices, counts, edges)
edges = decompressEdges(edges);
numBins = numel(edges)-1;
allCounts = zeros(1, numBins);
allCounts(countIndices) = counts;
end

function edges = compressEdges(edges)
% Check whether edges == colon(min(edges), step, max(edges))
% where step = unique(diff(edges)) and step is a positive scalar
step = unique(diff(edges));

if all(isfinite(edges)) && isscalar(step) && isfinite(step) && step > 0
    % Compress the edges into a cell array of args for colon operator
    % This is done to avoid unnecessarily communicating a large row vector
    edges = {min(edges), step, max(edges)};
end
end

function edges = decompressEdges(edges)
if iscell(edges)
    % reconstruct the edges vector
    edges = colon(edges{:});
end
end

function counts = normalizeCounts(counts, edges, normType)

if strcmpi(normType, 'count')
    % this is the default so nothing to do here.
    return;
end

switch normType
    case 'countdensity'
        normFcn = @(n, e) n./double(diff(decompressEdges(e)));
    case 'cumcount'
        normFcn = @(n, ~) cumsum(n);
    case 'probability'
        normFcn = @(n, ~) n / sum(n);
    case 'pdf'
        normFcn = @(n, e) n/sum(n)./double(diff(decompressEdges(e)));
    case 'cdf'
        normFcn = @(n, ~) cumsum(n / sum(n));
end

% There is an assumption here that counts and edges will fit on client
% numel(edges) <= getmaxnumbins = 2^16 so this seems plausible.
counts = clientfun(normFcn, counts, edges);
end

function bins = getBinIndices(x, edges)
edges = decompressEdges(edges);
bins = discretize(x, edges);
bins(isnan(bins)) = 0;
end

