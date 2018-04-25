function [theta, r] = cordiccart2pol(x, y, varargin)
%CORDICCART2POL  Transform Cartesian to polar coordinates.
%   CORDICCART2POL(X, Y, ...) transforms corresponding elements of data
%   stored in Cartesian coordinates X and Y to polar coordinates (angle TH
%   and radius R).  The arrays X and Y must be the same size (or either can
%   be scalar). TH is returned in radians. Both X and Y must have the same
%   data type.
%
%   SYNTAX:
%     [TH, R] = CORDICCART2POL(X, Y);
%     [TH, R] = CORDICCART2POL(X, Y, NITERS);
%     [TH, R] = CORDICCART2POL(X, Y, NITERS, 'ScaleOutput', B);
%     [TH, R] = CORDICCART2POL(X, Y, 'ScaleOutput', B);
%
%   NITERS specifies the number of CORDIC kernel iterations. This is an
%   optional argument. More iterations may produce more accurate results,
%   at the expense of more computation/latency. When you specify NITERS
%   as a numeric value, it must be a positive integer-valued scalar. If
%   you do not specify NITERS, or specify it as empty or non-finite, the
%   algorithm uses a maximum value. For fixed-point operation, the
%   maximum number of iterations is one less than the word length of
%   X or Y. For floating-point operation, the maximum value is 52 for
%   double or 23 for single.
%
%   The optional parameter name-value pair ('ScaleOutput', B) specifies
%   whether to scale the output by the inverse CORDIC gain factor. The
%   default setting is true.
%
%   The range of the returned TH values is -pi <= TH <= pi radians.
%   If X and Y are floating-point, then TH has the same data type as X and
%   Y. Otherwise, TH is a fixed-point data type with the same word length
%   as Y,X and with a best precision fraction length for the [-pi, pi]
%   range.
%
%   Example:
%
%   [th_c2p_flt, r_c2p_flt] = cordiccart2pol(-0.5, 0.5);
%   [th_c2p_fxp, r_c2p_fxp] = cordiccart2pol(fi(-0.5,1,16,15), fi(0.5,1,16,15));
%   [th_mlb_flt, r_mlb_flt] = cart2pol(-0.5, 0.5);
%
%   See also CART2POL, CORDICATAN2.

%   Copyright 2010-2017 The MathWorks, Inc.

% =================
% Argument Checking
% =================
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[length_Y, length_X, nonscalarY, nonscalarX] = ...
    localCORDICCART2POLInputArgChecking(y, x);

if nonscalarY
    size_of_z   = size(y);
    length_of_z = length_Y;
else
    size_of_z   = size(x);
    length_of_z = length_X;
end

% Compute maximum number of iterations (maxNITERS)
if isa(y, 'double')
    maxNITERS = 52;
elseif isa(y, 'single')
    maxNITERS = 23;
else
    % FI fixed-point or FI double/single or builtin MATLAB integer
    if isfi(y)
        valueWithYNumType = y;
    else
        valueWithYNumType = fi(y);
    end
    
    % At this point, valueWithYNumType is a FI type
    if isfloat(valueWithYNumType)
        if isdouble(valueWithYNumType)
            maxNITERS = 52; % FI double
        else
            maxNITERS = 23; % FI single
        end
    else
        % Fixed-point or Scaled double
        maxNITERS = valueWithYNumType.WordLength - 1;
    end
end

numIters_dbl = maxNITERS; % default
doOutScaling = true; % default

if nargin > 2
    if ischar(varargin{1})
        doOutScaling = checkAndParsePVPairs(varargin);
    else
        numIters_dbl = fixed.internal.cordic_check_and_parse_niters(...
            varargin{1}, 'cordiccart2pol');
        
        if numIters_dbl > maxNITERS
            numIters_dbl = maxNITERS;
        end
        
        if (nargin > 3)
            doOutScaling = checkAndParsePVPairs(varargin(2:end));
        end
    end
end

% Compute constants (e.g., inpLUT) values and initialize inputs/outputs
inputLUT_dbl = fixed.internal.cordic_compute_atan_inputLUT_dbl(numIters_dbl);
invGC_dbl    = 1 / fixed.internal.cordic_compute_gain(numIters_dbl);

if isa(y, 'double')
    zero_of_z_type = 0;
    pi_of_z_type   = pi;
    invGC          = invGC_dbl; % Inverse CORDIC gain const
    inpLUT         = double(inputLUT_dbl);
    theta          = double(zeros(size_of_z)); % initialize output
    r              = double(zeros(size_of_z)); % initialize output
    xAcc           = double(0); % "Accumulator" type for X
    yAcc           = double(0); % "Accumulator" type for Y
    
elseif isa(y, 'single')
    zero_of_z_type = single(0);
    pi_of_z_type   = single(pi);
    invGC          = single(invGC_dbl); % Inverse CORDIC gain const
    inpLUT         = single(inputLUT_dbl);
    theta          = single(zeros(size_of_z)); % initialize output
    r              = single(zeros(size_of_z)); % initialize output
    xAcc           = single(0); % "Accumulator" type for X
    yAcc           = single(0); % "Accumulator" type for Y
    
