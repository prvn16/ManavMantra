function out = getAdaptorFromPreview(localValue)
%getAdaptorFromPreview Get appropriate adaptor from a loval preview value.
%   A = getAdaptorFromPReview(X) returns an adaptor appropriate to the
%   local value X, but with the tall size left unknown.
%
%   A = getAdaptor(T) for tall T returns T's Adaptor.

%   Copyright 2017 The MathWorks, Inc.

out = matlab.bigdata.internal.adaptors.getAdaptor(localValue);

% Reset the tall size since we can't know its exact value. However, we can
% tell if it's non-empty or has >1 row (which is useful information for
% determining first non-singleton dimension, etc.).
out = resetTallSize(out);
if size(localValue, 1) > 1
    % We know that there is more than 1 row in the data set, so update the
    % adaptor accordingly.
    out.setTallSizeGtOneInPlace();
end