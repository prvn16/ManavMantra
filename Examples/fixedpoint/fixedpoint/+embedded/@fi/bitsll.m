function y = bitsll(x,kin)
%BITSLL Shift Left Logical
%
% SYNTAX
%   Y = BITSLL(A, K)
%
% DESCRIPTION
%   BITSLL performs a logical left shift by K bits on input operand A.
%   Input A can be any numeric type, including double, single, integer,
%   or fixed-point. K may be any FI type or any builtin numeric type.
%   K must be a scalar, integer-valued, and greater than or equal to zero.
%
%   BITSLL operates on both signed and unsigned inputs, shifting zeros
%   into the positions of bits that it shifts left.
%
%   There is no overflow/underflow checking. FIMATH properties are ignored.
%   The output has the same numeric type and fimath properties as input A.
%
%   See also BITSLL, BITSRL, BITSRA, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSRL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2016 The MathWorks, Inc.

narginchk(2,2);

if ~(isnumeric(kin) && isreal(kin))
    error(message('fixed:bitsxx:invalidShiftVal','BITSLL'));
end

if ~isa(kin,'double')
    % This helps avoid extra checks below for the case of
    % x as a builtin (and kin as a FI), for example.
    % This call handles various combinations for x and kin.
    y = bitsll(x, double(kin));
    return;
end

if ~isscalar(kin) 
    error(message('fixed:bitsxx:invalidShiftVal','BITSLL'));
end

if ~isequal(floor(kin), kin) || (kin < 0)
    error(message('fixed:bitsxx:invalidShiftVal','BITSLL'));
end

if isequal(kin, 0)
    y = x;
else
    nt = numerictype(x);
    wl = nt.WordLength;
    
    if (wl == 1)
        error(message('fixed:fi:notDefinedForOneBitFi',mfilename));
    end
    
    if isfixed(x)
        % do shift without saturation or rounding
        a = x;
        a.RoundMode = 'floor';
        a.OverflowMode = 'wrap';
        y = bitshift(a, kin);
    else
        % x is a (real or complex) floating-point or scaled-double FI
        % Do the arithmetic in double and then cast back.
        % Apply the bit shift to the stored integer part, then scale by slope and add bias back in.
        if isscaleddouble(x)
            y_dbl = (double(x)-x.Bias)./x.Slope .* pow2(double(kin)) .* x.Slope + x.Bias;
        else
            y_dbl = double(x) .* pow2(double(kin));
        end

        
        % Preserve the numeric type and fimath of x for output
        y = embedded.fi(y_dbl, nt, fimath(x));

        if isscaleddouble(x)
            P = fipref;
            if ~strcmpi(P.LoggingMode, 'off')
                % Re-run the BITSLL operation on fixed-point
                % type to report possible overflow/underflow
                nt.DataType = 'Fixed';
                xfp = embedded.fi(double(x), nt, fimath(x));
                yfp = bitsll(xfp, kin); %#ok
            end
        end
    end
    
    % restore fimath
    if (isfimathlocal(x))
        y.fimath = fimath(x);
    else
        y.fimathislocal = false;
    end
end

% LocalWords:  invalidShiftVal
