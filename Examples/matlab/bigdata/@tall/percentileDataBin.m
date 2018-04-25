function [prctileDataBin1, locationInPrctileDataBin1, prctileDataBin2, locationInPrctileDataBin2] = ...
    percentileDataBin(tX, percentile1, percentile2)
% percentileDataBin Find data bin containing a percentile
%
% Compute the entry of tX which coincides with the percentile, or compute a
% data bin formed from two consecutive entries of tX (the data bin which
% contains the percentile). Set the percentile input to 50 for median,
% or to 25 and 75 for the first and third quartiles.

% Copyright 2017 The MathWorks, Inc.

% Bin the data to avoid sorting the entire array.
[n, ~, bins] = histcounts(tX);

% We need to take extreme care over +inf, -inf and NaN. We want NaN
% and +inf to be at the end of the bins list and -inf to be at the
% beginning (should already be the case).
toGoAtBeginning = isinf(tX) & (tX < 0);
bins = elementfun( @iReplaceInf, bins, tX, numel(n) + 1 );
% Prepend a bin for -inf, offsetting the bin counts (n)
n = [nnz(toGoAtBeginning), n];
bins = bins + 1;
nCumulative = cumsum(n, 2);

numelX = numel(tX);
if nargin < 3
    % tall/median
    prctileDataBin1 = iPercentile(tX, percentile1, numelX, nCumulative, bins);
else
    % tall/isoutlier 'quartiles'
    [prctileDataBin1, locationInPrctileDataBin1] = iPercentile(tX, percentile1, numelX, nCumulative, bins);
    [prctileDataBin2, locationInPrctileDataBin2] = iPercentile(tX, percentile2, numelX, nCumulative, bins);
end

%--------------------------------------------------------------------------
function [prctileDataBin, locationInPrctileDataBin] = ...
    iPercentile(tX, percentile, numelX, nCumulative, bins)

p = (percentile./100) .* numelX + 0.5;
pf = floor(p);
pc = ceil(p);

% Percentile can be in one bin or the interpolation between values in two
% separate bins.
bin1 = nnz(nCumulative < pf) + 1; % lower bin
bin2 = nnz(nCumulative < pc) + 1; % upper bin

% Reduced set of data where we know the percentile is.
reducedX = filterslices(bins == bin1 | bins == bin2, tX);

% Sort only the reduced set of data.
reducedX = sort(reducedX,1);

% Form the vector 1:size(reducedX,1).
import matlab.bigdata.internal.lazyeval.getAbsoluteSliceIndices
absoluteIndices = tall(getAbsoluteSliceIndices(hGetValueImpl(reducedX)));

% Extract the data bin containing the percentile.
nPrevious = nnz(bins < bin1);
prctileDataBin = filterslices(absoluteIndices == (pc - nPrevious) | ...
    absoluteIndices == (pf - nPrevious), reducedX);

if nargout > 1
    % tall/isoutlier 'quartiles'
    % Location in bin is between [0,1), unless the tall array is empty or
    % scalar, then the location is NaN.
    notNaN = ~(isempty(tX) | isscalar(tX));
    locationInPrctileDataBin = ((p - pf) .* notNaN) ./ notNaN;
end

%--------------------------------------------------------------------------
function bins = iReplaceInf(bins, vals, newIdx)
bins(isnan(vals) | (isinf(vals) & vals > 0)) = newIdx;
