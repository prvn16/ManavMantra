function szDouble = sizeAsDouble(obj)
%sizeAsDouble return double representation of size

% Copyright 2016 The MathWorks, Inc.

arrayInfo = matlab.bigdata.internal.util.getArrayInfo(obj);
if isnan(arrayInfo.Ndims)
    szDouble = nan(1, 2);
else
    szDouble = arrayInfo.Size;
end
end
