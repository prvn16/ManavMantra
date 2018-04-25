function theta = cordicatan2(y, x, niters)
%CORDICATAN2  CORDIC-based four quadrant inverse tangent.
%   CORDICATAN2(Y, X, ...) is the four quadrant arctangent of the elements
%   of Y and X. Both Y and X must have the same data type.
%
%   SYNTAX:
%     THETA = CORDICATAN2(Y, X);
%     THETA = CORDICATAN2(Y, X, NITERS);
%
%   NITERS specifies the number of CORDIC kernel iterations. This is an
%   optional argument. More iterations may produce more accurate results,
%   at the expense of more computation/latency. When you specify NITERS
%   as a numeric value, it must be a positive integer-valued scalar. If
%   you do not specify NITERS, or specify it as empty or non-finite, the
%   algorithm uses a maximum value. For fixed-point operation, the
%   maximum number of iterations is one less than the word length of
%   Y or X. For floating-point operation, the maximum value is 52 for
%   double or 23 for single.
%
%   The range of the returned THETA values is -pi <= THETA <= pi radians.
%   If Y,X are floating-point, then THETA has the same data type as Y,X.
%   Otherwise, THETA is a fixed-point data type with the same word length
%   as Y,X and with a best precision fraction length for the [-pi, pi]
%   range.
%
%   Example:
%
%   theta_cdat2_float = cordicatan2(0.5, -0.5);
%   theta_cdat2_fixpt = cordicatan2(fi(0.5,1,16,15), fi(-0.5,1,16,15));
%   theta_atan2_float = atan2(0.5, -0.5);
%   theta_atan2_fixpt = atan2(fi(0.5,1,16,15), fi(-0.5,1,16,15));
%
%   See also ATAN2.

%   Copyright 2010-2011 The MathWorks, Inc.

%#codegen

% Call shared CORDICCART2POL function
if nargin > 2
    theta = cordiccart2pol(x, y, niters, 'ScaleOutput', false);
else
    theta = cordiccart2pol(x, y, 'ScaleOutput', false);
end
