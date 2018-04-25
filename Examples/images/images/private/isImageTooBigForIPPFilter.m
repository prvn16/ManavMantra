function tooBig = isImageTooBigForIPPFilter(im, outSize)
%ISIMAGETOOBIGFORIPPFILTER queries if image is too big for IPP
%	tooBig = isImageTooBigForIPPFilter(im, outSize) returns true if image
%	im is too large for IPP's filtering routine based on size of filtered
%	image outSize.
%
%	Note that this function is intended for use by internal clients only.

%   Copyright 2014 The MathWorks, Inc.

if (isfloat(im))
    tooBig = any(outSize>32750);
else
    tooBig = any(outSize>65500);
end

end