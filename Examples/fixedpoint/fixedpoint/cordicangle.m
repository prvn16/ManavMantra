function theta = cordicangle(c, niters)
%CORDICANGLE  CORDIC-based phase angle.
%   CORDICANGLE(C, ...) returns the phase angles, in radians, of a matrix
%   with complex elements.
%
%   SYNTAX:
%     THETA = CORDICANGLE(C);
%     THETA = CORDICANGLE(C, NITERS);
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
%   The range of the returned THETA values is -pi <= THETA <= pi radians.
%   If C is floating-point, then THETA has the same data type as C.
%   Otherwise, THETA is a fixed-point data type with the same word length
%   as C and with a best precision fraction length for the range -pi to
%   pi (i.e., equal to three less than the word length of C).
%
%   For example, C is fixed-point and the word length of C is 16, then
%   the word length of THETA is also 16 (but the fraction length is 13).
%
%   Example:
%
%   dblRandomVals = complex(rand(5,4), rand(5,4));
%   fxpRandomVals = fi(dblRandomVals);
%   theta_dbl_ref = angle(dblRandomVals);
%   theta_dbl_cdc = cordicangle(dblRandomVals);
%   theta_fxp_cdc = cordicangle(fxpRandomVals);
%
%   See also ANGLE, CORDICATAN2, CORDICCART2POL, CORDICABS.

%   Copyright 2011 The MathWorks, Inc.

%#codegen

% Call shared CORDICATAN2 function
if nargin > 1
    theta = cordicatan2(imag(c), real(c), niters);
else
    theta = cordicatan2(imag(c), real(c));
end
