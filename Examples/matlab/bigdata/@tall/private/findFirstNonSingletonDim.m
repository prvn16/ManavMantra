function lazyDim = findFirstNonSingletonDim(tX)
%findFirstNonSingletonDim - Finds the first non-singleton dimension of tX
%   Returns lazyDim as a tall scalar double

% Copyright 2017 The MathWorks, Inc.

% First check whether the adaptor knows the first non-singleton dim
% (aka the default reduction dim)
dimValue = getDefaultReductionDimIfKnown(tX.Adaptor);

if ~isempty(dimValue)
    % Size must be known so return a gathered tall
    lazyDim = tall.createGathered(dimValue);
    return;
end

% Size not known so use a clientfun for deferred dim
lazyDim = clientfun(@iFindDim, size(tX));
lazyDim.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end

function dim = iFindDim(sz)
dim = find(sz ~= 1, 1, 'first');

if isempty(dim)
    % scalar input
    dim = 1;
end
end