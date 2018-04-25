function [sin_out, cos_out] = cordicsincos(theta, niters)
% CORDICSINCOS CORDIC-based approximation of SIN and COS.
%    [Y, X] = CORDICSINCOS(THETA, NITERS) computes the sine and cosine of
%    THETA using a CORDIC algorithm approximation. Y contains the
%    approximate sine result and X contains the approximate cosine result.
%
%    THETA can be a scalar, vector, matrix, or N-dimensional array
%    containing the angle values in radians. All THETA values must be in
%    the range [-2*pi, 2*pi).
%
%    NITERS specifies the number of CORDIC kernel iterations. This is an
%    optional argument. More iterations may produce more accurate results,
%    at the expense of more computation/latency. When you specify NITERS
%    as a numeric value, it must be a positive integer-valued scalar. If
%    you do not specify NITERS, or specify it as empty or non-finite, the
%    algorithm uses a maximum value. For fixed-point operation, the
%    maximum number of iterations is one less than the word length of
%    THETA. For floating-point operation, the maximum value is 52 for
%    double or 23 for single.
%
%    EXAMPLE: Compare the accuracy of CORDIC-based SIN and COS results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\t\tY (SIN)\t ERROR\t LSBs\t\tX (COS)\t ERROR\t LSBs\n');
%    fprintf('------\t\t-------\t ------\t ----\t\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      [y, x] = cordicsincos(theta, niters);
%      y_FL   = y.FractionLength;
%      y_dbl  = double(y);
%      x_dbl  = double(x);
%      y_err  = abs(y_dbl - sin(double(theta)));
%      x_err  = abs(x_dbl - cos(double(theta)));
%      fprintf('  %d\t\t%1.4f\t %1.4f\t %1.1f\t\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              y_dbl, y_err, (y_err * pow2(y_FL)), ...
%              x_dbl, x_err, (x_err * pow2(y_FL)));
%    end
%    fprintf('\n');
%  
%    % NITERS      Y (SIN)  ERROR   LSBs      X (COS)  ERROR   LSBs
%    % ------      -------  ------  ----      -------  ------  ----
%    %   1         0.7031   0.2968  19.0      0.7031   0.7105  45.5
%    %   2         0.9375   0.0625  4.0       0.3125   0.3198  20.5
%    %   3         0.9844   0.0156  1.0       0.0938   0.1011  6.5
%    %   4         0.9844   0.0156  1.0       -0.0156  0.0083  0.5
%    %   5         1.0000   0.0000  0.0       0.0312   0.0386  2.5
%    %   6         1.0000   0.0000  0.0       0.0000   0.0073  0.5
%    %   7         1.0000   0.0000  0.0       0.0156   0.0230  1.5
%
%
%    See also CORDICCEXP, CORDICSIN, CORDICCOS.

% Copyright 2009-2012 The MathWorks, Inc.

if (nargin == 1)
    cis_out = cordiccexp(theta);
else
    cis_out = cordiccexp(theta, niters);
end    
cos_out = real(cis_out);
sin_out = imag(cis_out);

% [EOF]

