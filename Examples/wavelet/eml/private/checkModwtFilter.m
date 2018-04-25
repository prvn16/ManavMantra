function out = checkModwtFilter(Lo,Hi)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% For a user-supplied scaling and wavelet filter, check that
% both correspond to an orthogonal wavelet
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
Lscaling = coder.internal.indexInt(length(Lo));
Lwavelet = coder.internal.indexInt(length(Hi));
evenlengthLo = eml_bitand(Lscaling,ONE) == ZERO;
evenlengthHi = eml_bitand(Lwavelet,ONE) == ZERO;
evenlength = evenlengthLo && evenlengthHi;
equallen = Lscaling == Lwavelet;
if ~(evenlength && equallen)
    out = false;
    return
end
normLo = norm(Lo,2);
normHi = norm(Hi,2);
tol = 1e-7;
unitnorm = ~(abs(normLo - 1) > tol && abs(normHi - 1) > tol);
if ~unitnorm
    out = false;
    return
end
sumLo = sum(Lo);
sumHi = sum(Hi);
sumfilters = ~(abs(sumLo - sqrt(2)) > tol && abs(sumHi) > tol);
if ~sumfilters
    out = false;
    return
end
if Lscaling > 2
    xcorrHi = conv(Hi,flip(Hi));
    xcorrLo = conv(Lo,flip(Lo));
    i1 = Lscaling + 2;
    i2 = length(xcorrLo);
    zeroevenlagsLo = true;
    zeroevenlagsHi = true;
    for k = i1:2:i2
        zeroevenlagsLo = zeroevenlagsLo && ~(abs(xcorrLo(k) > tol));
        zeroevenlagsHi = zeroevenlagsHi && ~(abs(xcorrHi(k) > tol));
    end
    out = zeroevenlagsLo || zeroevenlagsHi;
else
    out = true;
end
