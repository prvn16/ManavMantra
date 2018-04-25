function out = cordicsqrt(u, varargin)
%CORDICSQRT  CORDIC-based square root.
%   CORDICSQRT(U, ...) returns the square root of the elements of U.
%
%   SYNTAX:
%     Y = CORDICSQRT(U);
%     Y = CORDICSQRT(U, NITERS);
%     Y = CORDICSQRT(U, NITERS, 'ScaleOutput', B);
%     Y = CORDICSQRT(U, 'ScaleOutput', B);
%
%   The data input array U must be real-valued and non-negative.
%
%   NITERS specifies the number of CORDIC kernel iterations.
%   This is an optional argument. More iterations may produce
%   more accurate results, at the expense of more computation/latency. 
%   When you specify NITERS as a numeric value, it must be a positive 
%   integer-valued scalar. If you do not specify NITERS, or specify it 
%   as empty or non-finite, the algorithm uses a default value. For 
%   fixed-point operation, the default number of iterations is one 
%   less than the word length of U. For floating-point operation, the 
%   default value is 52 for double or 23 for single.
%
%   The optional parameter name-value pair ('ScaleOutput', B) 
%   specifies whether to scale the output by the inverse CORDIC gain
%   factor. The default setting is true.
%
%   Example:
%
%     % Compute results
%     fxpValues = fi((0:0.025:2), 0, 16); % Fixed-point input values
%     dblValues = double(fxpValues);      % Floating-pt reference values
%     y_dbl_ref = sqrt(dblValues);        % Floating-pt reference SQRT
%     y_dbl_cdc = cordicsqrt(dblValues);  % Floating-pt CORDICSQRT
%     y_fxp_cdc = cordicsqrt(fxpValues);  % Fixed-point CORDICSQRT
%
%     % Plot results
%     figure; subplot(311);
%     plot(dblValues, y_dbl_ref, 'b-', dblValues, y_fxp_cdc, 'r.');
%     title('sqrt(x) and cordicsqrt(x)');
%     legend('SQRT Reference', 'CORDICSQRT', 'Location', 'SouthEast');
%     subplot(312);
%     lsbErrDbl = ceil((abs(double(y_dbl_cdc)-y_dbl_ref)) ./ eps(y_dbl_cdc));
%     plot(dblValues, lsbErrDbl, 'b-');
%     title('Absolute Error relative to EPS (floating-point cordicsqrt vs. floating-point sqrt)');
%     subplot(313);
%     lsbErrFxp = ceil((abs(double(y_fxp_cdc)-y_dbl_ref)) ./ eps(y_fxp_cdc));
%     plot(dblValues, lsbErrFxp, 'r-');
%     title('Absolute Error relative to EPS (fixed-point cordicsqrt vs. floating-point sqrt)');
%
%   See also SQRT.

%   Copyright 2013-2017 The MathWorks, Inc.

% Argument Checking for MATLAB simulation
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1,4);
if ~isreal(u) || ~isnumeric(u)
    error(message('fixed:fi:realAndNumeric'));
elseif isfi(u) && ~isfloat(u)
    if strcmpi(u.DataType, 'boolean')
        error(message('fixed:fi:unsupportedDataType', 'boolean'));
    elseif ~isscalingbinarypoint(u)
        error(message('fixed:fi:inputsMustBeIntOrFixPtBPSOrSDBPS'));
    elseif (u.WordLength < 2)
        error(message('fixed:cordic:inputWordLengthNotGTOne'));
    end
end

if isempty(u)
    out = u;
elseif isfi(u) && isfloat(u)
    % Call CORDICSQRT with the equivalent builtin floating-point type
    % and then cast builtin results to FI Double/Single outputs.
    out_flt = cordicsqrt(storedInteger(u), varargin{:});
    out     = cast(out_flt, 'like', u);
elseif isinteger(u)
    % Builtin MATLAB integer (treat as FI)
    out = cordicsqrt(fi(u), varargin{:});
