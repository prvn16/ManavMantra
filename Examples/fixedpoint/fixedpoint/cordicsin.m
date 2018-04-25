function sin_out = cordicsin(theta, niters)
% CORDICSIN CORDIC-based approximation of SIN.
%    Y = CORDICSIN(THETA, NITERS) computes the sine of THETA using a
%    CORDIC algorithm approximation. Y contains the approximate result.
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
%    EXAMPLE: Compare the accuracy of CORDIC-based SIN results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\tY (SIN)\t ERROR\t LSBs\n');
%    fprintf('------\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      y      = cordicsin(theta, niters);
%      y_FL   = y.FractionLength;
%      y_dbl  = double(y);
%      y_err  = abs(y_dbl - sin(double(theta)));
%      fprintf('  %d\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              y_dbl, y_err, (y_err * pow2(y_FL)));
%    end
%    fprintf('\n');
%  
%    % NITERS  Y (SIN)  ERROR   LSBs
%    % ------  -------  ------  ----
%    %   1     0.7031   0.2968  19.0
%    %   2     0.9375   0.0625  4.0 
%    %   3     0.9844   0.0156  1.0 
%    %   4     0.9844   0.0156  1.0 
%    %   5     1.0000   0.0000  0.0 
%    %   6     1.0000   0.0000  0.0 
%    %   7     1.0000   0.0000  0.0 
%
%
%    See also CORDICCEXP, CORDICCOS, CORDICSINCOS.

% Copyright 2009-2012 The MathWorks, Inc.

if (nargin == 1)
    cis_out = cordiccexp(theta);
else
    cis_out = cordiccexp(theta, niters);
end
sin_out = imag(cis_out);

% [EOF]

