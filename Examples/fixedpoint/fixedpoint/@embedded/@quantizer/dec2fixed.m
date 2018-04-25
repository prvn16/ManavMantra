function y = dec2fixed(q,y)
%DEC2FIXED Unsigned integer to signed fixed-point numeric value
%
%   DEC2FIXED(Q,U) converts unsigned integer matrix U to a signed fixed-point
%   numeric value using quantizer Q.  This is a private function that is used
%   by HEX2NUM and BIN2NUM.
%
%   Example:
%     q = quantizer('fixed',[4 3]);
%     u = 15;
%     dec2fixed(q,u)
%   returns -0.125 = -1/2^3.
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

% Where the negative numbers start
neg = pow2(wordlength(q)-1);
% Two's complement for negative values
y(y>=neg) = y(y>=neg) - pow2(wordlength(q));
% Scale by 2^-f
y = pow2(y,-fractionlength(q));
