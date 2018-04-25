function domain = chooseFilterDomain3(A, hsize)
%CHOOSEFILTERDOMAIN3 chooses appropriate domain for 3-D filtering
%   domain = chooseFilterDomain3(A, hsize) determines whether filtering
%   image A with 3-D kernel of size hsize is faster in the frequency domain
%   or spatial domain.
%
%   Note that this is only for internal use by gpuArray/imgaussfilt3.

%   Copyright 2014 The MathWorks, Inc.


bigImageThreshold = 2.5e6;          %.5k x .5k x 10
bigKernelThreshold = 4913;           %17 x 17 x 17

imageIsBig = numel(A)>=bigImageThreshold;
kernelIsBig = prod(hsize)>=bigKernelThreshold;

if imageIsBig && kernelIsBig
    domain = 'frequency';
else
    domain = 'spatial';
end

end