function strArr = sizeAsString(obj)
%sizeAsString return string representation of size

% Copyright 2016 The MathWorks, Inc.

arrayInfo = matlab.bigdata.internal.util.getArrayInfo(obj);
strArr = matlab.bigdata.internal.util.getArraySizeAsString(...
    arrayInfo.Ndims, arrayInfo.Size);
end
