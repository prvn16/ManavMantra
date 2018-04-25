function paY = subsrefTallNumeric(paX, paIdx)
% Get x(idx,:,:,..) where idx is a numeric index. Input arguments x and idx
% can be either tall or non-tall.
%
% This assumes paIdx is a column vector and is either numeric or logical.

%   Copyright 2017 The MathWorks, Inc.

% There is a chance that paIdx is actually logical. In such cases where
% this needs to continue working, we bypass the communication parts of the
% calculation. This is done by performing the logical indexing, storing the
% result of that in paLogicalY, then making paIdx empty. If paIdx is in
% fact numeric, paLogicalY is empty and everything continues as normal.
%
% To document the algorithm, each pass below will describe how it acts on a
% given example. This example will be:
%
%   X     Idx
%   A      3 |
%   B      5 | Partition 1
%   C        |
%  ---    ---
%   E      3 |
%   F      1 | Partition 2
%   G        |
%

wasPartitionIndependent = isPartitionIndependent(paX, paIdx);

attemptLogicalBypass = isequal(paX.PartitionMetadata, paIdx.PartitionMetadata);
if attemptLogicalBypass
    [paLogicalY, paIdx] = iAttemptLogicalIndex(paX, paIdx);
else
    paIdx = iAssertNotLogical(paIdx);
end

% Pass 1. Get the partition sizes of X and form necessary pieces of metadata
% about X. This is needed to map requested indices to the right partition of X.
%
% For the example, we know partition sizes to be [3,3]. I.e. indices 1:3
% refer to partition 1 of X and indices 4:6 refer to partition 2 of X.
xPartitionSizes = matlab.bigdata.internal.lazyeval.getPartitionSizes(paX);
xPartitionBoundaries = iBuildPartitionBoundaries(xPartitionSizes);
xNumel = clientfun(@sum, xPartitionSizes);

% Pass 2. Build an optimized array of requested indices from Idx. Then
% repartition to put each requested index alongside the same partition of X
% as where the corresponding slice can be found.
%
% For the example, pass 2 does the following transformations:
%
%  Idx        ReqIdx XPart IdxPart        ReqIdx XPart IdxPart
%   3    Add    3      1      1             3      1      1
%   5 Partition 5      2      1 Repartition 3      1      2
%      Indices                     to X     1      1      2
%  ---   ->    -----------------    ->     ------------------
%   3           3      1      2             5      2      1
%   1           1      1      2
%
[paReqIndices, paXPartIndices, paIdxPartIndices] ...
    = iBuildRequestIndexTuples(paIdx, xPartitionBoundaries, xNumel);
[paReqIndices, paIdxPartIndices] ...
    = repartition(paX.PartitionMetadata, paXPartIndices, ...
    paReqIndices, paIdxPartIndices);

% Pass 3. Map each requested index to its corresponding slice of data. Then
% repartition that information back to the partitioning of Idx.
%
% For the example, pass 3 does the following transformations on the output
% of pass 2:
%
%  ReqIdx IdxPart       ReqIdx IdxPart ReqSlice       ReqIdx IdxPart ReqSlice
%    3       1   Unique   1       2       A             3       1       C
%    3       2     per    3       1       C Repartition 5       1       F
%    1       2  Partition 3       2       C   to Idx
%   ------------   ->    -------------------    ->     -------------------
%    5       1  Then get  5       5       F             1       2       A
%               Slice of                                3       2       C
%               X per row
%
% Note that the output ReqIdx is not in the same order as Idx. This is ok
% as <ReqIdx, ReqSlice> for each partition will used as a random access map.
[paReqIndices, paReqSlices, paIdxPartIndices] = iMapReqIndicesToData(...
    paX, paReqIndices, paIdxPartIndices, xPartitionBoundaries);
[paReqIndices, paReqSlices] ...
    = repartition(paIdx.PartitionMetadata, paIdxPartIndices, ...
    paReqIndices, paReqSlices);

% Pass 4. Build the output Y.
%
% For the example, pass 4 uses the output of pass 3 to map index to output
% slice:
%
%  Idx            Y
%   3             C
%   5  Map index  F
%      to slice
%  ---    ->     ---
%   3             C
%   1             A
%
paY = iBuildOutput(paIdx, paReqIndices, paReqSlices);

% If a logical bypass worked, all of the output will be in paLogicalY
% instead of paY. Here we combine the two.
if attemptLogicalBypass
    paY = iVertcatPartitions(paY, paLogicalY);
end

% The framework will assume out is partition dependent because it is
% derived from partitionfun/generalpartitionfun. It is not, so we must
% correct this.
if wasPartitionIndependent
    paY = markPartitionIndependent(paY);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pass 2 Implementation: Build an optimized array of requested indices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [paReqIndices, paXPartIndices, paIdxPartIndices] ...
    = iBuildRequestIndexTuples(paIdx, xPartitionBoundaries, xNumel)
% Build an optimized array of requested index tuples to retrieve from X.
% Each tuple is of the form:
% <requested index of X, partition of X, destination partition of Idx>

