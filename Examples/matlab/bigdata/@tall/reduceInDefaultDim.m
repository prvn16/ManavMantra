function [result, dim] = reduceInDefaultDim(reduceFcn, tv, varargin)
%reduceInDefaultDim Perform reduction along default dimension
%   [RESULT, DIM] = reduceInDefaultDim(FCN,TV,...) performs the reduction FCN on
%   tall TV in the first non-singleton dimension, returning the final value in
%   RESULT, and the resolved dimension in DIM. RESULT and DIM are
%   PartitionedArrays that the caller must wrap back up into tall arrays.
%
%   FCN will be invoked like so: LOCALRESULT = FCN(CHUNK,DIM,...) where CHUNK
%   is a chunk of the original tall TV, DIM is a dimension (in practice,
%   always 1), and "..." represents the extra arguments from the original call
%   to reduceInDefaultDim.
%
%   FCN can also be a 2-element cell array comprising an aggregation function
%   and a reduction function.

% Copyright 2015-2016 The MathWorks, Inc.

if iscell(reduceFcn)
    [aggregateFcn, reduceFcn] = deal(reduceFcn{:});
else
    [aggregateFcn, reduceFcn] = deal(reduceFcn);
end

% Reducing in the default dimension proceeds as follows:

% Build up the aggregatefun call. The aggregation produces two results - the
% aggregation assuming 1 is the first non-singleton dimension, and the other
% assuming 1 is not the first non-singleton dimension. So, the first output of
% the aggregation will always be reduceFcn(chunkA, 1), and the second output
% will be something like reduceFcn(chunkA, 2). iAggregate ensures that both
% outputs have size 1 in the tall dimension, and consistent sizes in the
% remaining dimensions.
aggregateFcn = @(tA) iAggregate(aggregateFcn, reduceFcn, tA, varargin{:});

% The reduction proceeds by simply reducing in dimension 1 for both aggregated
% results. Note that this will produce a bogus result for the other dimension in
% the case where the tall dimension is not unity - in that case, the correct
% result would have to be obtained by concatenating the partial results in the
% nextNonSingletonDimension, and then performing the reduction in that
% dimension. By omitting this stage, we're relying on the fact that if the tall
% dimension not the first non-singleton dimension, then iAggregate only ever had
% one single slice to reduce.
reduceFcn = @(tR1, tR2) iReduce(reduceFcn, tR1, tR2, varargin{:});
[tR1, tR2] = aggregatefun(aggregateFcn, reduceFcn, tv.ValueImpl);

% We now need to select the correct result using the size information from the
% tall. The clientfun call here can select the correct result.
sz = size(tv);
[result, dim] = clientfun(@iPickWhichOne, sz.ValueImpl, tR1, tR2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A clientfun call to establish which of the results is correct, and return that
% along with the resolved reduction dimension.
function [result, dim] = iPickWhichOne(sz, r1, r2)

nonSingletonDims = find(sz ~= 1);
if isequal(sz, [0 0])
    % Special case (as per g1361570) for [] empty input, MATLAB doesn't
    % apply the first-non-singleton dimension rule. We get the correct
    % result in r2, so we set dim = 3 to force that.
    dim = 3;
elseif isempty(nonSingletonDims)
    % No non-singleton dimensions - scalar case
    dim = 1;
else
    dim = nonSingletonDims(1);
end

% Pick the result depending on the computed full size of the tall variable.
if dim == 1
    result = r1;
else
    result = r2;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simply compute reduceFun(X,1) for each input. As noted above, this doesn't
% guarantee the right result for r2.
function [r1, r2] = iReduce(reduceFcn, r1, r2, varargin)
r1 = reduceFcn(r1, 1, varargin{:});
r2 = reduceFcn(r2, 1, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregation - calculate the reduceFun in the tall dimension, and in the next
% non-singleton dimension. If the tall size of the chunk is >1, then we know for
% sure that the reduced2 output will ultimately be discarded, so we just pick
% the first slice out of the chunk, and let the reduction operate on that. If
% the chunk is empty or tallness 1, then the output reduced2 will be correct.
%
% Both outputs will have size 1 in the first dimension. The other dimensions
% will not match between reduced1 and reduced2, but they will be consistent for
% each call to this function when operating on the same tall variable.
function [reduced1, reduced2] = iAggregate(aggregateFcn, reduceFcn, chunk, varargin)

% obvious first-dimension reduction.
reduced1 = aggregateFcn(chunk, 1, varargin{:});

szChunk = size(chunk);

if szChunk(1) > 1
    % Pick the first slice of 'chunk'
    trailingColons = repmat({':'}, 1, ndims(chunk) - 1);
    chunkForDim2 = chunk(1, trailingColons{:});
else
    % 0 or 1 slices - use the whole chunk.
    chunkForDim2 = chunk;
end

% Calculate next non-singleton dimension
nextNonSingletonDim = find([1, szChunk(2:end)] ~= 1, 1, 'first');
if isempty(nextNonSingletonDim)
    nextNonSingletonDim = 2;
end

% Reduce the chunk slice in the next dimension
reduced2 = aggregateFcn(chunkForDim2, nextNonSingletonDim, varargin{:});

% This can be hit if the input chunk is empty and this reduction converts
% empty chunks to non-empty chunks.
if size(reduced2, 1) ~= size(reduced1, 1)
    reduced1 = reduceFcn(reduced1, 1, varargin{:});
    reduced2 = reduceFcn(reduced2, 1, varargin{:});
end
end
