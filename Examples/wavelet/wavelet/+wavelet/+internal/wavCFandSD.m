function [FourierFactor,sigmaT, cf] = wavCFandSD(wname,ga,be)
%   This function is for internal use only. It may change or be removed
%   in a future release.

% cf is wavelet center frequency in radians / second, sigmaT is the pulse
% width in seconds.
switch lower(wname(1))
    case 'm'
        % Morse
        cf = wavelet.internal.morsepeakfreq(ga,be);
        [~,~,~,sigmaT,~] = ...
            wavelet.internal.morseproperties(ga,be);

    case 'a'
        % amor / Analytic Morlet
        cf = 6;
        sigmaT = sqrt(2);

    case 'b'
        % bump
        cf = 5;
        sigmaT = 5.847705;

end
% Convert scale from center frequency reference to sampling frequency ref.
FourierFactor = (2*pi)/cf;
