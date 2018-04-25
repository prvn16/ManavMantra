function dim = deduceReductionDimension(adap, useSecondDimForScalar)
% Attempt to deduce the reduction dimension from an adaptor as the first
% non-singleton dimension. If not enough information is known or there is
% any chance that the input could be [], the result is empty.

%   Copyright 2016 The MathWorks, Inc.

dim = getDefaultReductionDimIfKnown(adap);
if (nargin >= 2) && useSecondDimForScalar && isKnownScalar(adap)
    dim = 2;
end
end
