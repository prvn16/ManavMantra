function ad = getScalarDoubleAdaptor()
%getScalarDoubleAdaptor return adaptor appropriate for scalar-double

% Copyright 2016 The MathWorks, Inc.

ad = setKnownSize(...
    matlab.bigdata.internal.adaptors.getAdaptorForType('double'), ...
    [1 1]);
end
