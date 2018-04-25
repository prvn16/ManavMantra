function minKernelElems = getSeparableFilterThreshold(imtype)
%GETSEPARABLEFILTERTHRESHOLD returns threshold for separable filtering.
%   minKernelElems = getSeparableFilterThreshold(imtype) returns the
%   minimum number of kernel elements at which 2-D separable filtering with
%   2 1-D kernels is expected to out-perform 2-D non-separable filtering
%   for an image of type imtype.
%
%   Note that this is only for internal use by imgaussfilt and imfilter.

%   Copyright 2014 The MathWorks Inc.

if strcmp(imtype,'double')
    minKernelElems = 49;
else
    minKernelElems = 289;
end

end