function is = isempty(tv)
%ISEMPTY True for empty array.
%   ISEMPTY(tv) returns 1 if tv is an empty tall array and 0 otherwise. An
%   empty tall array has no elements, that is prod(size(X))==0.

% Copyright 2016 The MathWorks, Inc.

if tv.Adaptor.isSizeKnown()
    is = tall.createGathered(prod(tv.Adaptor.Size) == 0, getExecutor(tv));
else
    is = aggregatefun(@isempty, @all, tv);
    is.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();
end
end
