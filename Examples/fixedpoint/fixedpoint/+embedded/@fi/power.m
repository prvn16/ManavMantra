function y = power(a,k)
%.^     FI array power.
%   Y = A.^K, and Y = POWER(A,K) compute element-by-element power. The
%   exponent K must be a positive, real-valued integer.
%
%   Refer to the MATLAB POWER reference page for more information.
%
%   The following example computes the power of a 2-dimensional array for
%   exponents 0, 1, 2 and 3.
%
%   x = fi([0 1 2; 3 4 5], 1, 32);
%   % x is a signed FI object with a 32-bit word length, and 28-bit (best
%   % precision) fraction length.
%   y0 = x.^0
%   % y0 is a FI object with the value [1 1 1; 1 1 1], a unsigned
%   % numerictype with 1-bit word length and 0 fraction length.
%   y1 = x.^1
%   % y1 is same as x
%   y2 = x.^2
%   % y2 is a FI object with the value of [0 1 4; 9 16 25], a signed
%   % numerictype with 64-bit word length, and 56-bit fraction length.
%   y3 = x.^3
%   % y3 is a FI object with the value of [0 1 8; 27 64 125], a signed
%   % numerictype with 96-bit word length and 84-bit fraction length.
%
%   See also EMBEDDED.FI/POWER, POWER
    
%   Copyright 2009-2014 The MathWorks, Inc.
    
    if ~isfi(a)
        error(message('fixed:fi:firstInputNotFi'));
    end
    
    validateInputsToStatFunctions(a,'power');
    if ~isreal(k)||~isnumeric(k)||~(isequal(k , floor(k)))||~isscalar(k)||~isfinite(k)||(k < 0)
        error(message('fixed:fi:invalidExponent','power'));
    end
    
    if ~isfloat(a)
        [errid,errwl,errmaxwl] = validate_power_output_type(a,k,false);
        if ~isempty(errid)
            error(message(errid,errwl,errmaxwl));
        end
    end
    k = double(k);
    if isfloat(a)
        % Use builtin a.^k for floating-point
        y = embedded.fi(power(double(a),k), numerictype(a), fimath(a));
    elseif (k == 0)
        % Special case a .^ 0
        tOnes = numerictype(numerictype(false,1,0),'DataType',a.DataType);
        y = embedded.fi(ones(size(a)), tOnes, fimath(a));
    elseif (k == 1)
        % Special case a .^ 1
        y = a;
    elseif (k == 2 )
        % Special case a .^ 2
        y = a .* a;
    elseif (k == 3 )
        % Special case a .^ 3
        y = a .* a .* a;
    elseif (k == 4 )
        % Special case a .^ 4
        b = a .* a;
        y = b .* b;
    elseif (  isfi(a) && strcmpi( a.ProductMode, 'FullPrecision') && strcmpi( a.SumMode, 'FullPrecision') )
        % a.^k with repeated squaring
        k = uint32(k);
        one = uint32(1);
        initialized = false;
        while k>0
            if bitand(k, one)
                % Multiply in the odd power
                if initialized
                    y = y .* a;
                else
                    y = a;
                    initialized = true;
                end
            end
            % Divide k by 2 (shift off a bit at each iteration)
            k = bitsrl(k,1);
            if k ~= 0
                % Squaring up the even powers
                a = a .* a;
            end
        end
    else
        y = a.*a;
        for pwridx = 3:1:k
            y = y.*a;
        end
    end
    % Propagate input fimath to output
    if isfi(y) && isfi(a) && isfimathlocal(a)
        y = setfimath(y, a.fimath);
    else
        y = removefimath(y);
    end
end

