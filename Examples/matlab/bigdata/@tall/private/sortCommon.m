function tY = sortCommon(sortFunctionHandle, tX)
%SORTCOMMON Shared sort/sortrows implementation
%
% This algorithm requires at most three passes:
%  1. A pass to estimate the distribution of the data so that it can be
%  partitioned correctly.
%  2. A pass to read the data and distribute it correctly.
%  3. A pass to sort the data after communication.
% If the number of partitions is one, passes 1 and 2 are skipped.
%
% This is shared because tall/sort only supports column vectors, where it
% overlaps with the implementation of sortrows.
%
% This has syntax:
%  tY = sortCommon(sortFunctionHandle, tX)
%
% Where sortFunctionHandle performs a sort of a local chunk of data in
% dimension 1.

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.FunctionHandle;
import matlab.bigdata.internal.io.ExternalSortFunction;
import matlab.bigdata.internal.broadcast;
import matlab.bigdata.internal.PartitionMetadata;

% This algorithm uses partitioned array instead of tall so that the adaptor
% information isn't needed for update till the very end.
paX = hGetValueImpl(tX);

numPartitions = numpartitions(paX);

if numPartitions ~= 1
    % Need to estimate how to distribute the data among workers evenly.
    paNewPartitionBoundaries = iEstimateQuantiles(paX, sortFunctionHandle, numPartitions - 1);
    paNewPartitionBoundaries = broadcast(paNewPartitionBoundaries);
    
    fh = @(varargin) iDiscretize(sortFunctionHandle, varargin{:});
    paRedistributeKeys = slicefun(fh, paX, paNewPartitionBoundaries);
    paX = repartition(PartitionMetadata(numPartitions), paRedistributeKeys, paX);
end

paX = partitionfun(FunctionHandle(ExternalSortFunction(sortFunctionHandle)), paX);

tY = tall(paX, tX.Adaptor);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
tY = copyPartitionIndependence(tY, tX);

% Discretize an input array based on sortrow criterion and a set of
% boundaries.
function keys = iDiscretize(sortFunctionHandle, x, boundaries)
[~, idx] = feval(sortFunctionHandle, [x; boundaries]);

boundaryIndices = find(idx > size(x, 1));
sortedKeys = discretize((1 : size(x, 1) + size(boundaries, 1))', [-Inf; boundaryIndices; Inf]);
keys = zeros(size(x, 1), 1);
keys(idx, :) = sortedKeys;
keys(end - size(boundaries,1) + 1 : end, :) = [];

% Estimate the N-quantiles of the given partitioned array input.
%
% TODO(g1473256): This is the generic version and a crude algorithm. If we
% can map this to the space of real numbers with a reasonable distance
% metric, we can use algorithms such as t-digest to get a much more
% accurate quantile estimation.
function paBoundaries = iEstimateQuantiles(paX, sortFunctionHandle, numQuantiles)
import matlab.bigdata.internal.util.StatefulFunction;
import matlab.bigdata.internal.FunctionHandle;

% We over-sample the quantiles to improve the accuracy of the estimate.
oversampledNumQuantiles = 3 * numQuantiles + 2;

fh = StatefulFunction(@(quantiles, info, x) iEstimateQuantilesPerPartition(quantiles, info, x, sortFunctionHandle, oversampledNumQuantiles));
paBoundaries = partitionfun(FunctionHandle(fh), paX);
paBoundaries = clientfun(@(x) iLocalQuantiles(x, sortFunctionHandle, numQuantiles), paBoundaries);

% A partitionfun function that estimates the N-quantiles of a partition.
function [quantiles, isFinished, out] = iEstimateQuantilesPerPartition(quantiles, info, x, sortFunctionHandle, numQuantiles)
isFinished = info.IsLastChunk;

if isempty(quantiles)
    quantiles = matlab.bigdata.internal.util.indexSlices(x, []);
end
if ~isempty(x)
    quantiles = [quantiles; iLocalQuantiles(x, sortFunctionHandle, numQuantiles)];
    quantiles = iLocalQuantiles(quantiles, sortFunctionHandle, numQuantiles);
end

if isFinished
    out = quantiles;
    quantiles = [];
else
    out = matlab.bigdata.internal.util.indexSlices(x, []);
end

% Calculate the quantiles for a local array.
function q = iLocalQuantiles(x, sortFunctionHandle, numQuantiles)

x = feval(sortFunctionHandle, x);

tallSize = size(x, 1);
if tallSize == 0
    q = matlab.bigdata.internal.util.indexSlices(x, []);
else
    idx = ceil(tallSize * (1 : numQuantiles) / (numQuantiles + 1));
    q = matlab.bigdata.internal.util.indexSlices(x, idx);
end
