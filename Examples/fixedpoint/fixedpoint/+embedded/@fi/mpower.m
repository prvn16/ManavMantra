function y = mpower(a, k)
%^      FI matrix power.
%   Y = A^K and Y=MPOWER(A,K) compute matrix power. The exponent K must 
%   be a positive, real-valued integer.
%
%   Refer to the MATLAB MPOWER reference page for more information.
%
%   The following example computes the power of a 2-dimensional square
%   matrix for exponents 0, 1, 2, 3.
%
%   x = fi([0 1; 2 4], 1, 32);
%   % x is a signed FI object with a 32-bit word length, and 28-bit (best
%   % precision) fraction length.
%   px0 = x^0
%   % px0 is a FI object with the value [1 0; 0 1], a unsigned numerictype
%   % with 1-bit word length and 0 fraction length.
%   px1 = x^1
%   % px1 is same as x
%   px2 = x^2
%   % px2 is a FI object with the value [2 4; 8 18], a signed numerictype
%   % with 65-bit word length and 56-bit fraction length.
%   px3 = x^3
%   % px3 is a FI object with the value [8 18; 36 80], a signed numerictype
%   % with 98-bit word length and 84-bit fraction length.
%
%   See also EMBEDDED.FI/MPOWER, MPOWER

%   Copyright 2009-2014 The MathWorks, Inc.

if ~isfi(a)
    error(message('fixed:fi:firstInputNotFi'));
end

validateInputsToStatFunctions(a,'mpower');
if ~isreal(k)||~isnumeric(k)||~isequal(k , floor(k))||~isscalar(k)||~isfinite(k)||(k < 0)
    error(message('fixed:fi:invalidExponent','mpower'));
end

if (ndims(a) > 2)||(~isscalar(a)&&(size(a,1)~=size(a,2))) %#ok
    error(message('MATLAB:mpower:notScalarAndSquareMatrix'));
end

if ~isfloat(a)
    [errid,errwl,errmaxwl] = validate_power_output_type(a,k,true);
    if ~isempty(errid)
        error(message(errid,uint64(errmaxwl),uint64(errwl)));
    end
end
k = double(k);
if isfloat(a)
    % Use builtin a^k for floating-point
    y = embedded.fi(mpower(double(a), k), numerictype(a), fimath(a));
elseif (k == 0)
    % Special case a ^ 0
    tEye = numerictype(numerictype(false,1,0),'DataType',a.DataType);
    y = embedded.fi(eye(size(a,1)), tEye, fimath(a));
elseif (k == 1)
    % Special case a ^ 1
    y = a;
elseif (k == 2 )
    % Special case a ^ 2
    y = a * a;
elseif (k == 3 )
    % Special case a ^ 3
    y = a * a * a;
elseif (k == 4 )
    % Special case a ^ 4
    b = a * a;
    y = b * b;
elseif (  isfi(a) && strcmpi( a.ProductMode, 'FullPrecision') && strcmpi( a.SumMode, 'FullPrecision') )
    % a^k with repeated squaring
    k = uint32(k);
    one = uint32(1);
    initialized = false;
    while k>0
        if bitand(k, one)
            % k is odd
            if initialized
                y = y * a;
            else
                y = a;
                initialized = true;
            end
        end
        k = bitsrl(k,1);
        if k ~= 0
            a = a * a;
        end
    end
else
    y = a*a;
    for pwridx = 3:1:k
        y = y*a;
    end
end
% Propagate input fimath to output
if isfi(y) && isfi(a) && isfimathlocal(a)
    y = setfimath(y, a.fimath);
else
    y = removefimath(y);
end