% a. Check validity of the numeric indices.
dim = 1;
paIdx = verifyNumericSubscript(paIdx, dim, xNumel);

% b. Attempt to optimize the number of indices communicated by removing
% the easy to find duplicates. All remaining duplicates will be removed
% during the sort/unique per partition applied by pass 3.
paReqIndices = chunkfun(@unique, paIdx);

% c. Split the indices into partition index and relative index in partition.
% We need the partition index in order to know where to send the request
% for this index.
paXPartIndices = slicefun(@discretize, paReqIndices, xPartitionBoundaries);
paIdxPartIndices = iGetPartitionIndices(paReqIndices);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paPartitionIndices = iGetPartitionIndices(paX)
% Form a column vector of partition indices, each value being the partition
% index to which that slice belongs.
fh = @(info, x) deal(info.IsLastChunk, info.PartitionId * ones(size(x,1),1));
paPartitionIndices = partitionfun(fh, paX);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pass 3 Implementation: Map each requested index to its corresponding slice of data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [paReqIndices, paReqSlices, paIdxPartIndices] ...
    = iMapReqIndicesToData(paX, paReqIndices, paIdxPartIndices, xPartitionSizes)
% Map each requested index to its corresponding slice of data. This also
% outputs the requested indices as this part of the algorithm needs them to
% be in sorted order.

% a. Convert the requested indices map into sorted unique form. This is to
% allow (c) to be done without a random access map.
paReqPairs = slicefun(@(x,y) horzcat(x,y), paReqIndices, paIdxPartIndices);
paReqPairs = iUniqueSortPerPartition(paReqPairs);
[paReqIndices, paIdxPartIndices] = slicefun(@(x) deal(x(:, 1), x(:, 2)), paReqPairs);

% b. Convert the requested indices to be relative to the start of each
% partition.
paReqRelIndices = iBuildRelativeIndices(paReqIndices, xPartitionSizes);

% c. Select the rows of X that are referenced by the request. This will
% duplicate rows that are to be duplicated to two different partitions.
paReqSlices = iMapSortedIndices(paX, paReqRelIndices);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paX = iUniqueSortPerPartition(paX)
% Perform a unique rows operation across each individual partition. This
% supports matrices of doubles.
fh = matlab.bigdata.internal.io.ExternalSortFunction(@sortrows);
fh = matlab.bigdata.internal.FunctionHandle(fh);
paX = partitionfun(fh, paX);

fh = matlab.bigdata.internal.util.StatefulFunction(@iUniquePerPartitionImpl);
fh = matlab.bigdata.internal.FunctionHandle(fh);
paX = partitionfun(fh, paX);
end

function [state, isFinished, x] = iUniquePerPartitionImpl(state, info, x)
% Performs a unique, assuming the data is already in sorted order.
isFinished = info.IsLastChunk;
assert(issorted(x, 'rows'), ...
    'Assertion failed: Found unsorted rows when applying unique to a partition.');
x = unique([state; x], 'rows');
state = [];

if ~isFinished && ~isempty(x)
    state = x(end, :);
    x(end, :) = [];
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paRelIndices = iBuildRelativeIndices(paIndices, partitionBoundaries)
% Build relative indices from absolute indices.
paRelIndices = partitionfun(@iBuildRelativeIndicesImpl, paIndices, partitionBoundaries);
end

function [isFinished, relIndices] = iBuildRelativeIndicesImpl(info, indices, boundaries)
% Implementation of iBuildRelativeIndices.
isFinished = info.IsLastChunk;
relIndices = indices - boundaries(info.PartitionId) + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paY = iMapSortedIndices(paX, paRelIdx)
% Map a column vector of sorted relative indices from the start of each
% partition to the data found at those indices.
paY = generalpartitionfun(@iMapSortedIndicesImpl, paX, paRelIdx);
end

function [isFinished, unusedInputs, y] = iMapSortedIndicesImpl(info, x, relIdx)
% Implementation of iMapSortedIndices.
import matlab.bigdata.internal.util.indexSlices;

unusedInputs = {indexSlices(x, []), zeros(0, 1)};

% Calculate the offset of request indices from the start of this chunk.
relIdxStart = info.RelativeIndexInPartition(1);
offset = relIdx - relIdxStart + 1;

% Put everything we cannot use in this chunk back on unused inputs.
isOffsetPresent = (offset <= size(x, 1));
if all(isOffsetPresent)
    if ~info.IsLastChunk(2)
        % There might still be more request indices to come, put everything
        % immediately after the last seen offset back on unused inputs.
        lastOffset = max(offset, [], 1);
        lastOffset = min(lastOffset, size(x, 1));
        unusedInputs{1} = x;
        unusedInputs{1} (1 : lastOffset, :) = [];
        x(lastOffset + 1 : end, :) = [];
    end
else
    % There are still request indices to be matched to data. Put those back
    % on unused inputs.
    unusedInputs{2} = relIdx(~isOffsetPresent);
    offset(~isOffsetPresent) = [];
end

y = indexSlices(x, offset);
% We're finished only when there are no more request inputs.
isFinished = info.IsLastChunk(2) && isempty(unusedInputs{2});

