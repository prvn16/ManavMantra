function [x, y] = cordicpol2cart(theta, r, varargin)
% CORDICPOL2CART CORDIC-based approximation of polar to Cartesian conversion
%    [X, Y] = CORDICPOL2CART(THETA, R, ...) computes the Cartesian (X,Y)
%    coordinates of R * e^(j*THETA) using a CORDIC algorithm approximation.
%
%    SYNTAX:
%      [X, Y] = CORDICPOL2CART(THETA, R);
%      [X, Y] = CORDICPOL2CART(THETA, R, NITERS);
%      [X, Y] = CORDICPOL2CART(THETA, R, NITERS, 'ScaleOutput', B);
%      [X, Y] = CORDICPOL2CART(THETA, R, 'ScaleOutput', B);
%
%    THETA can be a scalar, vector, matrix, or N-dimensional array
%    containing the angle values in radians. All THETA values must be in
%    the range [-2*pi, 2*pi).
%
%    R contains the magnitude value(s). R can be a scalar or have the same
%    dimensions as THETA. R must be real valued.
%
%    NITERS specifies the number of CORDIC kernel iterations. This is an
%    optional argument. More iterations may produce more accurate results,
%    at the expense of more computation/latency. When you specify NITERS
%    as a numeric value, it must be a positive integer-valued scalar. If
%    you do not specify NITERS, or specify it as empty or non-finite, the
%    algorithm uses a maximum value. For fixed-point operation, the maximum
%    number of iterations is the minimum of {one less than the word length
%    of THETA} and {the word length of U}. For floating-point operation,
%    the maximum value is 52 for double or 23 for single.
%
%    The optional parameter name-value pair ('ScaleOutput', B) specifies
%    whether to scale the output by the inverse CORDIC gain factor. The
%    default setting is true.
%
%    Example:
%
%    % Run the following code, and evaluate the accuracy
%    % of the CORDIC-based Polar-to-Cartesian conversion.
%    wrdLn = 16;
%    theta = fi(pi/3, 1, wrdLn);
%    u     = fi( 2.0, 1, wrdLn);
%    fprintf('\n\nNITERS\t\tX\t ERROR\t LSBs\t\tY\t ERROR\t LSBs\n');
%    fprintf('------\t\t-------\t ------\t ----\t\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%        [x_ref, y_ref] = pol2cart(double(theta),double(u));
%        [x_fi,  y_fi] = cordicpol2cart(theta, u, niters);
%        x_dbl = double(x_fi);
%        y_dbl = double(y_fi);
%        x_err = abs(x_dbl - x_ref);
%        y_err = abs(y_dbl - y_ref);
%        fprintf('   %d\t\t%1.4f\t %1.4f\t %1.1f\t\t%1.4f\t %1.4f\t %1.1f\n', ...
%            niters, x_dbl, x_err, (x_err * pow2(x_fi.FractionLength)), ...
%            y_dbl, y_err, (y_err * pow2(y_fi.FractionLength)));
%    end
%
%    See also CORDICROTATE, CORDICSINCOS, POL2CART.

% Copyright 2009-2017 The MathWorks, Inc.
%   

% CHECK r: real
% (remaining input arg checks done in shared CORDICROTATE function)
% -----------------------------------------------------------------
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if ~isreal(r)
    error(message('fixed:cordic:pol2cart_invalidR'));
end

% Use shared CORDICROTATE function for CORDICPOL2CART computation
% ---------------------------------------------------------------
if nargin > 2
    v = cordicrotate(theta, r, varargin{1:end});
else
    v = cordicrotate(theta, r);
end
x = real(v);
y = imag(v);

% [EOF]

