function coi = morseroi(N,tb,Fs)
% This function is for internal use only, it may change or be removed in a
% future release.
ga = 3;
be = tb/3;
FourierFactor = (2*pi)/wavelet.internal.morsepeakfreq(ga,be);
[~,~,~,sigmaPsi,~] = wavelet.internal.morseproperties(ga,be);
coi = FourierFactor/sigmaPsi;