else
    % Compute default number of iterations constant
    if isa(u, 'double')
        numItersDefault = 52;
    elseif isa(u, 'single')
        numItersDefault = 23;
    elseif isfi(u)
        uFPNT   = numerictype(u);
        inputWL = uFPNT.WordLength;
        numItersDefault = inputWL - 1;
    else
        error(message('fixed:fi:inputsMustBeIntOrFixPtBPSOrSDBPS'));
    end

    % Get actual number of iterations and doOutScaling to use
    [numIters_dbl, doOutScaling] = ...
        checkAndParseVarargin(numItersDefault, varargin{:});

    % Pre-compute constant gain value (based on the TOTAL number
    % of iterations, INCLUDING the repeated 3*k + 1 iterations)
    An_hp_dbl = prod(sqrt(1 - 2.^(-2*(1:(numIters_dbl)))));
    k = 4;
    while k <= numIters_dbl
        An_hp_dbl = An_hp_dbl * sqrt(1 - 2.^(-2*k));
        k = 3*k + 1;
    end

    if isa(u, 'double') || isa(u, 'single') || (isfi(u) && isfloat(u))
        % Floating-point processing
        out = localFloatingPointCORDICSQRT( ...
            u, numIters_dbl, doOutScaling, An_hp_dbl);
    else
        % Fixed-point processing
        if (inputWL > 128)
            error(message('fixed:fi:maxWordLengthExceeded', inputWL, 128));
        end
        out = localFixedPointCORDICSQRT( ...
            u, numIters_dbl, doOutScaling, An_hp_dbl, ...
            u.SignednessBool, u.WordLength, u.FractionLength);
    end
end

out = removefimath(out);

end % function


% =========================================================================
function [numIters_dbl, doOutScaling] = ...
    checkAndParseVarargin(numItersDefault, varargin)

if nargin > 1
    % MATLAB simulation checking and setting
    if ischar(varargin{1})
        % Get 'Scale output values by inverse CORDIC gain' flag
        doOutScaling = checkAndParsePVPairsSim(varargin);
        numIters_dbl = numItersDefault;
    else
        % Number of Iterations specified
        numIters_dbl = fixed.internal.cordic_check_and_parse_niters(...
            varargin{1}, 'cordicsqrt'); % no limits on numIters_dbl
        
        if (nargin > 2)
            % Get 'Scale output values by inverse CORDIC gain' flag
            doOutScaling = checkAndParsePVPairsSim(varargin(2:end));
        else
            doOutScaling = true;
        end
    end
    
    % We allow specified niters values of [], Inf
    if isempty(numIters_dbl) || ~isfinite(numIters_dbl)
        numIters_dbl = numItersDefault;
    end
else
    % No optional arguments specified
    numIters_dbl = numItersDefault; % use default
    doOutScaling = true;            % use default
end

end % function


% =========================================================================
function out = localFloatingPointCORDICSQRT( ...
    u, numIters_dbl, doOutScaling, An_hp_dbl)

out = zeros(size(u), 'like', u);
isBuiltinDblSgl = ~isfi(u);

% --------------------------------------------------------------
% Floating-point processing (e.g. for Data Type Override) always
% uses input/output normlization on a value-by-value basis.
% --------------------------------------------------------------
for idx = 1:numel(u)
    uInput = u(idx);
    if (uInput <= 0)
        out(idx) = 0;
    elseif isfinite(uInput)
        % Floating-point: normBitsVal varies for each input value.
        % Normalize each value into the range [0.5, 2) for CORDIC.
        if isBuiltinDblSgl
            [uNorm, normBitsVal] = log2(uInput); % Double/Single
        else
            [uNorm, normBitsVal] = log2(double(uInput)); % FI Dbl/Sgl
        end
        normBitsDivTwo = normBitsVal/2;
        denormPow2Bits = floor(normBitsVal/2);
        isodd = (denormPow2Bits ~= normBitsDivTwo);
        if isodd
            uNorm = uNorm .* 2;
        end
        
        % Compute CORDICSQRT using normalized range
        % then denormalize back into correct range
        xNrm     = localCORDICSQRT(uNorm, numIters_dbl);
        out(idx) = pow2(xNrm, denormPow2Bits);
    else
        % Non-finite (nan, inf) value
        out(idx) = uInput;
    end
end

if doOutScaling
    % Scale ALL results by inverse of CORDIC gain constant
    out(:) = out .* cast((1/An_hp_dbl),'like',u);
end

end % function


% =========================================================================
function out = localFixedPointCORDICSQRT(u, ...
    numIters_dbl, doOutScaling, An_hp_dbl, ...
    inputSB, inputWL, inputFL)

% Pre-allocate type-specific outputs, temp vars, constants, etc.
% Output result type uses input signedness and word length along
% with best precision fraction length for SQRT(inputMaxRange).
% It is independent of the internal, intermediate CORDIC types.
inputRangeVect = double(range(u));
inputMaxRange  = inputRangeVect(2);
outputMaxRange = sqrt(inputMaxRange);
maxOutputNT    = numerictype(fi(outputMaxRange, inputSB, inputWL));
outFL          = maxOutputNT.FractionLength;

