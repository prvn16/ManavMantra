function varargout = stencilfun(opts, stencilFcn, window, X)
%STENCILFUN Apply a stencil operation to a partitioned array
%
%   Syntax:
%       tY = stencilfun(stencilFcn, [NB NF], tX)
%       tY = stencilfun(opts, stencilFcn, [NB NF], tX)
%
%   Inputs:
%    - stencilFcn is a function handle containing the stencil operation
%    that will be applied to the underlying data with signature as
%    described below.
%
%    - window is a two-element vector of integer values used to encode the
%    stencil extent in the tall dimension. The window is defined as [NB NF]
%    where NB is the number of backwards slices required for the stencil
%    operation.  Similarly, NF is the number of forward slices required for
%    the stencil operation.
%
%    - tX is the partitioned array to apply the stencil operation to.
%
%    - opts (optional) specifies options for running the operation such as
%    RNG state.
%
%   Outputs:
%    - tY is the partitioned array that results from applying the stencil.
%
%   Stencil Function Handle Syntax:
%       out = stencilFcn(info, data)
%
%    - data is provided as a chunk with as many as [NB NF] padding slices
%    applied to the underlying data.  The applied padding will depend on
%    the window extent and the number of slices that were available.
%
%    - info is a struct with the following properties:
%       - Window: a two-element vector containing the requested stencil
%       extent.  This is equivalent to the window argument, [NB NF].
%
%       - Padding: a two-element vector containing the actual data padding
%       that was applied by the framework.  The padding will be reduced
%       near the endpoints of the array and clients where there are not
%       enough slices to satisfy the requested window.
%
%       - IsHead: a scalar-logical that is true when there were
%       insufficient slices above the current chunk to satisfy the
%       requested backwards window as specified by NB.
%
%       - IsTail: a scalar-logical that is true when there were
%       insufficient slices below the current chunk to satisfy the
%       requested forwards window as specified by NF.
%
%    - out is the result of applying the stencil operation to the input
%    data.  This should only include slices where the stencil operation is
%    valid.  Valid slices are defined as follows:
%
%      - Near array end points there are insufficient slices to satisfy the
%      window and the client is responsible for defining how the stencil
%      operation should be modified.  E.g. shrinking, filling, or
%      discarding slices that fall within this region.
%
%      - Within the array the framework supplies the sufficient padding
%      slices to satisfy the requested window.  In this region, the output
%      should not include any slices where there were not enough elements
%      to satisfy the stencil extent.
%

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.bigdata.internal.broadcast
import matlab.bigdata.internal.FunctionHandle
import matlab.bigdata.internal.util.StatefulFunction

if ~isa(opts, 'matlab.bigdata.internal.PartitionedArrayOptions')
    % No options, so shuffle down inputs
    X = window;
    window = stencilFcn;
    stencilFcn = opts;
end

if all(window == 0)
    % [0 0] window indicates that there is no padding to apply
    % so the stencil operation reduces to a slice-wise operation.
    % bind the constant info struct into stencilFcn
    stencilInfo.Window = window;
    stencilInfo.Padding = window;
    stencilInfo.IsHead = false;
    stencilInfo.IsTail = false;
    [varargout{1:nargout}] = slicefun(@(x) stencilFcn(stencilInfo, x), X);
    return;
end

% First pass: Reduce each partition to the first NF and last NB data slices
summaryFcn = @(varargin) iSummarizePartition(varargin{:}, window);
summaryFH = FunctionHandle(StatefulFunction(summaryFcn));
summaryTable = partitionfun(summaryFH, X);
summaryTable.Adaptor = iMakeSummaryTableAdaptor();

% Second pass: Apply the stencil function using the partition boundary
% slices obtained in the first pass.
applyStencilFcn = @(varargin) iApplyStencil(varargin{:}, stencilFcn, window);
applyStencilFH = FunctionHandle(StatefulFunction(applyStencilFcn));
[varargout{1:nargout}] = partitionfun(applyStencilFH, X, broadcast(summaryTable));
% The framework assumes the output of partitionfun is dependent on the
% partitioning. We need to correct this here as the output of stencilfun is
% not.
[varargout{:}] = copyPartitionIndependence(varargout{:}, X);
end

%--------------------------------------------------------------------------
function [state, done, out] = iSummarizePartition(state, info, X, window)
% Summarize each partition: count the number of slices in the tall
% dimension and extract the halo slices.
import matlab.bigdata.internal.util.indexSlices

if isempty(state)
    numDataSlices = 0;
    halo = iMakeHaloTable([], indexSlices(X, []));
else
    % unpack the state cell
    [numDataSlices, halo] = state{:};
end

% Combine this chunk with any previously reduced chunks
h = size(X,1);
numDataSlices = numDataSlices + h;
sliceId = info.RelativeIndexInPartition - 1 + (1:h)';
chunk = iMakeHaloTable(sliceId, X);
halo = [halo; chunk];

% Reduce the data we've seen thus far to the first NF and last NB slices
NB = window(1); 
NF = window(2);
isFirstNF = iFindSlices(halo.SliceIndex, NF, 'first');
isLastNB = iFindSlices(halo.SliceIndex, NB, 'last');
slicesToKeep = unique([isFirstNF; isLastNB]);
halo = indexSlices(halo, slicesToKeep);

done = info.IsLastChunk;

if done
    out = iMakeSummaryTable(info.PartitionId, numDataSlices, {halo});
else
    % Update state and output an empty row
    state = {numDataSlices, halo};
    out = iMakeSummaryTable([], [], {});
end
end

%--------------------------------------------------------------------------
function summaryTable = iMakeSummaryTable(PartitionId, NumDataSlices, Halo)
summaryTable = table(PartitionId, NumDataSlices, Halo);
end

