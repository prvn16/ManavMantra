function Y = movcommon(X, k, movFcn, varargin)
%MOVCOMMON   Common moving window function helper.

% Copyright 2016 The MathWorks, Inc.

try
    opts = parseMovOpts(movFcn, k, varargin{:});
catch e
    throwAsCaller(e);
end
    

if isempty(opts.dim)
    % Apply the moving window function along the first non-singleton dim
    % This is the same rule as used for the default reduction dimension
    % which *might* be known.
    dim = getDefaultReductionDimIfKnown(X.Adaptor);
else
    dim = opts.dim;
end

if ~isempty(dim)
    % The dim was either explicitly provided or we were able to deduce it
    opts.dim = dim;
    Y = iDoMovFunInDim(movFcn, X, opts, dim);
else
    % Dim not specificied and it wasn't possible to deduce it.
    % Use a ternaryfun to apply the moving window function in the first
    % non-singleton dimension.  The slice-wise branch is used when the tall
    % dimension is 0 or 1, and otherwise use stencilfun to apply the moving
    % window function along the tall dimension.
    Y = ternaryfun(...
        size(X,1) <= 1, ...
        iDoMovBySliceLazy(movFcn, X, opts, size(X)),...
        iDoMovInTallDim(movFcn, X, opts));
end
end

function Y = iDoMovFunInDim(movFcn, X, opts, dim)
if dim == 1
    Y = iDoMovInTallDim(movFcn, X, opts);
else
    Y = iDoMovBySlice(movFcn, X, opts, dim);
end
end

function dim = iGetFirstNonSingletonDim(sizeX)
dim = find(sizeX ~= 1);

if isempty(dim)
    % scalar input
    dim=1;
end

dim = dim(1);
end

function Y = iDoMovBySliceLazy(movFcn, X, opts, sizeX)
dim = clientfun(@iGetFirstNonSingletonDim, sizeX);
Y = iDoMovBySlice(movFcn, X, opts, dim);
end

function Y = iDoMovInTallDim(movFcn, X, opts)
% Always bind dim=1 within stencilFcn as we might be called through ternaryfun.
dim = 1;
stencilFcn = iCreateMovStencilFcn(movFcn, opts, dim);
Y = stencilfun(stencilFcn, opts.window, X);
Y = iSetOutputSize(X, Y, opts, dim);
end

function Y = iDoMovBySlice(movFcn, X, opts, dim)
movFcn = iBindWeightArg(movFcn, opts);
Y = slicefun(@(x, dim) iMovFun(x, movFcn, opts, dim), X, dim);
Y = iSetOutputSize(X, Y, opts, dim);
end

function Y = iSetOutputSize(X, Y, opts, dim)
% The size of Y depends on the endpoint option selected.
if strcmpi(opts.endpoints, 'discard')
    % For discard, size(Y,dim) will be size(X,dim) - (NB + NF)
    Y.Adaptor = reduceSizeInDimBy(X.Adaptor, dim, sum(opts.window));
else
    % For shrink and fill, Y will be the same size as X
    Y.Adaptor = copySizeInformation(Y.Adaptor, X.Adaptor);
end
end

function movStencilFcn = iCreateMovStencilFcn(movFcn, opts, dim)
movFcn = iBindWeightArg(movFcn, opts);

if strcmpi(opts.endpoints, 'discard')
    movStencilFcn = @(~, x) iMovDiscard(x, movFcn, opts, dim);    
else
    % opts.endpoints must be 'shrink', or 'fill' (string or explict value)
    movStencilFcn = @(varargin) iMovEndpoints(varargin{:}, movFcn, opts, dim);
end
end

function movFcn = iBindWeightArg(movFcn, opts)
if ismember(func2str(movFcn), {'movstd', 'movvar'})
    % bind the optional weight argument used by movstd & movvar to
    % normalize the function signatures for the whole mov-family
    movFcn = @(x, w, varargin) movFcn(x, w, opts.weight, varargin{:});
end
end

function y = iMovEndpoints(info, x, movFcn, opts, dim)
if info.IsHead || info.IsTail
    y = movFcn(x, opts.window, dim, opts.nanflag, 'EndPoints', opts.endpoints);
    y = iRemovePaddingSlices(y, info.Padding);
else
    y = iMovDiscard(x, movFcn, opts, dim);
end
end

function y = iMovDiscard(x, movFcn, opts, dim)
y = movFcn(x, opts.window, dim, opts.nanflag, 'EndPoints', 'discard');
end

function y = iMovFun(x, movFcn, opts, dim)
y = movFcn(x, opts.window, dim, opts.nanflag, 'EndPoints', opts.endpoints);
end

function y = iRemovePaddingSlices(y, padding)
import matlab.bigdata.internal.util.indexSlices

y = indexSlices(y, padding(1) + 1 : size(y,1)-padding(2));
end