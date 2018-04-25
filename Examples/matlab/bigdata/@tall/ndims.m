function nd = ndims(t)
%NDIMS Number of dimensions of a tall array
%   N = NDIMS(X)
%
%   See also TALL/NUMEL, TALL/SIZE.

% Copyright 2016 The MathWorks, Inc.

if ~isnan(t.Adaptor.NDims)
    nd = tall.createGathered(t.Adaptor.NDims, getExecutor(t));
else
    % Hm. We want to return only a scalar, we don't really need a reduction here,
    % but there's not really any other way to do this.
    nd = aggregatefun(@ndims, @(x) x(1), t);
    nd.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end
end
