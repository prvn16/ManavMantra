function out = numel(obj)
%NUMEL Number of elements in a tall array
%   N = NUMEL(A)
%
%   See also TALL/SIZE.

%   Copyright 2015-2016 The MathWorks, Inc.

out = aggregatefun(@numel, @sum, obj);
out.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end
