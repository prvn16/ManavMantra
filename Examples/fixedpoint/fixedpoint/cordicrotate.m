function v = cordicrotate(theta, u, varargin)
% CORDICROTATE Rotate input using CORDIC-based approximation
%    V = CORDICROTATE(THETA, U, ...) computes U * e^(j*THETA) using a
%    CORDIC rotation algorithm approximation.
%
%    SYNTAX:
%      V = CORDICROTATE(THETA, U);
%      V = CORDICROTATE(THETA, U, NITERS);
%      V = CORDICROTATE(THETA, U, NITERS, 'ScaleOutput', B);
%      V = CORDICROTATE(THETA, U, 'ScaleOutput', B);
%
%    THETA can be a scalar, vector, matrix, or N-dimensional array
%    containing the angle values in radians. All THETA values must be in
%    the range [-2*pi, 2*pi).
%
%    U can be a scalar or have the same dimensions as THETA.
%    U can be real or complex valued.
%
%    NITERS specifies the number of CORDIC kernel iterations. This is an
%    optional argument. More iterations may produce more accurate results,
%    at the expense of more computation/latency. When you specify NITERS
%    as a numeric value, it must be a positive integer-valued scalar. If
%    you do not specify NITERS, or specify it as empty or non-finite, the
%    algorithm uses a maximum value. For fixed-point operation, the maximum
%    number of iterations is the minimum of: one less than the word length
%    of THETA, and the word length of U. For floating-point operation,
%    the maximum value is 52 for double or 23 for single.
%
%    The optional parameter name-value pair ('ScaleOutput', B) specifies
%    whether to scale the output by the inverse CORDIC gain factor. The
%    default setting is true.
%
%    Example:
%
%    % Run the following code, and evaluate the accuracy
%    % of the CORDIC-based complex rotation.
%    wrdLn = 16;
%    theta = fi(-pi/3, 1, wrdLn);
%    u     = fi(0.25 - 7.1i, 1, wrdLn);
%    uTeTh = double(u) .* exp(1i * double(theta));
%    fprintf('\n\nNITERS\t\tReal\t ERROR\t LSBs\t\tImag\t ERROR\t LSBs\n');
%    fprintf('------\t\t-------\t ------\t ----\t\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%        v_fi   = cordicrotate(theta, u, niters);
%        v_dbl  = double(v_fi);
%        x_err  = abs(real(v_dbl) - real(uTeTh));
%        y_err  = abs(imag(v_dbl) - imag(uTeTh));
%        fprintf('   %d\t\t%1.4f\t %1.4f\t %1.1f\t\t%1.4f\t %1.4f\t %1.1f\n', ...
%          niters, real(v_dbl), x_err, (x_err * pow2(v_fi.FractionLength)), ...
%          imag(v_dbl), y_err, (y_err * pow2(v_fi.FractionLength)));
%    end
%
%    See also CORDICPOL2CART, CORDICCEXP.

% Copyright 2009-2017 The MathWorks, Inc.

% =================
% Argument Checking
% =================
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[length_Theta, length_U, nonscalarTheta, nonscalarU] = ...
    localCORDICROTATEInputArgChecking(theta, u);

if nonscalarU
    outLen = length_U;
    sz     = size(u);
else
    outLen = length_Theta;
    sz     = size(theta);
end

% -------------------------------------------------------------------------
% Supported OPTIONAL argument and P-V pair syntaxes:
%
%   CORDICROTATE(T, U)
%   CORDICROTATE(T, U, N)
%   CORDICROTATE(T, U, N, 'ScaleOutput', B)
%   CORDICROTATE(T, U, 'ScaleOutput', B)
%
% The following syntax presently causes an error to occur:
%
%   CORDICROTATE(T, U, N, B)
% -------------------------------------------------------------------------
numIters_dbl = inf;  % default
doOutScaling = true; % default
if (nargin > 2)
    if ischar(varargin{1})
        doOutScaling = checkAndParsePVPairs(varargin);
    else
        numIters_dbl = fixed.internal.cordic_check_and_parse_niters(...
            varargin{1}, 'cordicrotate');
        if (nargin > 3)
            doOutScaling = checkAndParsePVPairs(varargin(2:end));
        end
    end
end

% =====================================================================
% Quadrant Correction for input angle(s); correct to range [-pi/2 pi/2]
% =====================================================================
[theta_in_range, needToNegate] = ...
    fixed.internal.cordiccexpInputQuadrantCorrection(theta(:), length_Theta);

% =========================================
% CORDIC rotation algorithm initializations
% =========================================

% INPUT side ("z") data type casts
% --------------------------------
if isa(theta, 'double')
    % Adjust for maximum number of iterations for 'double'
    maxNITERS = 52;
    if numIters_dbl > maxNITERS
        numIters_dbl = maxNITERS;
    end
    
    invGC_dbl    = 1 / fixed.internal.cordic_compute_gain(numIters_dbl);
    inputLUT_dbl = fixed.internal.cordic_compute_atan_inputLUT_dbl(numIters_dbl);
    inpLUT       = inputLUT_dbl;
    z            = theta_in_range;
elseif isa(theta, 'single')
    % Adjust for maximum number of iterations for 'single'
    maxNITERS = 23;
    if numIters_dbl > maxNITERS
        numIters_dbl = maxNITERS;
    end
    
    invGC_dbl    = 1 / fixed.internal.cordic_compute_gain(numIters_dbl);
    inputLUT_dbl = fixed.internal.cordic_compute_atan_inputLUT_dbl(numIters_dbl);
    inpLUT       = single(inputLUT_dbl);
    z            = single(theta_in_range);
else
    % Fixed-point or builtin integer or FI double/single
    if isfi(theta)
        thetaValueWithNumericType = theta;
    else
        thetaValueWithNumericType = fi(theta);
    end
    
    % Retain word length of THETA, adjust fraction length to best precision
    inpLoopNumTyp = thetaValueWithNumericType.numerictype;
    if ~isfloat(inpLoopNumTyp)
        inLpWL = inpLoopNumTyp.WordLength;
        if inLpWL < 2
            error(message('fixed:cordic:inputWordLengthNotGTOne'));
        end
        inpLoopNumTyp.Signedness     = 'Signed';
        inpLoopNumTyp.FractionLength = inLpWL - 2;
    end
    
    % Adjust for maximum number of iterations
    if isfi(u)
        uFPWL = u.WordLength;
    else
        uWithNumTyp = fi(u);
        uFPWL = uWithNumTyp.WordLength;
    end
    
    if uFPWL < 2
        error(message('fixed:cordic:inputWordLengthNotGTOne'));
    end
    
    maxNITERS = min((inpLoopNumTyp.WordLength - 1), uFPWL);
    if numIters_dbl > maxNITERS
        numIters_dbl = maxNITERS;
    end
    
    invGC_dbl    = 1 / fixed.internal.cordic_compute_gain(numIters_dbl);
    inputLUT_dbl = fixed.internal.cordic_compute_atan_inputLUT_dbl(numIters_dbl);

    % First initialize all values using the "fimathless FI" rules
    % (i.e. float-to-fixed value casts use round to nearest and saturate)
    inpLUT = fi(inputLUT_dbl,   inpLoopNumTyp);
    
    % Use localFimath for theta ("Z") CORDIC arithmetic
    if ~isfloat(inpLoopNumTyp)
        % FI fixed-point
        
        % Using local Z fimath here (e.g. floor/wrap)
        zFm = fixed.internal.computeFimathForCORDIC(...
            thetaValueWithNumericType, ...
            inpLoopNumTyp.WordLength,  ...
            inpLoopNumTyp.FractionLength);

        z = fi(theta_in_range, inpLoopNumTyp, zFm);

        inpLUT.fimath = zFm;
        z.fimath      = zFm;
    else
        % FI double or FI single
        z = fi(theta_in_range, inpLoopNumTyp);
    end
end

% OUTPUT side ("x", "y") data type casts
% --------------------------------------
if isa(u, 'double')
    invGC = invGC_dbl; % Inverse gain const (applied AFTER CORDIC kernel)
    
    if isreal(u)
        v = complex(u .* double(ones(sz)), zeros(sz));
    else
        v = u .* double(ones(sz));
    end
    
elseif isa(u, 'single')
    invGC = single(invGC_dbl); % Inverse gain const (applied AFTER CORDIC)

    if isreal(u)
        v = complex(u .* single(ones(sz)), single(zeros(sz)));
    else
        v = u .* single(ones(sz));
    end
    
else
    % Fixed-point or builtin integer or FI double/single
    if isfi(u)
        if isfloat(u)
            % FI double/single
            isFixedPtOp = false;
            isUnsUInput = false;
            uWL         = u.WordLength;
            uFL         = 0; % arbitrary default
        else
            % Fixed-point or Scaled double
            isFixedPtOp = true;
            isUnsUInput = ~issigned(u);
            uWL         = u.WordLength;
            uFL         = u.FractionLength;
        end
    else
        % Builtin integer (treat as FI fixed-point)
        isFixedPtOp = true;
        uWithNumTyp = fi(u);
        isUnsUInput = ~issigned(uWithNumTyp);
        uWL         = uWithNumTyp.WordLength;
        uFL         = uWithNumTyp.FractionLength;
    end

    if isFixedPtOp
        % Increase signed word length by TWO bits to avoid overflow, due to
        % both the CORDIC gain (~ 1.65) and sqrt(2) rotation worst case.
        % Total possible gain (worst case) is ~ 2.33 due to both gains.
        % Also retain input fraction length (full precision computations).
        xyWL = uWL + 2 + double(isUnsUInput); % account for sign bit
        xyFL = uFL;
        
        if (isfi(u) && isscaleddouble(u)) || (isfi(theta) && isscaleddouble(theta))
            xyNT = numerictype(...
                'Signedness',     'Signed',...
                'WordLength',     xyWL,...
                'FractionLength', xyFL,...
                'DataTypeMode',   'Scaled double: binary point scaling');
        else
            xyNT = numerictype(1, xyWL, xyFL);
        end

        % Use localFimath for "X-Y" CORDIC arithmetic.
        xyFm = fimath(...
                'ProductMode',           'SpecifyPrecision', ...
                'ProductWordLength',     xyNT.WordLength, ...
                'ProductFractionLength', xyNT.FractionLength, ...
                'SumMode',           'SpecifyPrecision', ...
                'SumWordLength',     xyNT.WordLength, ...
                'SumFractionLength', xyNT.FractionLength, ...
                'RoundMode',         'floor', ...
                'OverflowMode',      'wrap'...
                );
            
        % Compute inverse gain constant (~0.607) to apply AFTER the
        % CORDIC iterations, to ensure maximum precision (no loss of
        % data prior to iterations). Initialize using "fimathless FI"
        % rules: NEAREST, SATURATE. Also, USE BEST PRECISION FRAC LEN.
%         invGC = sfi(invGC_dbl, uWL); % best precision frac len
        invGC = fi(invGC_dbl, 1, uWL, 'DataType',xyNT.DataType);
        invGC.fimath = xyFm; % local FIMATH for full precision prod
    else
        % FI double/single etc.
        xyNT  = u.numerictype;
        xyFm  = [];
        invGC = fi(invGC_dbl, xyNT);
    end
    
    % Initial CORDIC X-Y values (reuse V in-place for I/O)
    if nonscalarU
        % Output matches size of U input
        v = fi(complex(real(u), imag(u)), xyNT, xyFm);
    else
        % Output matches size of THETA input.
        v    = fi(complex(zeros(sz), zeros(sz)), xyNT, xyFm);
        v(:) = fi(complex(real(u),   imag(u)),   xyNT, xyFm);
    end
end

% Perform CORDIC Iterations and Form Output
if nonscalarTheta
    for idx = 1:outLen
        [xRe, yIm] = fixed.internal.cordic_rotation_kernel_private( ...
            real(v(idx)), imag(v(idx)), z(idx), inpLUT, numIters_dbl);

        if needToNegate(idx)
            xRe(:) = -xRe;
            yIm(:) = -yIm;
        end
        
        if doOutScaling
            xRePrd = xRe .* invGC;
            yImPrd = yIm .* invGC;
            v(idx) = complex(xRePrd,  yImPrd);
        else
            v(idx) = complex(xRe,  yIm);
        end
    end
else
    % Scalar THETA (possibly non-scalar X-Y)
    for idx = 1:outLen
        [xRe, yIm] = fixed.internal.cordic_rotation_kernel_private( ...
            real(v(idx)), imag(v(idx)), z, inpLUT, numIters_dbl);

        if needToNegate
            tmpNeg = -xRe;
            xRe(:) = tmpNeg;
            tmpNeg = -yIm;
            yIm(:) = tmpNeg;
        end
        
        if doOutScaling
            xRePrd = xRe .* invGC;
            yImPrd = yIm .* invGC;
            v(idx) = complex(xRePrd,  yImPrd);
        else
            v(idx) = complex(xRe,  yIm);
        end
    end
end

if isfi(v)
    v.fimath = []; % remove local fimath
end


% =========================================================================
function [length_Theta, length_U, nonscalarTheta, nonscalarU] = ...
    localCORDICROTATEInputArgChecking(theta, u)

% CHECK theta and u dimensions
length_Theta   = numel(theta);
length_U       = numel(u);
nonscalarTheta = length_Theta > 1;
nonscalarU     = length_U > 1;
if nonscalarTheta && nonscalarU
    if ~isequal(size(theta), size(u))
        error(message('fixed:cordic:rotate_invalidDims'));

    end
end

% CHECK theta and u data types
if isfloat(theta) || isfloat(u)
    if ~isequal(class(theta), class(u))
        error(message('fixed:cordic:rotate_invalidMixedDataTypes'));
    end
    
    if isfi(theta) && strcmpi(theta.DataType, 'boolean')
        error(message('fixed:fi:unsupportedDataType', 'boolean'));
    end
    
    if isfi(u) && strcmpi(u.DataType, 'boolean')
        error(message('fixed:fi:unsupportedDataType', 'boolean'));
    end
    
    if isfi(theta) && isfi(u)
        if ~isequal(theta.DataType, u.DataType)
            error(message('fixed:cordic:rotate_invalidMixedDataTypes'));
        end
    end
end

% Common CORDIC theta argument checking
fixed.internal.cordic_check_theta_arg(theta, 'cordicrotate');

% CHECK u: numeric, non-empty, non-nan, non-inf
if ~(isnumeric(u) && ~(isempty(u) || any(isnan(u(:))) || any(isinf(u(:)))))
    error(message('fixed:cordic:rotate_invalidU'));
end


% =========================================================================
function doOutScaling = checkAndParsePVPairs(pvPairArgs)
% There should be only ONE PV Pair {'ScaleOutput', doOutScaling}
p = inputParser;
p.addParamValue('ScaleOutput', true, @(x)(isscalar(x) && (islogical(x) || (isnumeric(x) && isreal(x) && isfinite(x)))));
p.FunctionName = 'cordicrotate';
p.parse(pvPairArgs{:});
doOutScaling = logical(pvPairArgs{2});


% LocalWords:  CORDIC NITERS CORDICPOL CORDICCEXP fixedpoint invalidtheta PV
% LocalWords:  invalidu invaliddims invaliddtypes invalidparam
% LocalWords:  fimathless invalidnargin
