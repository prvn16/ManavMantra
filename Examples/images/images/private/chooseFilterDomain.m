function domain = chooseFilterDomain(A, hsize, ippFlag)
%CHOOSEFILTERDOMAIN chooses appropriate domain for 2-D filtering
%   domain = chooseFilterDomain(A, hsize, ippFlag) determines whether
%   filtering image A with 2-D kernel of size hsize is faster in the
%   frequency domain or spatial domain with IPP availability specified by
%   ippFlag.
%
%   Note that this is only for internal use by imgaussfilt.

%   Copyright 2014 The MathWorks, Inc.

if ippFlag
    bigImageThreshold = 2.25e6;         %1.5k x 1.5k
    if isa(A,'single')
        bigKernelThreshold = 1.44e4;    %120 x 120
    else
        bigKernelThreshold = 4e4;       %200 x 200    
    end
else
    bigImageThreshold = 1e6;            %1k x 1k
    bigKernelThreshold = 1.6e3;         %40 x 40
end

Asize = [size(A,1) size(A,2)];
imageIsBig = prod(Asize)>=bigImageThreshold;
kernelIsBig = prod(hsize)>=bigKernelThreshold;

if imageIsBig && kernelIsBig
    domain = 'frequency';
else
    domain = 'spatial';
end

end