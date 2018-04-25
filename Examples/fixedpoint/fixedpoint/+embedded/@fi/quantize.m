function y = quantize(x, varargin)
%QUANTIZE(X, ...) Quantize fixed-point numbers.
%   Y = QUANTIZE(X) quantizes the input X values to the default
%   numerictype(true,16,15), using the default RoundingMethod 'Floor' and
%   default OverflowAction 'Wrap'. The input X must be a FI object or
%   builtin integer type.
%
%   Y = QUANTIZE(X,NT) quantizes the input X values to numerictype NT.
%
%   Y = QUANTIZE(X,NT,RM) quantizes the input X values to numerictype NT
%   using RoundingMethod RM.
%
%   Y = QUANTIZE(X,NT,RM,OA) quantizes the input X values to numerictype NT
%   using RoundingMethod RM and OverflowAction OA.
%
%   Y = QUANTIZE(X,S) quantizes the input X values to a binary point scaled
%   fixed-point type defined by NUMERICTYPE(S,16,15), using the specified
%   sign S, default word length 16, default fraction length 15, default
%   RoundingMethod 'Floor', and default OverflowAction 'Wrap'.
%
%   Y = QUANTIZE(X,S,WL) quantizes the input X values to a binary point
%   scaled fixed-point type defined by NUMERICTYPE(S,WL,WL-1), using the
%   specified sign S and word length WL.
%
%   Y = QUANTIZE(X,S,WL,FL) quantizes the input X values to a binary point
%   scaled fixed-point type defined by NUMERICTYPE(S,WL,FL), using the
%   specified sign S, word length WL, and fraction length FL.
%
%   Y = QUANTIZE(X,S,WL,FL,RM) quantizes the input X values to a binary
%   point scaled fixed-point type defined by NUMERICTYPE(S,WL,FL) using
%   the specified sign S, word length WL, fraction length FL, and
%   RoundingMethod RM.
%
%   Y = QUANTIZE(X,S,WL,FL,RM,OA) quantizes the input X values to a binary
%   point scaled fixed-point type defined by NUMERICTYPE(S,WL,FL) using
%   the specified sign S, word length WL, fraction length FL,
%   RoundingMethod RM, and OverflowAction OA.
%
%   Examples:
%
%     % Create some numerictype objects
%     ntBP = numerictype(1,8,4); % Binary point scaled
%     ntSB = numerictype('Scaling', 'SlopeBias', ...
%     'SlopeAdjustmentFactor', 1.8, 'Bias', 1, 'FixedExponent', -12);
%
%     % Quantize fixed-point binary point scaled data
%     x_BP = fi(pi);
%     yBP1 = quantize(x_BP, ntBP); % Quantize to binary point scaled type
%     ySB1 = quantize(x_BP, ntSB); % Quantize to slope-bias scaled type
%
%     % Quantize fixed-point slope-bias scaled data
%     x_SB = fi(rand(5,3), numerictype('Scaling', 'SlopeBias', 'Bias', -0.125));
%     yBP2 = quantize(x_SB, ntBP, 'Nearest', 'Saturate'); % Quantize to ntBP
%     ySB2 = quantize(x_SB, ntSB, 'Ceiling', 'Wrap');     % Quantize to ntSB
%
%     % Quantize builtin integer data
%     xInt = int8(-128:127);
%     yBP3 = quantize(xInt, ntBP, 'Zero');          % Quantize to ntBP
%     ySB3 = quantize(xInt, ntSB, 'Round', 'Wrap'); % Quantize to ntSB
%
%   See also FI, FIMATH, FIXED.QUANTIZER, NUMERICTYPE

% Copyright 2011-2017 The MathWorks, Inc.

% -------------------------------------------------------------------------
% NOTE: This implementation is a METHOD of FI (i.e., assumes input x is FI)
% -------------------------------------------------------------------------

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if isempty(coder.target)
    narginchk(1,6); % Called for MATLAB simulation only
elseif nargin < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargin > 6
    error(message('MATLAB:narginchk:tooManyInputs'));
end

if isfloat(x)
    % FI double/single floating-point input X
    y = x;
    
else
    % FI fixed-point or scaled double input X
    
    % Assign default argument values
    wl = 16;      % word len
    fl = 15;      % frac len
    rm = 'floor'; % rounding
    om = 'wrap';  % overflow

    if nargin > 1
        % At least one varargin is provided
        firstVarArg = varargin{1};
        if isnumerictype(firstVarArg)
            % Y = QUANTIZE(X,NT,RM,OA)
            if nargin > 4
                error(message('MATLAB:narginchk:tooManyInputs'));
            end
        
            Ty = firstVarArg;
            
            if isscaleddouble(x)
                Ty.DataType = x.DataType;
            elseif ~isfixed(x)
                % e.g., FI Boolean
                error(message('fixed:fi:unsupportedDataType',x.DataType));
            end
            
            if nargin > 2
                rm = varargin{2};
                if nargin > 3
                    om = varargin{3};
                end
            end
        elseif isscalar(firstVarArg) && ~isempty(firstVarArg) && isreal(firstVarArg) && (islogical(firstVarArg) || isnumeric(firstVarArg))
            % Y = QUANTIZE(X,S,WL,FL,RM,OA)
            if nargin > 3
                if ~(isnumeric(varargin{2}) && isscalar(varargin{2}))
                    error(message('fixed:numerictype:invalidWLInputArg'));
                end
                if ~(isnumeric(varargin{3}) && isscalar(varargin{3}))
                    error(message('fixed:numerictype:invalidFLInputArg'));
                end
                wl = double(varargin{2});
                fl = double(varargin{3});
            elseif nargin > 2
                if ~(isnumeric(varargin{2}) && isscalar(varargin{2}))
                    error(message('fixed:numerictype:invalidWLInputArg'));
                end
                wl = double(varargin{2});
                fl = wl - 1;
            end
            
            if isfixed(x)
                Ty = numerictype(firstVarArg, wl, fl);
            elseif isscaleddouble(x)
                Ty = numerictype(...
                    'DataType',       x.DataType, ...
                    'Signed',         firstVarArg, ...
                    'WordLength',     wl, ...
                    'FractionLength', fl);
            else
                % e.g., FI Boolean
                error(message('fixed:fi:unsupportedDataType',x.DataType));
            end
            
            if nargin > 4
                rm = varargin{4};
                if nargin > 5
                    om = varargin{5};
                end
            end
        else
            error(message('fixed:numerictype:invalidInputArg',firstVarArg));
        end
    else
        % Use all defaults (no varargin provided)
        Ty = numerictype(1, wl, fl);
    end

    % FI fixed-point or scaled double output
    y = embedded.fi.quantize_fi_private(x,Ty,rm,om);
end
