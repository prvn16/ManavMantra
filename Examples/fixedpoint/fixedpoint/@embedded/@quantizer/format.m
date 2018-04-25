function varargout = format(q)
%FORMAT Format of a quantizer object
%   FMT = FORMAT(Q) returns the value of the FORMAT property of
%   quantizer object Q.
%
%   [W,F] = FORMAT(Q) returns the wordlength W and fractionlength F,
%   if Q is a fixed-point quantizer.
%
%   [W,E] = FORMAT(Q) returns the wordlength W and exponentlength E,
%   if Q is a floating-point quantizer.
%
%   If Q is a fixed-point quantizer, then FORMAT(Q) = [W, F] where W is
%   the wordlength in bits, and F is the fractionlength in bits.  For
%   signed fixed-point (MODE(Q)='FIXED'), 53 >= W > F >= 0.  For
%   unsigned fixed point (MODE(Q)='UFIXED'), 53 >= W >= F >= 0.
%
%   If Q is a floating-point quantizer, then FORMAT(Q) = [W, E] where W is
%   the wordlength in bits, and E is the exponentlength in bits.
%   64 >= W > E > 0, and 11 >= E.
%
%   Examples:
%     q = quantizer('single');
%     format(q)
%   returns [32 8].
%
%     q = quantizer([8 7]);
%     format(q)
%   returns [8 7].
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/GET, EMBEDDED.QUANTIZER/SET, 
%            EMBEDDED.QUANTIZER/MODE, EMBEDDED.QUANTIZER/WORDLENGTH,
%            EMBEDDED.QUANTIZER/FRACTIONLENGTH, 
%            EMBEDDED.QUANTIZER/EXPONENTLENGTH

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

error(nargoutchk(0,2,nargout));

fmt = q.format;
if nargout==2
  varargout{1} = fmt(1);
  varargout{2} = fmt(2);
else
  varargout{1} = fmt;
end