elseif ~isfloat(y)
    % FIXED-POINT (builtin MATLAB integer or FI fixed-point inputs)
    
    % Get fixed-point input arg(s) information
    if isfi(y)
        fiValueWithYNumType = y;
    else
        fiValueWithYNumType = fi(y);
    end
    yWL = fiValueWithYNumType.WordLength;
    yFL = fiValueWithYNumType.FractionLength;

    % Z (theta) output type
    zWL = yWL;
    if issigned(fiValueWithYNumType)
        zFL = zWL - 3; % best precision frac length for range [-pi, pi)
    else
        zFL = zWL - 2; % best precision frac length for range [0, pi/2]
    end
    
    if (isfi(x) && isscaleddouble(x)) || (isfi(y) && isscaleddouble(y))
        zNT = numerictype(...
            'Signedness',     'Signed',...
            'WordLength',     zWL,...
            'FractionLength', zFL,...
            'DataTypeMode',   'Scaled double: binary point scaling');
    else
        zNT = numerictype(1, zWL, zFL);
    end
    
    zFm = fimath(...
        'ProductMode',           'SpecifyPrecision', ...
        'ProductWordLength',     zNT.WordLength, ...
        'ProductFractionLength', zNT.FractionLength, ...
        'SumMode',               'SpecifyPrecision', ...
        'SumWordLength',         zNT.WordLength, ...
        'SumFractionLength',     zNT.FractionLength, ...
        'RoundMode',             'floor', ...
        'OverflowMode',          'wrap');
    
    zero_of_z_type = fi( 0, zNT);
    pi_of_z_type   = fi(pi, zNT);
    inpLUT         = fi(inputLUT_dbl, zNT);
    inpLUT.fimath  = zFm;
    theta          = fi(zeros(size_of_z), zNT);
    theta.fimath   = zFm;
    
    % "Accumulator" types for X and Y summation ops (to avoid overflow):
    % Increase signed word length by TWO bits to avoid overflow, due to
    % both the CORDIC gain (~ 1.65) and sqrt(2) rotation worst case.
    % Total possible gain (worst case) is ~ 2.33 due to both gains.
    % Also retain input fraction length (full precision computations).
    xyWL = yWL + 2 + double(~issigned(fiValueWithYNumType));
    xyFL = yFL;
    
    if (isfi(x) && isscaleddouble(x)) || (isfi(y) && isscaleddouble(y))
        xyNT = numerictype(...
            'Signedness',     'Signed',...
            'WordLength',     xyWL,...
            'FractionLength', xyFL,...
            'DataTypeMode',   'Scaled double: binary point scaling');
    else
        xyNT = numerictype(1, xyWL, xyFL);
    end

    xAcc = fi(0, 1, xyWL, xyFL,'DataType',xyNT.DataType);
    yAcc = fi(0, 1, xyWL, xyFL,'DataType',xyNT.DataType);

    xyFm = fimath(...
        'ProductMode',           'SpecifyPrecision', ...
        'ProductWordLength',     xyNT.WordLength, ...
        'ProductFractionLength', xyNT.FractionLength, ...
        'SumMode',               'SpecifyPrecision', ...
        'SumWordLength',         xyNT.WordLength, ...
        'SumFractionLength',     xyNT.FractionLength, ...
        'RoundMode',             'floor', ...
        'OverflowMode',          'wrap');
    
    xAcc.fimath = xyFm;
    yAcc.fimath = xyFm;

    % Initialize R output
    r = fi(zeros(size_of_z), 1, xyWL, xyFL,'DataType',xyNT.DataType);
    r.fimath = xyFm;
    
    % Compute inverse gain constant (~0.607) to apply AFTER the
    % CORDIC iterations, to ensure maximum precision (no loss of
    % data prior to iterations). Initialize using "fimathless FI"
    % rules: NEAREST, SATURATE. Also, USE BEST PRECISION FRAC LEN.
%     invGC = sfi(invGC_dbl, yWL); % best precision frac len
    invGC = fi(invGC_dbl, 1, yWL, 'DataType',xyNT.DataType);
    invGC.fimath = xyFm; % local FIMATH for full precision prod
else
    % FI double/single
    if strcmpi(y.DataType, 'double')
        % FI double
        [theta_builtin_float, r_builtin_float] = ...
            cordiccart2pol(double(x), double(y), ...
            numIters_dbl, 'ScaleOutput', doOutScaling);
    else
        % FI single
        [theta_builtin_float, r_builtin_float] = ...
            cordiccart2pol(single(x), single(y), ...
            numIters_dbl, 'ScaleOutput', doOutScaling);
    end
    
    % Form FI double/single return value
    theta = fi(theta_builtin_float, numerictype(y));
    r     = fi(r_builtin_float,     numerictype(y));
    return; % EARLY RETURN
end

if (~nonscalarY)
    % SCALAR
    if y < 0
        yAcc(:) = -y; y_quad_adjust =  true; y_nonzero = true;
    else
        yAcc(:) =  y; y_quad_adjust = false; y_nonzero = (y > 0);
    end
