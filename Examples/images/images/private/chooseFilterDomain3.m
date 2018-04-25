function domain = chooseFilterDomain3(A, hsize, ippFlag)
%CHOOSEFILTERDOMAIN3 chooses appropriate domain for 3-D filtering
%   domain = chooseFilterDomain3(A, hsize, ippFlag) determines whether
%   filtering image A with 3-D kernel of size hsize is faster in the
%   frequency domain or spatial domain with IPP availability specified by
%   ippFlag.
%
%   Note that this is only for internal use by imgaussfilt3.

%   Copyright 2014 The MathWorks, Inc.

if ippFlag
    domain = 'spatial';
    return;
else
    bigImageThreshold = 2.5e6;          %.5k x .5k x 10
    bigKernelThreshold = 729;           %9 x 9 x 9
end

imageIsBig = numel(A)>=bigImageThreshold;
kernelIsBig = prod(hsize)>=bigKernelThreshold;

if imageIsBig && kernelIsBig
    domain = 'frequency';
else
    domain = 'spatial';
end

end