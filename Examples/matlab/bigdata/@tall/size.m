function varargout = size(obj, dim)
%SIZE Size of a tall array
%   D = SIZE(X)
%   [M,N] = SIZE(X)
%   [M1,M2,M3,...,MN] = SIZE(X)
%   M = SIZE(X,DIM)
%
%   See also TALL/NUMEL, TALL/NDIMS.

%   Copyright 2015-2017 The MathWorks, Inc.

% Simple input parsing. Error if multiple inputs and outputs.
if (nargin>1) && (nargout>1)
    error(message('MATLAB:maxlhs'));
end
% Dimension argument must not be tall and must be a positive integer
if nargin>1
    if istall(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    % Now that we know it isn't tall, call built-in SIZE to do the rest of
    % the error checking.
    [~] = size(1,dim);
end

% We might be able to return ready-gathered data for some cases.
adaptor = obj.Adaptor;
executor = getExecutor(obj);
if ~isnan(adaptor.NDims)
    szVec = adaptor.Size;
    if nargin == 1 && all(~isnan(szVec))
        % Either [a,b,...] = size(x), or sz = size(x)
        [varargout{1:max(1, nargout)}] = iSplitSize(szVec);
        % Convert to talls
        varargout = cellfun( @(data)tall.createGathered(data, executor), varargout, 'UniformOutput', false );
        return
    end
    if nargin == 2
        if dim > adaptor.NDims
            varargout = { tall.createGathered(1, executor) };
            return
        elseif ~isnan(szVec(dim))
            varargout = { tall.createGathered(szVec(dim), executor) };
            return
        end
    end
end

% We couldn't return an immediate result, so setup the deferred calculation
if nargin == 1
    [varargout{1:max(1, nargout)}] = aggregatefun(@size, @iCombineSize, obj);
else
    nargoutchk(0, 1);
    varargout{1} = aggregatefun(iDimSizeFunctor(dim), iDimSizeCombineFunctor(dim), obj);
end

% Set up output adaptors because we know the size of the results.
if numel(varargout) == 1 && nargin == 1
    % Row-vector output. Note we use 'adaptor.NDims' which might be NaN,
    % or it might contain the actual number of dimensions
    varargout{1}.Adaptor = setKnownSize(matlab.bigdata.internal.adaptors.getAdaptorForType('double'), ...
                                        [1 adaptor.NDims]);
else
    % One or more scalar outputs.
    for idx = 1:numel(varargout)
        varargout{idx}.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
    end
end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper for combining all sizes across partitions
function varargout = iCombineSize(varargin)
varargout = cell(1, nargout);
% Differentiate between vector size and multiple size outputs
if nargin==1
    in = varargin{1};
    assert(~isempty(in), "input to CombineSize should never be empty (@size always returns non-empty)");
    out = in(1, :);
    out(1) = sum(in(:, 1));
    varargout{1} = out;
else
    % For multiple out, sum the first and keep first element of the rest
    varargout{1} = sum(varargin{1}, 1);
    for idx = 2:nargout
        in = varargin{idx};
        varargout{idx} = in(1 : min(1, end));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper for splitting a size vector into multiple outputs if nargout>1
function varargout = iSplitSize(szVec)

% Simply return the vector if nargout==1 (i.e. szvec = size(x))
if nargout==1
    varargout = {szVec};
    return
end

% If there are fewer outputs than dimensions, combine all trailing
% dimension. If more, pad with ones.
numSz = numel(szVec);
if nargout<numSz
    szVec(nargout) = prod(szVec(nargout:end));
elseif nargout>numSz
    szVec = [szVec, ones(1, nargout-numel(szVec))];
end
varargout = num2cell(szVec);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function that generates a dimension specific size functor.
function functor = iDimSizeFunctor(dim)
functor = @fcn;
    function out = fcn(in)
        out = size(in, dim);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function functor = iDimSizeCombineFunctor(dim)
% Helper for combining one specific size across partitions
functor = @fcn;
    function out = fcn(in)
        if dim == 1
            out = sum(in);
        else
            out = in(1);
        end
    end
end
