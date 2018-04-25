function [y, delta] = polyval(p,x,S,mu)
%POLYVAL Evaluate polynomial.
%   Y = POLYVAL(P,X)
%   Y = POLYVAL(P,X,[],MU)
%   [Y,DELTA] = POLYVAL(P,X,S)
%   [Y,DELTA] = POLYVAL(P,X,S,MU)
%
%   Limitations:
%   If X is a tall array it must be a column vector.
%
%   See also POLYVAL, POLYFIT, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% Check P is a vector. Note that X does not have to be tall - it is
% OK to fit a polynomial to tall data then use it for small data (i.e. P is
% tall). Neither X nor P should be sparse.
x = full(x);
p = full(p);
p = tall.validateVectorOrEmpty(p, 'MATLAB:polyval:InvalidP');

% Maybe normalize the input
if nargin == 4
    if istall(x)
        x = elementfun(@(x,m) (x - m(1))./m(2), x, matlab.bigdata.internal.broadcast(mu));
    elseif istall(mu)
        x2 = clientfun(@(x,m) (x - m(1))./m(2), x, mu);
        x2.Adaptor = setKnownSize(x2.Adaptor, size(x));
        x = x2;
    else
        % Neither x nor mu is tall
        x = (x - mu(1))./mu(2);
    end
end

% Use Horner's method on each element of x
if istall(x)
    y = elementfun( @iHorner, x, matlab.bigdata.internal.broadcast(p) );
else
    % X would have been tall if either X or MU was tall, so to get here P
    % must be tall.
    assert(istall(p))
    % If only P is tall, Y needs to be deferred but is small.
    y = clientfun( @iHorner, x, p );
    y.Adaptor = setKnownSize(y.Adaptor, size(x));
end

% Maybe calculate confidence bound
if nargout > 1
    if nargin<3 || (~istall(S) && isempty(S))
        error(message('MATLAB:polyval:RequiresS'));
    end
    
    if isstruct(S)
        R = S.R;
        df = S.df;
        normr = S.normr;
    else
        % Use output matrix from previous versions of polyfit. Since
        % tall/polyfit doesn't produce matrix S, this must have come from
        % the old host POLYFIT and S will be local.
        tall.checkNotTall(mfilename, 2, S);
        [ms,ns] = size(S);
        if (ms ~= ns+2)
            error(message('MATLAB:polyval:SizeS'));
        end
        R = S(1:ns,1:ns);
        df = S(ns+1,1);
        normr = S(ns+2,1);
    end
    
    % Construct Vandermonde matrix for the new X.
    V = iVander(x,length(p));
    
    % R, df, normr are allowed to be tall arrays, but are all small. We can
    % therefore broadcast R safely.
    E = slicefun(@mrdivide, V, matlab.bigdata.internal.broadcast(R));
    e = sqrt(1+sum(E.*E,2));
    
    delta = clientfun( @iCalculateDelta, e, df, normr, size(x) );
    % Delta is always same size as x
    if istall(x)
        delta.Adaptor = copySizeInformation(delta.Adaptor, x.Adaptor);
    else
        delta.Adaptor = setKnownSize(delta.Adaptor, size(x));
    end
end

end

function V = iVander(x,n)
% Construct Vandermonde matrix.
if istall(x)
    % Since we need x(:), x had better be a column vector
    x = tall.validateColumn(x, 'MATLAB:bigdata:array:PolyvalInputMustBeColumn');
    V = slicefun(@iVanderFcn, x,  matlab.bigdata.internal.broadcast(n));
else
    % N was tall
    V = clientfun(@iVanderFcn, x(:), n);
    V.Adaptor = setTallSize(V.Adaptor, numel(x));
end
end

function V = iVanderFcn(x,n)
% Construct one chunk of a Vandermonde matrix
V = repmat(x(:,1), 1, n);
V(:, n) = 1;
V = cumprod(V, 2, 'reverse');
end


function y = iHorner(x, p)
% Apply Horner's method to calculate the value of polynomial p at x.
if isempty(p)
    y = zeros(size(x), 'like', x);
    return
end
% We have to be careful not to multiply the first term by zero to avoid
% turning infinities into NaN.
y = p(1).*ones(size(x), 'like', x);
for ii=2:numel(p)
    y = x .* y + p(ii);
end
end


function delta = iCalculateDelta(e, df, normr, sz)
% Helper to do deferred calculation of delta. Inside this function, all
% arrays are now evaluated.
if df == 0
    warning(message('MATLAB:polyval:ZeroDOF'));
    delta = inf(size(e));
else
    delta = normr./sqrt(df).*e;
end
delta = reshape(delta, sz);
end
