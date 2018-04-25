% Copyright 2016 The MathWorks, Inc.

function f = cubic(x)
% See Keys, "Cubic Convolution Interpolation for Digital Image
% Processing," IEEE Transactions on Acoustics, Speech, and Signal
% Processing, Vol. ASSP-29, No. 6, December 1981, p. 1155.

absx = abs(x);
absx2 = absx.^2;
absx3 = absx.^3;

f = (1.5*absx3 - 2.5*absx2 + 1) .* (absx <= 1) + ...
    (-0.5*absx3 + 2.5*absx2 - 4*absx + 2) .* ...
    ((1 < absx) & (absx <= 2));
end