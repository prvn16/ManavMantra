function y = dec2ufixed(q,y)
%DEC2FIXED Unsigned integer to unsigned fixed-point numeric value conversion
%
%   DEC2UFIXED(Q,U) converts unsigned integer matrix U to unsigned fixed-point
%   numeric value using quantizer Q.  It is assumed that Q.mode = 'ufixed', and
%   no error checking is done.  This is a private function that is used by
%   HEX2NUM and BIN2NUM.
%
%   Example:
%     q = quantizer('ufixed',[4 3]);
%     u = 15;
%     dec2ufixed(q,u)
%   returns 1.875 = 2 - 1/2^3.
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

% Scale by 2^-f
y = pow2(y,-fractionlength(q));