% We should not be able to trigger this assertion because indices are
% checked in pass 2.
hasRemainingIndices = ~isempty(unusedInputs{2});
isXFinished = info.IsLastChunk(1) && isempty(unusedInputs{1});
assert(~(hasRemainingIndices && isXFinished), ...
    'Assertion failed: Numeric indexing ran out of data before expectation.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pass 4 Implementation: Build the output Y.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tY = iBuildOutput(paIdx, paReqIndices, paReqSlices)
% Build the output Y using the requested slices of X.

fh = @iBuildOutputImpl;
fh = matlab.bigdata.internal.util.StatefulFunction(fh);
fh = matlab.bigdata.internal.FunctionHandle(fh);
tY = generalpartitionfun(fh, paReqIndices, paReqSlices, paIdx);
end

function [obj, isFinished, unusedInputs, y] = iBuildOutputImpl(obj, info, reqIndices, reqSlices, idx)
% Implementation of iBuildOutput.
import matlab.bigdata.internal.util.indexSlices;

if isempty(obj)
    obj.PagedMapBuilder = matlab.bigdata.internal.io.PagedRandomAccessMapBuilder();
    obj.PagedMap = [];
end
if isempty(obj.PagedMap)
    % The PagedMap object exploits the fact that reqIndices was left in
    % a sorted order by pass 3.
    assert(issorted(reqIndices), ...
        'Assertion failed: Found unsorted <reqIndices,reqSlice> pairs.');
    % Until we've retrieved all requested <index, slice> pairs from pass 3,
    % do not start building Y just yet. The paged map must be complete
    % before use because idx can be in any order.
    obj.PagedMapBuilder.add(reqIndices, reqSlices);
    if all(info.IsLastChunk(1 : 2))
        obj.PagedMap = obj.PagedMapBuilder.build();
    else
        isFinished = false;
        unusedInputs = {zeros(0, 1), indexSlices(reqSlices, []), idx};
        y = indexSlices(reqSlices, []);
        return;
    end
end

% Once the paged map is complete, we can build Y.
isFinished = info.IsLastChunk(3);
unusedInputs = [];
y = obj.PagedMap.get(idx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bypass for logical types.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [paLogicalY, paNumericIdx] = iAttemptLogicalIndex(paX, paIdx)
% Attempt logical indexing. If paIdx is logical, this will perform the
% logical indexing. Otherwise it will no-op.
[paLogicalIdx, paNumericIdx] = generalpartitionfun(@iSplitIndexOnType, paIdx, paX);
paLogicalY = filterslices(paLogicalIdx, paX);
end

function [isFinished, unusedInputs, logicalIdx, numericIdx] = iSplitIndexOnType(info, idx, x)
% Direct idx into one of several outputs based on whether idx is logical
% or numeric.
if islogical(idx)
    % As idx is logical, we simply return an empty for the numeric output.
    isFinished = info.IsLastChunk(1);
    logicalIdx = idx;
    numericIdx = zeros(0, 1);
else
    % As idx is numeric, we return an a column vector of false compatible
    % with x. The subsequent filter operation will filter out all of paX,
    % leaving paLogicalY empty.
    isFinished = info.IsLastChunk(2);
    logicalIdx = false(size(x, 1), 1);
    numericIdx = idx;
end
unusedInputs = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function paY = iVertcatPartitions(paY, paLogicalY)
% Fuse two vertically concatenable arrays assuming at least one is empty.
% This is used to fuse the result of logical indexing with numeric
% indexing. We can make this assumption because the index will either be
% logical or numeric, it can't be both.
paY = generalpartitionfun(@iVertcatPartitionsImpl, paY, paLogicalY);
end

function [isFinished, unusedInputs, y] = iVertcatPartitionsImpl(info, y, logicalY)
% Implementation of iVertcatPartitions. At least one of y or logicalY
% should be empty.
assert(isempty(y) || isempty(logicalY), ...
    'Assertion Failed: Both y and logicalY were non-empty.');
isFinished = all(info.IsLastChunk);
unusedInputs = [];
y = [y; logicalY];
end

function paIdx = iAssertNotLogical(paIdx)
% Assert that idx is a numeric index. If it is not, then we can issue an
% incompatibility error because logical indexing would not have worked
% anyway.
paIdx = elementfun(@iAssertNotLogicalImpl, paIdx);
end

function idx = iAssertNotLogicalImpl(idx)
% Implementation of iAssertNotLogical.
if islogical(idx)
    error(message('MATLAB:bigdata:array:IncompatibleTallIndexing'));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function partitionBoundaries = iBuildPartitionBoundaries(partitionSizes)
% Convert partition sizes into a row vector of boundaries for use with
% discretize.
partitionBoundaries = clientfun(@iBuildPartitionBoundariesImpl, partitionSizes);
end

function partitionBoundaries = iBuildPartitionBoundariesImpl(partitionSizes)
% Implementation of iBuildPartitionBoundaries.
partitionBoundaries = cumsum(partitionSizes(:)');
partitionBoundaries = [1, partitionBoundaries(1 : end - 1) + 1, inf];
end
