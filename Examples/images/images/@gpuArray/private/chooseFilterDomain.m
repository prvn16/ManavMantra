function domain = chooseFilterDomain(A, hsize)
%CHOOSEFILTERDOMAIN chooses appropriate domain for 2-D filtering
%   domain = chooseFilterDomain(A, hsize) determines whether filtering
%   image A with 2-D kernel of size hsize is faster in the frequency domain
%   or spatial domain.
%
%   Note that this is only for internal use by gpuArray/imgaussfilt.

%   Copyright 2014 The MathWorks, Inc.


bigImageThreshold = 3.24e6;         %1.8k x 1.8k
bigKernelThreshold = 1.6e3;         %40 x 40

Asize = [size(A,1) size(A,2)];
imageIsBig = prod(Asize)>=bigImageThreshold;
kernelIsBig = prod(hsize)>=bigKernelThreshold;

if imageIsBig && kernelIsBig
    domain = 'frequency';
else
    domain = 'spatial';
end

end