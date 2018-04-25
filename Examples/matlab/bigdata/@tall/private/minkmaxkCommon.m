function [B, I] = minkmaxkCommon(fcn, A, k, varargin)
%minkmaxkCommon Common helper for MINK and MAXK

% Copyright 2017 The MathWorks, Inc.

import matlab.bigdata.internal.adaptors.getAdaptorForType
import matlab.bigdata.internal.broadcast
import matlab.bigdata.internal.util.isGathered

% Non-tall input validation
try
    tall.validateSyntax(fcn, [{A, k} varargin], 'DefaultType', 'double');
catch e
    % Any error should appear from the user-visible function
    throwAsCaller(e)
end

opts = iParseOpts(fcn, A, k, varargin{:});
[dimIsKnown, dimValue] = isGathered(hGetValueImpl(opts.Dim));

TALL_DIM = 1;

if nargout < 2
    if dimIsKnown
        % Single output and dimension is known on the client.
        minkmaxkFcn = iBuildMinkMaxkFcn(opts, dimValue);
        
        if dimValue == TALL_DIM
            B = reducefun(minkmaxkFcn, A);
        else
            B = slicefun(minkmaxkFcn, A);
        end
        B.Adaptor = topkReductionAdaptor(A, opts.K, dimValue);
    else
        % Single output and reduction dimension is not known on the client.
        if k == 0
            B = iK0DefaultReductionEdgeCase(fcn, A, varargin{:});
        else
            minkmaxkFcn = iBuildMinkMaxkFcn(opts);
            B = reduceInDefaultDim(minkmaxkFcn, A);
            B = tall(B);
        end
        
        % B will have the same type as A and unknown size
        B.Adaptor = getAdaptorForType(A.Adaptor.Class);
    end
else
    if dimIsKnown
        % Two-outputs and reduction dimension is known on the client.
        minkmaxkFcn = iBuildMinkMaxkFcn(opts, dimValue);
        
        if dimValue == TALL_DIM
            sliceIds = iGetSliceIndices(A);
            reduceFcn = @(x, ids) iReduceWithIdsInTallDim(x, ids, minkmaxkFcn);
            [B, I] = reducefun(reduceFcn, A, sliceIds);
        else
            [B, I] = slicefun(minkmaxkFcn, A);
        end
        
        B.Adaptor = topkReductionAdaptor(A, opts.K, dimValue);
    else
        % Two-outputs and reduction dimension is not known on the client.
        if k==0
            [B, I] = iK0DefaultReductionEdgeCase(fcn, A, varargin{:});
        else
            lazyDim = opts.Dim;
            opts = rmfield(opts, 'Dim');
            initialFcn = @(varargin) iApplyLazyDim(varargin{:}, opts);
            
            reduceInTallDimFcn = iBuildMinkMaxkFcn(opts, 1);
            reduceFcn = @(x, ids) iReduceWithIdsInTallDim(x, ids, reduceInTallDimFcn);
            
            sliceIds = iGetSliceIndices(A);
            [B, I] = aggregatefun(initialFcn, reduceFcn, A, sliceIds, broadcast(lazyDim));
        end
        
        % B will have the same type as A and unknown size
        B.Adaptor = getAdaptorForType(A.Adaptor.Class);
    end
    
    % Indices are always of type double and have the same size as the
    % first output so make sure the two are linked together.
    I.Adaptor = copySizeInformation(getAdaptorForType('double'), B.Adaptor);
end
end

%--------------------------------------------------------------------------
function opts = iParseOpts(fcn, A, k, varargin)
opts.Fcn = fcn;
opts.K = k;
opts.Dim = findFirstNonSingletonDim(A);
opts.Comparator = []; % Default is 'auto' but leave empty to indicate unset

% Pick out any argument overrides from the already validated inputs
argId = 1;
while argId <= numel(varargin)
    arg = varargin{argId};
    
    if matlab.internal.math.checkInputName(arg, {'ComparisonMethod'})
        % ComparisonMethod N-V pair
        argId = argId + 1;
        opts.Comparator = varargin{argId};
    else
        % Must have supplied the dim
        opts.Dim = tall.createGathered(arg);
    end
    argId = argId + 1;
end
end

%--------------------------------------------------------------------------
function fcn = iBuildMinkMaxkFcn(opts, dimValue)
nvPairs = {};

if ~isempty(opts.Comparator)
    % This option is only valid for numeric or logical inputs and should
    % have been checked using validateSyntax
    nvPairs = {'ComparisonMethod', opts.Comparator};
end

if nargin < 2
    % No dimValue to bind - build function handle for lazy dim
    fcn = @(x, dim) opts.Fcn(x, opts.K, dim, nvPairs{:});
else
    % Bind known dimValue
    fcn = @(x) opts.Fcn(x, opts.K, dimValue, nvPairs{:});
end
end

%--------------------------------------------------------------------------
function [B, I] = iReduceWithIdsInTallDim(A, sliceIds, minkmaxkFcn)
[B, I] = minkmaxkFcn(A);

% Treat input as 2-D and use the local I to pick out the correct global
% slice index for each column of this chunk of data.
[~, numCols] = size(A);

for jj = 1:numCols
    I(:, jj) = sliceIds(I(:, jj), jj);
end
end

%--------------------------------------------------------------------------
function [B, I] = iApplyLazyDim(A, sliceIds, dim, opts)
minkmaxkFcn = iBuildMinkMaxkFcn(opts, dim);

if dim == 1
    [B, I] = iReduceWithIdsInTallDim(A, sliceIds, minkmaxkFcn);
else
    [B, I] = minkmaxkFcn(A);
end
end

%--------------------------------------------------------------------------
function sliceIds = iGetSliceIndices(A)
% Get absolute slice indices with small dimensions matching that of A
sliceIds = slicefun(@iMatchSmallSizes, A, getAbsoluteSliceIndices(A));
end

%--------------------------------------------------------------------------
function sliceIds = iMatchSmallSizes(A, sliceIds)
sizeA = size(A);
sliceIds = repmat(sliceIds, [1 sizeA(2:end)]);
end

function varargout = iK0DefaultReductionEdgeCase(fcn, A, varargin)
% Make mink(A, 0) work when A is a tall row vector with unknown size.
%
% We cannot use the standard aggregatefun approach for applying the default
% reduction rule when K is 0 and A is a row vector. This is necessary as
% the aggregation always applies a reduction in the tall dimension and the
% mink/maxk functions will (correctly) collapse the size in the reduction
% dimension to zero. Instead, use head to get up to two slices of the A
% and then evaluate the K == 0 result in a clientfun.
[varargout{1:nargout}] = clientfun(@(x) fcn(x, 0, varargin{:}), head(A, 2));
end