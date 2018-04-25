function x = round(q,x)
%ROUND  Round using quantizer, but do not check for overflow
%   ROUND(Q,X) uses the round mode and fraction length of quantizer Q to
%   round the numeric data X, but does not check for overflow.  Compare
%   to QUANTIZER/QUANTIZE.
%
%   This function only works with builtin numeric variables.
%   It does not work with fi objects.  Use the CAST function 
%   to work with fi objects.
%
%   Example:
%     warning on
%     q = quantizer('fixed', 'convergent', 'wrap', [3 2]);
%     x = (-2:eps(q)/4:2)';
%     y = round(q,x);
%     plot(x,[x,y],'.-'); axis square
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/QUANTIZE, CAST.

%   Thomas A. Bryan
%   Copyright 1999-2014 The MathWorks, Inc.

assert(~isfi(x),message('fixed:quantizer:quantize_valueCannotBeFi'));

switch q.mode
 case {'double', 'none'}
  % No operation on 'double' or 'none'
 otherwise
  % Round everything else
  p = pow2(q.fractionlength);
  rmode = q.roundmode;
  % round   == MATLAB's round:    round ties toward max abs.
  % nearest == fixed-point round: round ties toward +inf.
  % fix, floor, ceil == MATLAB's fix, floor, ceil.
  % convergent == round to nearest: round ties to nearest even integer.
  x(:) = feval(rmode,p*double(x))/p;
end