end

if (~nonscalarX)
    % SCALAR
    if x < 0
        xAcc(:) = -x; x_quad_adjust = true;
    else
        xAcc(:) =  x; x_quad_adjust = false;
    end
end

for idx = 1:length_of_z
    % Get next value(s) in the input array(s)
    % ---------------------------------------
    if nonscalarY
        y_idx = y(idx);
        if y_idx < 0
            yAcc(:) = -y_idx; y_quad_adjust =  true; y_nonzero = true;
        else
            yAcc(:) =  y_idx; y_quad_adjust = false; y_nonzero = (y_idx > 0);
        end
    end
    
    if nonscalarX
        x_idx = x(idx);
        if x_idx < 0
            xAcc(:) = -x_idx; x_quad_adjust = true;
        else
            xAcc(:) =  x_idx; x_quad_adjust = false;
        end
    end

    % Run CORDIC Vectoring Kernel iterations
    % --------------------------------------
    [xN, ~, zN] = ...
        fixed.internal.cordic_vectoring_kernel_private(...
        xAcc, yAcc, zero_of_z_type, inpLUT, numIters_dbl);
    
    if doOutScaling
        r(idx) = xN .* invGC; % Scale R output by inverse CORDIC gain value
    else
        r(idx) = xN; % No output scaling
    end

    % Perform output quadrant correction
    % ----------------------------------
    if y_nonzero
        if x_quad_adjust
            if y_quad_adjust
                theta(idx) = zN - pi_of_z_type;
            else
                theta(idx) = pi_of_z_type - zN;
            end
        else
            if y_quad_adjust
                theta(idx) = -zN;
            else
                theta(idx) =  zN;
            end
        end
    elseif x_quad_adjust
        % Y is zero, X is negative
        % (special case: answer is PI instead of ZERO)
        theta(idx) = pi_of_z_type;
    else
        % Y is zero, X is NON-negative
        % (special case: answer is ZERO)
        theta(idx) = zero_of_z_type;
    end
end

if isfi(theta)
    theta.fimath = []; % Remove local FIMATH
    r.fimath     = []; % Remove local FIMATH
end


% =========================================================================
function [length_Y, length_X, nonscalarY, nonscalarX] = ...
    localCORDICCART2POLInputArgChecking(y, x)

% CHECK Y,X real
if ~isreal(y) || ~isreal(x)
    error(message('fixed:cordic:cart2pol_YXMustBeReal'));
end

% CHECK Y,X dims
length_Y   = numel(y);
length_X   = numel(x);
nonscalarY = length_Y > 1;
nonscalarX = length_X > 1;
if nonscalarY && nonscalarX
    if ~isequal(size(y), size(x))
        error(message('fixed:cordic:cart2pol_invalidDims'));
    end
end

% CHECK Y,X data types
if ~isequal(class(y), class(x))
    error(message('fixed:cordic:cart2pol_YXDataTypesMustMatch'));
elseif isfi(y)
    % Both Y and X inputs are FI types
    if strcmpi(y.DataType, 'boolean') || strcmpi(x.DataType, 'boolean')
        error(message('fixed:fi:unsupportedDataType', 'boolean'));
    elseif ~isequal(y.DataType, x.DataType)
        error(message('fixed:cordic:cart2pol_invalidMixedDataTypes'));
    elseif ~isfloat(y)
        % FI FIXED-POINT
        % Check that Y and X have same word lengths and fraction lengths
        ySG = issigned(y);
        yWL = y.WordLength;
        yFL = y.FractionLength;
        
        xSG = issigned(x);
        xWL = x.WordLength;
        xFL = x.FractionLength;
        
        if ~isequal(ySG, xSG) || ~isequal(yWL, xWL) || ~isequal(yFL, xFL)
            error(message('fixed:cordic:cart2pol_YXDataTypesMustMatch'));
        end
        
        if yWL < 2
            error(message('fixed:cordic:inputWordLengthNotGTOne'));
        end
    end
end

% CHECK Y,X numeric, non-empty, non-nan, non-inf
if ~(isnumeric(y) && ~(isempty(y) || any(isnan(y(:))) || any(isinf(y(:)))))
    error(message('fixed:cordic:cart2pol_invalidDataValue'));
elseif ~(isnumeric(x) && ~(isempty(x) || any(isnan(x(:))) || any(isinf(x(:)))))
    error(message('fixed:cordic:cart2pol_invalidDataValue'));
end


% =========================================================================
function doOutScaling = checkAndParsePVPairs(pvPairArgs)
% There should be only ONE PV Pair {'ScaleOutput', doOutScaling}
p = inputParser;
p.addParamValue('ScaleOutput', true, @(x)(isscalar(x) && (islogical(x) || (isnumeric(x) && isreal(x) && isfinite(x)))));
p.FunctionName = 'cordicrotate';
p.parse(pvPairArgs{:});
doOutScaling = logical(pvPairArgs{2});
