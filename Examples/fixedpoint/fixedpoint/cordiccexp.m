function cis_out = cordiccexp(theta, niters)
% CORDICCEXP CORDIC-based approximation of complex exponential e^(j*THETA).
%    CIS = CORDICCEXP(THETA, NITERS) computes COS(THETA) + j*SIN(THETA)
%    using a CORDIC algorithm approximation and returns the complex result.
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
%      cis    = cordiccexp(theta, niters);
%      fl     = cis.FractionLength;
%      x      = real(cis);
%      y      = imag(cis);
%      x_dbl  = double(x);
%      x_err  = abs(x_dbl - cos(double(theta)));
%      y_dbl  = double(y);
%      y_err  = abs(y_dbl - sin(double(theta)));
%      fprintf('  %d\t\t%1.4f\t %1.4f\t %1.1f\t\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              y_dbl, y_err, (y_err * pow2(fl)), ...
%              x_dbl, x_err, (x_err * pow2(fl)));
%    end
%    fprintf('\n');
%
%    % NITERS    Y (SIN)  ERROR   LSBs    X (COS)  ERROR   LSBs
%    % ------    -------  ------  ----    -------  ------  ----
%    %   1       0.7031   0.2968  19.0     0.7031  0.7105  45.5
%    %   2       0.9375   0.0625   4.0     0.3125  0.3198  20.5
%    %   3       0.9844   0.0156   1.0     0.0938  0.1011   6.5
%    %   4       0.9844   0.0156   1.0    -0.0156  0.0083   0.5
%    %   5       1.0000   0.0000   0.0     0.0312  0.0386   2.5
%    %   6       1.0000   0.0000   0.0     0.0000  0.0073   0.5
%    %   7       1.0000   0.0000   0.0     0.0156  0.0230   1.5
%
%
%    See also CORDICSINCOS, CORDICSIN, CORDICCOS.

% Copyright 2009-2013 The MathWorks, Inc.

% =================
% Argument Checking
% =================
fixed.internal.cordic_check_theta_arg(theta, 'cordiccexp');

length_Theta = numel(theta);

% Compute maximum number of iterations (maxNITERS)
if isa(theta, 'double')
    maxNITERS = 52;
elseif isa(theta, 'single')
    maxNITERS = 23;
else
    % FI fixed-point or FI double/single or builtin MATLAB integer
    if isfi(theta)
        valueWithThetaNumType = theta;
    else
        valueWithThetaNumType = fi(theta);
    end
    
    % At this point, valueWithThetaNumType is a FI type
    if isfloat(valueWithThetaNumType)
        if isdouble(valueWithThetaNumType)
            maxNITERS = 52; % FI double
        else
            maxNITERS = 23; % FI single
        end
    else
        % Fixed-point or Scaled double
        thetaWL = valueWithThetaNumType.WordLength;
        if thetaWL < 2
            error(message('fixed:cordic:inputWordLengthNotGTOne'));
        end
        maxNITERS = thetaWL - 1;
    end
end

% Compute actual number of iterations (numIters_dbl)
if nargin > 1
    numIters_dbl = fixed.internal.cordic_check_and_parse_niters(...
        niters, 'cordiccexp');
    if numIters_dbl > maxNITERS
        numIters_dbl = maxNITERS;
    end
else
    numIters_dbl = maxNITERS; % default
end
        
% =====================================================================
% Quadrant Correction for input angle(s); correct to range [-pi/2 pi/2]
% =====================================================================
[theta_in_range, needToNegate] = ...
    fixed.internal.cordiccexpInputQuadrantCorrection(theta(:), length_Theta);

% =====================================================
% Off-line initializations for CORDIC sin-cos algorithm
% =====================================================
inputLUT_dbl = fixed.internal.cordic_compute_atan_inputLUT_dbl(numIters_dbl);
cordicGn_dbl = fixed.internal.cordic_compute_gain(numIters_dbl);

if isa(theta, 'double')
    size_Theta   = size(theta);
    x_dbl        = ones( size_Theta ) / cordicGn_dbl;
    y_dbl        = zeros(size_Theta);
    cis_out      = double(complex(x_dbl, y_dbl));
    inpLUT       = double(inputLUT_dbl);
    z            = double(theta_in_range);
elseif isa(theta, 'single')
    size_Theta   = size(theta);
    x_dbl        = ones( size_Theta ) / cordicGn_dbl;
    y_dbl        = zeros(size_Theta);
    cis_out      = single(complex(x_dbl, y_dbl));
    inpLUT       = single(inputLUT_dbl);
    z            = single(theta_in_range);
else
    % Fixed-point or builtin integer or FI double/single
    if isfi(theta)
        fiValueWithThetaNumType = theta;
    else
        fiValueWithThetaNumType = fi(theta);
    end
    
    % CORDIC kernel I-O signedness, word length, and fraction length
    ioLoopNumTyp = fiValueWithThetaNumType.numerictype;
    
    if ~isfloat(ioLoopNumTyp)
        % Fixed-point or Scaled double
        ioLoopNumTyp.Signedness     = 'Signed';
        ioWordLength                = ioLoopNumTyp.WordLength;
        ioFracLength                = ioWordLength - 2;
        ioLoopNumTyp.FractionLength = ioFracLength;
        
        % Make every variable involved in arithmetic use same localFimath
        % (Note: I-O WL/FL could be different than for quadrant corr above)
        localFimath = ...
            fixed.internal.computeFimathForCORDIC(...
            fiValueWithThetaNumType, ioWordLength, ioFracLength);
    end
    
    % First initialize all values using the "fimathless FI" rules
    % (i.e. float-to-fixed value casts use round to nearest and saturate)
    size_Theta   = size(theta);
    x_dbl        = ones( size_Theta ) / cordicGn_dbl;
    y_dbl        = zeros(size_Theta);
    cis_out      = fi(complex(x_dbl, y_dbl), ioLoopNumTyp);
    inpLUT       = fi(inputLUT_dbl,          ioLoopNumTyp);
    
    if isscaledtype(ioLoopNumTyp)
        cis_out.fimath = localFimath;
        inpLUT.fimath  = localFimath;
        z              = fi(theta_in_range, ioLoopNumTyp, localFimath);
    else
        % FI double or FI single
        z = fi(theta_in_range, ioLoopNumTyp);
    end
end

% =========================================
% Perform CORDIC Iterations and Form Output
% =========================================
for idx = 1:length_Theta
    [xRe, yIm] = fixed.internal.cordic_rotation_kernel_private( ...
        real(cis_out(idx)), imag(cis_out(idx)), z(idx), ...
        inpLUT, numIters_dbl);

    if needToNegate(idx)
        cis_out(idx) = complex(-xRe, -yIm);
    else
        cis_out(idx) = complex( xRe,  yIm);
    end
end

if isfi(cis_out)
    cis_out.fimath = []; % remove local fimath
end


% LocalWords:  CORDIC CIS NITERS wrd Bs niters cis CORDICSINCOS CORDICSIN Iters
% LocalWords:  CORDICCOS fixedpoint invalidtheta invalidniters fimathless WL
% LocalWords:  signedness
