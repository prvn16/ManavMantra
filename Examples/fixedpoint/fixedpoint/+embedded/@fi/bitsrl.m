function y = bitsrl(x,kin)
%BITSRL Shift Right Logical.
%
% SYNTAX
%   Y = BITSRL(A, K)
%
% DESCRIPTION
%   BITSRL performs a logical right shift by K bits on input operand A.
%   The input operand A must be integer or fixed-point. K may be any FI type
%   or any builtin numeric type. K must be a scalar, integer-valued, and
%   greater than or equal to zero.
%
%   BITSRL operates on both signed and unsigned inputs, shifting zeros into
%   the positions of bits that it shifts right (regardless of the sign of A).
%
%   There is no overflow/underflow checking. FIMATH properties are ignored.
%   The output has the same numeric type and fimath properties as input A.
%
%   See also BITSRL, BITSRA, BITSLL, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSLL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(2,2);

if ~(isnumeric(kin) && isreal(kin))
    error(message('fixed:bitsxx:invalidShiftVal','BITSRL'));
end

if ~isa(kin,'double')
    % This helps avoid extra checks below for the case of
    % x as a builtin (and kin as a FI), for example.
    % This call handles various combinations for x and kin.
    y = bitsrl(x, double(kin));
    return;
end

if ~isscalar(kin)
    error(message('fixed:bitsxx:invalidShiftVal','BITSRL'));
end

if ~isequal(floor(kin), kin) || (kin < 0)
    error(message('fixed:bitsxx:invalidShiftVal','BITSRL'));
end

if isequal(kin, 0)
    y = x;
else
    fm = fimath(x);
    nt = numerictype(x);
    wl = nt.WordLength;
    
    if (wl == 1)
        error(message('fixed:fi:notDefinedForOneBitFi',mfilename));
    end
    
    if isscaleddouble(x)
        % Recursion
        nt.DataType = 'Fixed';
        xfp = embedded.fi(double(x), nt, fm);
        yfp = bitsrl(xfp, kin);
        y   = embedded.fi(double(yfp), numerictype(x), fm);
        
    elseif isfixed(x)
        if (kin >= wl)
            % All bits are shifted out for each input
            if isreal(x)
                y = fi(zeros(size(x)), nt); % scalar expand and cast
            else
                y = fi(complex(zeros(size(x))), nt); % expand/cast
            end
        else
            % do shift without saturation or rounding
            a = x;
            a.RoundMode = 'floor';
            a.OverflowMode = 'wrap';
            y = bitshift(a, -kin);

            % fill in msbs with zeros
            if isreal(y)
                for ii=0:kin-1
                    y = bitset(y, wl-ii, 0);
                end
            else
                yr = real(y);
                yi = imag(y);
                for ii=0:kin-1
                    yr = bitset(yr, wl-ii, 0);
                end
                for ii=0:kin-1
                    yi = bitset(yi, wl-ii, 0);
                end
                y = complex(yr,yi);
            end
        end
    else
        % non fi-fixed-point not supported
        dt = x.DataType;
        error(message('fixed:fi:unsupportedDataType',dt));
    end
    
    % restore fimath
    if (isfimathlocal(x))
        y.fimath = fm;
    else
        y.fimathislocal = false;
    end
end

% LocalWords:  invalidShiftVal msbs
