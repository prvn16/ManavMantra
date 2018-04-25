function out = getAbsoluteSliceIndices(in)
%GETABSOLUTESLICEINDICES Helper that calls the underlying getAbsoluteSliceIndices

%   Copyright 2017 The MathWorks, Inc.

out = wrapUnderlyingMethod(@matlab.bigdata.internal.lazyeval.getAbsoluteSliceIndices, {}, in);
% Output is always a double column vector with the same tall size as
% input
ad = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
out.Adaptor = copyTallSize(ad, in.Adaptor);
out.Adaptor = resetSmallSizes(out.Adaptor, 1);
end