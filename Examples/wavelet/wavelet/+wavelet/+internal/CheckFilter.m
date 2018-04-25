function [out,evenlength,equallen,unitnorm,sumfilters,zeroevenlags] ...
    = CheckFilter(Lo,Hi, varargin)
% This function is for internal use only. It may change or be removed in a
% future release.

% IsOrthogonal() method on dwtfilterbank uses 1e-5 as default tolerance
tol = 1e-5;
if ~isempty(varargin)
    tol = varargin{1};
end

% For a user-supplied scaling and wavelet filter, check that
% both correspond to an orthogonal wavelet
Lo = Lo(:);
Hi = Hi(:);
Lscaling = length(Lo);
Lwavelet = length(Hi);
evenlengthLo = ~(rem(Lscaling,2));
evenlengthHi = ~(rem(Lwavelet,2));
evenlength = all([evenlengthLo evenlengthHi]);

equallen = (Lscaling == Lwavelet);

normLo = norm(Lo,2);
sumLo = sum(Lo);
normHi = norm(Hi,2);
sumHi = sum(Hi);


unitnorm = (abs(normLo - 1) < tol && abs(normHi -1) < tol);
% For orthogonal wavelet sum of scaling filter should be equal to sqrt(2)
% and sum of wavelet filter should be zero
sumfilters = (abs(sumLo - sqrt(2)) < tol && abs(sumHi) < tol) ;

L = Lscaling;
% Initialize zeroevenlags to false. Any valid scaling filter or wavelet
% filter must have at least two elements, but we ensure that this code will
% not error out if an invalid filter is provided.
zeroevenlags = true;
if L > 2
    xcorrHi = conv(Hi,flipud(Hi));
    xcorrLo = conv(Lo,flipud(Lo));
    xcorrLo = xcorrLo(L+2:2:end);
    xcorrHi = xcorrHi(L+2:2:end);
    zeroevenlags = all([~any(abs(xcorrLo)>tol) ~any(abs(xcorrHi)>tol)]);
end
out = all([evenlength equallen unitnorm sumfilters zeroevenlags]);