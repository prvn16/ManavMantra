function r = cordicabs(c, varargin)
%CORDICABS  CORDIC-based absolute value.
%   CORDICABS(C, ...) returns the magnitude of the complex elements of C.
%
%   SYNTAX:
%     R = CORDICABS(C);
%     R = CORDICABS(C, NITERS);
%     R = CORDICABS(C, NITERS, 'ScaleOutput', B);
%     R = CORDICABS(C, 'ScaleOutput', B);
%
%   NITERS specifies the number of CORDIC kernel iterations. This is an
%   optional argument. More iterations may produce more accurate results,
%   at the expense of more computation/latency. When you specify NITERS
%   as a numeric value, it must be a positive integer-valued scalar. If
%   you do not specify NITERS, or specify it as empty or non-finite, the
%   algorithm uses a maximum value. For fixed-point operation, the
%   maximum number of iterations is one less than the word length of
%   C. For floating-point operation, the maximum value is 52 for double or
%   23 for single.
%
%   The optional parameter name-value pair ('ScaleOutput', B) specifies
%   whether to scale the output by the inverse CORDIC gain factor. The
%   default setting is true.
%
%   Example:
%
%   dblValues = complex(rand(5,4), rand(5,4));
%   fxpValues = fi(dblValues);
%   r_dbl_ref = abs(dblValues);
%   r_dbl_cdc = cordicabs(dblValues);
%   r_fxp_cdc = cordicabs(fxpValues);
%
%   See also ABS, CORDICCART2POL, CORDICANGLE.

%   Copyright 2011 The MathWorks, Inc.

%#codegen

if nargin > 1
    [~, r] = cordiccart2pol(real(c), imag(c), varargin{1:end});
else
    [~, r] = cordiccart2pol(real(c), imag(c));
end
