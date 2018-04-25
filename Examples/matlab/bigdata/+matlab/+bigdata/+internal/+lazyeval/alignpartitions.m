function [paRefOut, varargout] = alignpartitions(paRefIn, varargin)
%alignpartitions
% Implementation of the alignpartitions primitive for LazyPartitionedArray.

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.broadcast;
import matlab.bigdata.internal.lazyeval.getPartitionSizes;
refPartitionSizes = broadcast(getPartitionSizes(paRefIn));
wasPartitionIndependent = isPartitionIndependent(paRefIn, varargin{:});

for ii = 1:numel(varargin)
    varargin{ii} = iAlignPartitions(varargin{ii}, paRefIn.PartitionMetadata, refPartitionSizes);
end

[paRefOut, varargout{1:numel(varargin)}] = slicefun(@deal, paRefIn, varargin{:});
% The framework will assume the output is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
if wasPartitionIndependent
    [paRefOut, varargout{:}] = markPartitionIndependent(paRefOut, varargout{:});
end

function paOut = iAlignPartitions(paIn, targetPartitionMetadata, targetPartitionSizes)
% Align partitions for a single tall array.
import matlab.bigdata.internal.broadcast;
import matlab.bigdata.internal.lazyeval.getAbsoluteSliceIndices;

paAbsoluteIndices = getAbsoluteSliceIndices(paIn);
paIndex = elementfun(@iMapToTargetPartitioning, paAbsoluteIndices, targetPartitionSizes);
paOut = repartition(targetPartitionMetadata, paIndex, paIn);

function targetKeys = iMapToTargetPartitioning(index, targetPartitionSizes)
boundaries = 1 + [0; cumsum(targetPartitionSizes)];
targetKeys = discretize(index, boundaries);
