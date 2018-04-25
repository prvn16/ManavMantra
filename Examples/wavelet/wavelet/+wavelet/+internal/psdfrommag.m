function Pxx = psdfrommag(Sxx,Fs,onesided)
% This function is for internal use only. It may change in a future
% release.
% Pxx = psdfrommag(Sxx,Fs,onesided);
N = numel(Sxx);
if onesided && mod(N,2) == 1
    Norig = 2*N-2;
elseif onesided && mod(N,2)== 0
    Norig = 2*N-1;
else
    Norig = N;
end

DT = 1/Fs;
% Input should be magnitude so abs() is not needed
Pxx = DT/Norig*abs(Sxx).^2;
if onesided
    % Correct for one-sided PSD. Do not scale 0
    % This assumes the Nyquist is present
    Pxx(2:end-1,:) = 2*Pxx(2:end-1,:);
end