if isequal(u.DataType,'ScaledDouble')
    % Get results using builtin double
    out_dbl = cordicsqrt(double(u), numIters_dbl, ...
        'ScaleOutput', doOutScaling);

    % Cast builtin double results to ScaledDouble.
    % Note: cannot set 'DataType' after construction.
    tmp = fi(zeros(size(u)), inputSB, inputWL, outFL);
    out = fi(tmp, 'DataType', 'ScaledDouble');
    out(:) = out_dbl;
else
    out = fi(zeros(size(u)), inputSB, inputWL, outFL);

    % Temporary variable for next input sample prior to normalization, etc.
    if (inputFL < 4)
        % Inputs need a minimum FractionLength to produce reasonable results.
        % Increase input precision in uTemp variable and grow extra WL bits.
        newWL = inputWL + 4 - inputFL;
        uTmpT = numerictype(inputSB, newWL, 4);
        uTemp = fi(0, uTmpT);
    else
        % Keep input precision as it is for uTemp var
        newWL = inputWL;
        uTemp = fi(0, numerictype(u));
    end
    
    % X-Y : Worst-case normalized X-Y sum range between [0, 4.25]
    [xyWL, xyFL] = localGetXYWordLenFracLen(newWL, inputSB);
    xyNT = numerictype(1, xyWL, xyFL);
    xyFm = fimath( ...
        'RoundingMethod',    'Floor', ...
        'OverflowAction',    'Wrap', ...
        'ProductMode',       'FullPrecision', ...
        'SumMode',           'SpecifyPrecision', ...
        'SumWordLength',     xyWL, ...
        'SumFractionLength', xyFL, ...
        'CastBeforeSum',     true);

    % Initialize NORMALIZED value temp variable
    v = fi(0, xyNT, xyFm);

    % Constrain number of iterations to the X-Y sum word length.
    % There is no reason to go beyond that word length, since
    % the X-Y sum values will be right shifted to zeros and
    % have no impact on the final result. Also prevents error.
    numItersValue = min(xyWL, numIters_dbl);

    % Inverse of CORDIC gain constant, using signed type with best precision
    % fraction length (typical IGC value is ~ 1.2144775390625, i.e., the
    % fraction length is WL-2 for this best precision, signed constant).
    igc = fi(1/An_hp_dbl, true, xyWL, (xyWL-2));

    % For simplicity, handling both SIGNED and UNSIGNED inputs
    for idx = 1:numel(u)
        uTemp(1) = u(idx); % Get next input sample (cast to uTemp var)
        
        % Compute CORDICSQRT using normalized range, i.e., [0.5, 2)
        % with even normBitsVal power-of-two, then denormalize back
        % into correct range using normBitsVal/2 power-of-two factor.
        % The denormalization is implemented using binary point shift.
        if uTemp <= 0
            out(idx) = 0;
        else
            [v(1), denormPow2Bits] = localNormalizeInput(uTemp, xyNT, xyFm);
            
            xNrm   = localCORDICSQRT(v, numItersValue);
            rsltFL = xNrm.FractionLength - denormPow2Bits;
            rsltNT = numerictype(false, xNrm.WordLength, rsltFL);
            result = reinterpretcast(xNrm, rsltNT);
            
            if doOutScaling
                % Scale output by inverse of CORDIC gain constant
                out(idx) = result .* igc;
            else
                out(idx) = result;
            end
        end
    end
end

end % function


% =========================================================================
function [uNorm, denormPow2Bits] = localNormalizeInput(uInput, xyNT, xyFm)

uNorm = fi(0, xyNT, xyFm);

[uNorm(1), normBitsVal] = fxpFREXP(uInput);

denormPow2Bits = bitsra(normBitsVal, 1);

if (bitsll(denormPow2Bits, 1) ~= normBitsVal)
    uNorm = bitsll(uNorm,1); % multiply by 2 for ODD normBitsVal
end

end % function


% =========================================================================
function [y, r] = fxpFREXP(u)
% fxpFREXP(u): Range normalization
%
% This function assumes:
%
%   1) u is a POSITIVE-valued
%   2) u is a FI fixed-point binary point scaled type
%   3) 2 < u.WordLength <= 128
%
% *** The CALLER must check for this before calling fxpFREXP ***

WL = u.WordLength;
v  = reinterpretcast(u, numerictype(false, WL, 0));

if WL > 64
    % Assuming 64 < WL <= 128 here

    % NOTE: (2^64 - 1) not representable in a double with 52-bit mantissa
    r  = bitsll(int16(v > fi([],false,WL,0,'hex','ffffffffffffffff')), 6);
    v  = bitsra(v, r);

    sh = bitsll(int16(v > (2^32 - 1)), 5);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > (2^16 - 1)), 4);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^8 - 1)), 3);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^4 - 1)), 2);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^2 - 1)), 1);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);
    
