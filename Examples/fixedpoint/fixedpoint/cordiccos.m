function cos_out = cordiccos(theta, niters)
% CORDICCOS CORDIC-based approximation of COS.
%    X = CORDICCOS(THETA, NITERS) computes the cosine of THETA using a
%    CORDIC algorithm approximation. X contains the approximate result.
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
%    EXAMPLE: Compare the accuracy of CORDIC-based COS results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\tX (COS)\t ERROR\t LSBs\n');
%    fprintf('------\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      x      = cordiccos(theta, niters);
%      x_FL   = x.FractionLength;
%      x_dbl  = double(x);
%      x_err  = abs(x_dbl - cos(double(theta)));
%      fprintf('  %d\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              x_dbl, x_err, (x_err * pow2(x_FL)));
%    end
%    fprintf('\n');
%  
%    % NITERS  X (COS)  ERROR   LSBs
%    % ------  -------  ------  ----
%    %   1     0.7031   0.7105  45.5
%    %   2     0.3125   0.3198  20.5
%    %   3     0.0938   0.1011  6.5
%    %   4     -0.0156  0.0083  0.5
%    %   5     0.0312   0.0386  2.5
%    %   6     0.0000   0.0073  0.5
%    %   7     0.0156   0.0230  1.5
%
%
%    See also CORDICCEXP, CORDICSIN, CORDICSINCOS.

% Copyright 2009-2012 The MathWorks, Inc.

if (nargin == 1)
    cis_out = cordiccexp(theta);
else
    cis_out = cordiccexp(theta, niters);
end
cos_out = real(cis_out);

% [EOF]