%--------------------------------------------------------------------------
function adaptor = iMakeSummaryTableAdaptor()
% Creates the necessary table adaptor for the internal summary table
import matlab.bigdata.internal.adaptors.getAdaptorForType
import matlab.bigdata.internal.adaptors.TableAdaptor

varNames = {'PartitionId', 'NumDataSlices', 'Halo'};
genericAdaptor = getAdaptorForType('');
varAdaptors = repmat({genericAdaptor}, size(varNames));
adaptor = TableAdaptor(varNames, varAdaptors);
end

%--------------------------------------------------------------------------
function haloTable = iMakeHaloTable(SliceIndex, X)
haloTable = table(SliceIndex, X);
end

%--------------------------------------------------------------------------
function [obj, done, varargout] = iApplyStencil(obj, info, X, summaryTable, stencilFcn, window)
import matlab.bigdata.internal.util.indexSlices

if isempty(obj)
    obj.InputBuffer = indexSlices(X, []);
    [obj.IsHeadPartition, obj.IsTailPartition] = ...
        iGetPartitionInfo(summaryTable, info.PartitionId);
    
    [obj.Head, obj.Tail] = ...
        iExtractPartitionHalo(summaryTable, info.PartitionId, window);
end

done = info.IsLastChunk;
NB = window(1);
NF = window(2);
span = NB + NF;
padding = [size(obj.Head, 1) size(obj.Tail, 1)];

% Combine input with any slices that were previously buffered.
X = [obj.InputBuffer; X];
h = size(X,1);

if ~done && h <= span
    % Need at least enough slices to satisfy an entire window span or we
    % run out of data in this partition.  Add any data onto the buffer and 
    % evaluate an empty body chunk to ensure outputs have correct types.
    obj.InputBuffer = X;
    X = indexSlices(X, []);
    stencilInfo = iGetStencilInfo(info, obj, window, window);
    [varargout{1:nargout-2}] = stencilFcn(stencilInfo, X);
elseif ~done && h > span
    % Body chunk.  Use the last NF slices of data as padding.
    stencilInfo = iGetStencilInfo(info, obj, window, [padding(1) NF]);
    paddedX = [obj.Head; X];
    [varargout{1:nargout-2}] = stencilFcn(stencilInfo, paddedX);
    
    % Buffer slices used as padding this call for the next one.
    obj.Head = indexSlices(X, (h - span + 1 : h - NF));
    obj.InputBuffer = indexSlices(X, (h - NF+1 : h));
else
    % Done! Apply the tail padding supplied by the following partition(s)
    stencilInfo = iGetStencilInfo(info, obj, window, padding);
    paddedX = [obj.Head; X; obj.Tail];
    [varargout{1:nargout-2}] = stencilFcn(stencilInfo, paddedX);
end
end

%--------------------------------------------------------------------------
function [head, tail] = iExtractPartitionHalo(T, partitionId, window)
% Convert halos to use absolute indices and extract partition boundaries
[halos, startId, endId] = iMapToAbsoluteIndices(T, partitionId);

% Head padding: previous NB slices to the start of this partition
NB = window(1);
isHead = iFindSlices(halos.SliceIndex < startId, NB, 'last');
head = halos{isHead, 'X'};

% Tail padding: the NF slices that come after the end of this partition
NF = window(2);
isTail = iFindSlices(halos.SliceIndex > endId, NF, 'first');
tail = halos{isTail, 'X'};
end

%--------------------------------------------------------------------------
function [halos, startId, endId] = iMapToAbsoluteIndices(T, partitionId)
% Update the slice indices stored within the halo table so that the slice
% index column contains the overall partitioned array index.
offset = circshift(T.NumDataSlices, 1);
offset(1) = 0; % first partition has no offset
offset = cumsum(offset);

for ii = 2:numel(offset)
    halo = T{ii, 'Halo'};
    halo{:}.SliceIndex = halo{:}.SliceIndex + offset(ii);
    T{ii, 'Halo'} = halo;
end

halos = vertcat(T.Halo{:});

% Work out the first and last absolute slice index for the given partition
offset = offset(T.PartitionId == partitionId);
startId = offset + 1;
endId = startId + T{T.PartitionId == partitionId, 'NumDataSlices'} - 1;
end

%--------------------------------------------------------------------------
function [isHeadPartition, isTailPartition] = iGetPartitionInfo(T, partitionId)
% Determine whether the current partition is the absolute head or tail
T = T(T.NumDataSlices ~=0, :); % prune empty partitions

if isempty(T)
    isHeadPartition = false;
    isTailPartition = false;
else
    [first, last] = bounds(T.PartitionId);
    isHeadPartition = first == partitionId;
    isTailPartition = last == partitionId;
end
end

%--------------------------------------------------------------------------
function ids = iFindSlices(x, N, opt)
% Simple wrapper around find that allows searching for N == 0 indices
import matlab.bigdata.internal.util.indexSlices

if N > 0
    ids = find(x, N, opt);
else
    % Return empty with the correct shape and type double
    ids = double(indexSlices(x, []));
end
end

%--------------------------------------------------------------------------
function stencilInfo = iGetStencilInfo(info, obj, window, padding)
% Build up the stencil info struct based on the current evaluation state.
isFirstChunk = obj.IsHeadPartition && info.RelativeIndexInPartition(1) == 1;
isLastChunk = obj.IsTailPartition && info.IsLastChunk;
isMissingPadding = padding < window;

stencilInfo = struct(...
    'Window', window, ...
    'Padding', padding, ...
    'IsHead', isFirstChunk || isMissingPadding(1), ...
    'IsTail', isLastChunk || isMissingPadding(2));
end
