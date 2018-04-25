function [M,P] = gaborFilterFFT(A,GaborBank,displayWaitBar)
%APPLYGABORFILTERFFT applies FFT to a Gabor Filter bank
%	[M,P] = applyGaborFilterFFT(A,GaborBank,displayWaitBar) computes the
%   magnitude and phase response of a Gabor filter with an input greyscale
%   image A.
%
%	This function is intended for use by internal use only.

%   Copyright 2016 The MathWorks, Inc.

if(displayWaitBar)
    waitBar = waitBarFactory(numel(GaborBank));
    refreshWaitbar(waitBar);
    % In case of Ctrl+C with graphical waitbar.
    cleanup_waitbar = onCleanup(@() destroy(waitBar));
end

outSize = size(A);

% Work in double precision floating point unless a is passed in as single.
if ~isa(A,'single')
    A = double(A);
end

sizeLargestKernel = findMaximumKernelSize(GaborBank);
% Gabor always returns odd length kernels
padSize = (sizeLargestKernel-1)/2;
A = padarray(A,padSize,'replicate');
sizeAPadded = size(A);

A = fft2(A);
out = zeros([outSize,length(GaborBank)],'like',A);

for p = 1:length(GaborBank)
    H = makeFrequencyDomainTransferFunction(GaborBank(p),sizeAPadded,class(A));
    outPadded = ifft2(A .* ifftshift(H));
    out(:,:,p) = unpadSlice(outPadded,padSize,outSize);
    if(displayWaitBar)
        update(waitBar,p)
        if waitBar.isCancelled
            M = [];
            P = [];
            return
        end
    end
end

M = abs(out);
P = angle(out);

end

function outTrimmed = unpadSlice(out,padSize,outSize)

start = padSize+1;
stop = start+outSize-1;

outTrimmed = out(start(1):stop(1),start(2):stop(2));

end


function sizeH = findMaximumKernelSize(GaborBank)

sizeH = [0 0];
for p = 1:length(GaborBank)
    thisKernelSize = GaborBank(p).KernelSize;
    % Kernels are always square, gabor enforces this.
    if  thisKernelSize(1) > sizeH(1)
         sizeH = thisKernelSize;
     end
end

end

function waitBar = waitBarFactory(numIterations)

    dlgName = getString(message('images:imgaborfilt:waitDlgName'));
    if images.internal.isFigureAvailable()
        
        waitBar = iptui.cancellableWaitbar(dlgName,...
            getString(message('images:imgaborfilt:statusFormatter','%d')),numIterations,0);
        
    else
                
        waitBar = iptui.textWaitUpdater(dlgName,...
            getString(message('images:imgaborfilt:statusFormatter','%d')),numIterations);
        
    end

end