elseif WL > 32
    % Assuming 32 < WL <= 64 here
    r  = bitsll(int16(v > (2^32 - 1)), 5);
    v  = bitsra(v, r);

    sh = bitsll(int16(v > (2^16 - 1)), 4);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^8 - 1)), 3);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^4 - 1)), 2);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^2 - 1)), 1);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);
    
elseif WL > 16
    % Assuming 16 < WL <= 32 here
    r  = bitsll(int16(v > (2^16 - 1)), 4);
    v  = bitsra(v, r);

    sh = bitsll(int16(v > ( 2^8 - 1)), 3);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^4 - 1)), 2);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^2 - 1)), 1);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);
    
elseif WL > 8
    % Assuming 8 < WL <= 16 here
    r  = bitsll(int16(v > ( 2^8 - 1)), 3);
    v  = bitsra(v, r);

    sh = bitsll(int16(v > ( 2^4 - 1)), 2);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);

    sh = bitsll(int16(v > ( 2^2 - 1)), 1);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);
    
else
    % Assuming 4 < WL <= 8 here
    r  = bitsll(int16(v > ( 2^4 - 1)), 2);
    v  = bitsra(v, r);

    sh = bitsll(int16(v > ( 2^2 - 1)), 1);
    v  = bitsra(v, sh);
    r  = bitor( r, sh);
end

r = bitor( r, int16(bitsra(v,1)) ) + 1;  % plus one for ceiling
r = r - cast(u.FractionLength,'like',r); % signed integer value

% Need to temporarily grow bits prior to right or left shifts.
% Minimum number of WL bits to grow is R. However word length
% needs to remain constant for code generation (and sim must
% match code generation) so use WL + WL for temporary variable.
if r >= cast(0,'like',r)
    % R is NON-NEGATIVE -> RIGHT SHIFT to smaller range
    uTmp = fi(u, false, (WL + WL), (WL + u.FractionLength)); % avoid round
    y    = fi(bitsra(uTmp, r), false, WL, WL); % Downcast back to WL
else
    % R is NEGATIVE (input is a small fractional value < 0.5)
    uTmp = fi(u, false, (WL + WL), u.FractionLength);
    y    = fi(bitsll(uTmp, -r), false, WL, WL); % Downcast back to WL
end

end % function


% =========================================================================
function x = localCORDICSQRT(v,n)

% Initialize and run CORDIC kernel for N iterations

x = v + cast(0.25, 'like', v); % v + 0.25 in same data type
y = v - cast(0.25, 'like', v); % v - 0.25 in same data type

k = 4; % Used for the repeated (3*k + 1) iteration steps

for idx = 1:n
    xtmp = bitsra(x, idx); % multiply by 2^(-idx)
    ytmp = bitsra(y, idx); % multiply by 2^(-idx)
    if y < 0
        x(:) = x + ytmp;
        y(:) = y + xtmp;
    else
        x(:) = x - ytmp;
        y(:) = y - xtmp;
    end
    
    if idx==k
        xtmp = bitsra(x, idx); % multiply by 2^(-idx)
        ytmp = bitsra(y, idx); % multiply by 2^(-idx)
        if y < 0
            x(:) = x + ytmp;
            y(:) = y + xtmp;
        else
            x(:) = x - ytmp;
            y(:) = y - xtmp;
        end
        k = 3*k + 1;
    end
end % idx loop

end % function


% =========================================================================
function [xyWL, xyFL] = localGetXYWordLenFracLen(inputWL, inputSB)
% Do not throw away LSBs after normalization (grow extra bits).
% Also may need to account for one extra bit for possible
% unsigned-to-signed input casts. Also need to handle maximum range
% using SIGNED arithmetic, using a minimum 8-bit WL for the X-Y sums
% (i.e., to handle worst case sum value 4.25, we need 4 extra bits),
% and a maximum of 128-bit WL for the X-Y sums (max alg supported WL).

intBits = 4; % Extra bits to handle max sum value
xyWL = min(max(8, inputWL + intBits + double(~inputSB)), 128);
xyFL = xyWL - intBits; % for X-Y in range [0, 4.25]

end % function


% =========================================================================
function doOutScaling = checkAndParsePVPairsSim(pvPairArgs)
% There should be only ONE PV Pair {'ScaleOutput', doOutScaling}
p = inputParser;
p.addParamValue('ScaleOutput', true, @(x)(isscalar(x) && (islogical(x) || (isnumeric(x) && isreal(x) && isfinite(x)))));
p.FunctionName = 'cordicsqrt';
p.parse(pvPairArgs{:});
doOutScaling = logical(pvPairArgs{2});

end % function
