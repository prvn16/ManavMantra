function resetThresholds(ntx)
% Establish initial overflow and underflow thresholds, based on
% .BAILMagInteractive and .BAFLMagInteractive.
%
% LastUnder and LastOver are the exponents N of the magnitude value 2^N.
% If the initial values 2^N (given by BAILMagInteractive, etc) are not
% powers of 2, meaning N is not an integer, N is rounded up for overflow
% and down for underflow, in order to be conservative.
%
% BAILMagInteractive and BAFLMagInteractive must be integers > 0,
% otherwise a warning is produced.

% Establish underflow and overflow vertical cursor x-coords
%  - Assumed to be positive integer values

%   Copyright 2010-2012 The MathWorks, Inc.

% Rounding up implies the next-higher power-of-2
v = ntx.hBitAllocationDialog.BAILMagInteractive;
if v<=0
    warning(message('fixed:NumericTypeScope:invalidPropertyValueBAILMag'));
    v = 2^3; % 8
end
ntx.LastOver = getBinsForData(ntx, v);

v = ntx.hBitAllocationDialog.BAFLMagInteractive;
if v<=0
    warning(message('fixed:NumericTypeScope:invalidPropertyValueBAFLMag'));
    v = 2^-3; % 1/8
end
% Exponent returned is the upper edge, negate by 1 for LSB cursor.
ntx.LastUnder = getBinsForData(ntx, v) - 1;
