function isp = isprime(X)
%ISPRIME True for prime numbers.
%   ISPRIME(X) is 1 for the elements of X that are prime, 0 otherwise.
%
%   Class support for input X:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also FACTOR, PRIMES.

%   Copyright 1984-2012 The MathWorks, Inc. 

isp = false(size(X));

if ~isempty(X)  
    X = X(:);
    if ~isreal(X) || any(X < 0) || any(floor(X) ~= X) || ...
            any(isinf(X))
        error(message('MATLAB:isprime:InputNotPosInt'));
    end
    
    n = max(X);
    if isinteger(X) || n <= flintmax(class(X))
        if (isa(X,'uint64') || isa(X,'int64')) && n > flintmax
            p = primes(2.^(nextpow2(n)/2));
        else
            p = primes(cast(sqrt(double(n)),class(X)));
        end
        for k = 1:numel(isp)
            Xk = X(k);
            isp(k) = (Xk>1) && all(rem(Xk, p(p<Xk)));
        end
    else
        fm = flintmax(class(X));
        p = primes(sqrt(fm));
        for k = 1:numel(isp)
            Xk = X(k);
            isp(k) = (Xk<fm) && (Xk>1) && all(rem(Xk, p(p<Xk)));
        end
    end
end
