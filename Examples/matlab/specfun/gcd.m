function [g,c,d] = gcd(a,b)
%GCD    Greatest common divisor.
%   G = GCD(A,B) is the greatest common divisor of corresponding elements
%   of A and B.  The arrays A and B must contain integer values and must be
%   the same size (or either can be scalar). GCD(0,0) is 0 by convention;
%   all other GCDs are positive integers.
%
%   [G,C,D] = GCD(A,B) also returns C and D so that G = A.*C + B.*D.
%   These are useful for solving Diophantine equations and computing
%   Hermite transformations.
%
%   Class support for inputs A,B:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also LCM.

%   References:
%   Knuth, Donald, The Art of Computer Programming, Vol. 2, Addison-Wesley:
%      Reading MA, 1973. Section 4.5.2, Algorithms A and X.
%
%   Thanks to John Gilbert for the original version
%   Copyright 1984-2017 The MathWorks, Inc.

if ~isequal(size(a),size(b)) && ~isscalar(a) && ~isscalar(b)
    error(message('MATLAB:gcd:InputSizeMismatch'))
end

if ~isreal(a) || ~isequal(round(a),a) || any(isinf(a(:))) || ...
   ~isreal(b) || ~isequal(round(b),b) || any(isinf(b(:)))
    error(message('MATLAB:gcd:NonIntInputs'))
end

if ~isscalar(a)
    siz = size(a);
else
    siz = size(b);
end
a = a(:); 
b = b(:);

if isinteger(a)
    if ~(strcmp(class(a),class(b)) || (isa(b,'double') && isscalar(b)))
        error(message('MATLAB:gcd:mixedIntegerTypes'))
    end
    classin = class(a);
    if isa(b,'double') && (b > intmax(classin) || b < intmin(classin))
        error(message('MATLAB:gcd:outOfRange'));
    end
    inttype = true;
elseif isinteger(b)
    if ~(isa(a,'double') && isscalar(a))
        error(message('MATLAB:gcd:mixedIntegerTypes'))
    end
    classin = class(b);
    if a > intmax(classin) || a < intmin(classin)
        error(message('MATLAB:gcd:outOfRange'));
    end
    inttype = true;
else
    classin = superiorfloat(a,b);
    largestFlint = flintmax(classin);
    if any(abs(a) > largestFlint) || any(abs(b) > largestFlint)
        warning(message('MATLAB:gcd:largestFlint'));
    end
    inttype = false;
end

if nargout <= 1
    % intmin in signed integers requires special handling
    iminIndex = [];
    if inttype
        imin = intmin(classin);
        if imin < 0
            iminIndex = xor(a == imin, b == imin);
        end
    end
    u = max(abs(a),abs(b));
    v = min(abs(a),abs(b));
    u(iminIndex) = u(iminIndex)/2;
    vnz = v>0;
    while any(vnz)
        t = rem(u,v);
        u(vnz) = v(vnz);
        v(vnz) = t(vnz);
        vnz = v>0;
    end
    g = reshape(u,siz);
else
    if inttype
        if intmin(classin) == 0    % unsigned integers not supported
            error(message('MATLAB:gcd:unsupportedType'));
        end
    end
    len = prod(siz);
    if issparse(a) || issparse(b)
        u = spalloc(len,3,nnz(a)+len);
    else
        u = zeros(len,3,classin);
    end
    u(:,1) = 1;
    u(:,3) = a;
    if issparse(b)
        v = spalloc(len,3,nnz(b)+len);
    else
        v = zeros(len,3,classin);
    end
    v(:,2) = 1;
    v(:,3) = b;
    vnz = v(:,3)~=0;
    while any(vnz)
        if inttype
            q = idivide(u(:,3),v(:,3));
        else
            q = fix( u(:,3)./v(:,3));
        end
        t = u - v .* q;
        u(vnz,:) = v(vnz,:);
        v(vnz,:) = t(vnz,:);
        vnz = v(:,3)~=0;
    end
    
    
    g = reshape(u(:,3),siz);
    c = reshape(u(:,1),siz).*sign(g);
    d = reshape(u(:,2),siz).*sign(g);
    g = abs(g);
    % correct overflow conditions in signed integers
    if inttype
        overflow1 = reshape(a == intmin(classin) & b == -1, siz);
        overflow2 = reshape(a == -1 & b == intmin(classin), siz);
        g(overflow1 | overflow2) = 1;
        c(overflow1) = 0;
        d(overflow1) = -1;
        c(overflow2) = -1;
        d(overflow2) = 0;
    end
end
