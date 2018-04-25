function ad = getScalarLogicalAdaptor()
%getScalarLogicalAdaptor return adaptor appropriate for scalar-logical

% Copyright 2016 The MathWorks, Inc.

ad = setKnownSize(...
    matlab.bigdata.internal.adaptors.getAdaptorForType('logical'), ...
    [1 1]);
end