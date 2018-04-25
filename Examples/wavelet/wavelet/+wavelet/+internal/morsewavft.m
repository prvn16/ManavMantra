function [psift,frequencies] = morsewavft(omega,scales,ga,be)
% [psift,frequencies] = morsewavft(omega,scales,ga,be);
% For now we are supporting only the k-th eigenfunction. We may expand
% to higher order eigenfunctions in the future.
% We are also currently not returning the time-domain wavelet from 
% wavelet.internal.morsewavelet
%
% For internal use only, this function may change in a future release

k = 0;

psift = zeros(length(scales),length(omega));

for jj = 1:length(scales)
    psift(jj,:) = wavelet.internal.morsewavelet(scales(jj)*omega,k,ga,be);
    
end

peakradfreq = wavelet.internal.morsepeakfreq(ga,be);
frequencies = (1/(2*pi))*peakradfreq./scales;
