function [p,S,mu] = polyfit(x,y,n)
%POLYFIT Fit polynomial to data.
%   P = POLYFIT(X,Y,N) finds the coefficients of a polynomial P(X) of
%   degree N that fits the data Y best in a least-squares sense. P is a
%   row vector of length N+1 containing the polynomial coefficients in
%   descending powers, P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X + P(N+1).
%
%   [P,S] = POLYFIT(X,Y,N) returns the polynomial coefficients P and a
%   structure S for use with POLYVAL to obtain error estimates for
%   predictions.  S contains fields for the triangular factor (R) from a QR
%   decomposition of the Vandermonde matrix of X, the degrees of freedom
%   (df), and the norm of the residuals (normr).  If the data Y are random,
%   an estimate of the covariance matrix of P is (Rinv*Rinv')*normr^2/df,
%   where Rinv is the inverse of R.
%
%   [P,S,MU] = POLYFIT(X,Y,N) finds the coefficients of a polynomial in
%   XHAT = (X-MU(1))/MU(2) where MU(1) = MEAN(X) and MU(2) = STD(X). This
%   centering and scaling transformation improves the numerical properties
%   of both the polynomial and the fitting algorithm.
%
%   Warning messages result if N is >= length(X), if X has repeated, or
%   nearly repeated, points, or if X might need centering and scaling.
%
%   Example: simple linear regression with polyfit
%
%     % Fit a polynomial p of degree 1 to the (x,y) data:
%       x = 1:50;
%       y = -0.3*x + 2*randn(1,50);
%       p = polyfit(x,y,1);
%
%     % Evaluate the fitted polynomial p and plot:
%       f = polyval(p,x);
%       plot(x,y,'o',x,f,'-')
%       legend('data','linear fit')
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also POLY, POLYVAL, ROOTS, LSCOV.

%   Copyright 1984-2017 The MathWorks, Inc.

if ~isequal(size(x),size(y))
    error(message('MATLAB:polyfit:XYSizeMismatch'))
end

x = x(:);
y = y(:);

if nargout > 2
    mu = [mean(x); std(x)];
    x = (x - mu(1))/mu(2);
end

% Construct the Vandermonde matrix V = [x.^n ... x.^2 x ones(size(x))]
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
    V(:,j) = x.*V(:,j+1);
end

% Solve least squares problem p = V\y to get polynomial coefficients p.
[Q,R] = qr(V,0);
oldws = warning('off','all');   % Turn all warnings off before solving
try
    p = R\(Q'*y);               % Same as p = V\y
catch ME
    warning(oldws);             % Restore initial warning state
    throw(ME);
end
warning(oldws);                 % Restore initial warning state

% Issue warnings.
if size(R,2) > size(R,1)
    warning(message('MATLAB:polyfit:PolyNotUnique'))
elseif warnIfLargeConditionNumber(R)
    if nargout > 2
        warning(message('MATLAB:polyfit:RepeatedPoints'));
    else
        warning(message('MATLAB:polyfit:RepeatedPointsOrRescale'));
    end
end

if nargout > 1
    r = y - V*p;
    % S is a structure containing three elements: the triangular factor
    % from a QR decomposition of the Vandermonde matrix, the degrees of
    % freedom and the norm of the residuals.
    S.R = R;
    S.df = max(0,length(y) - (n+1));
    S.normr = norm(r);
end

p = p.'; % Polynomial coefficients are row vectors by convention.

function flag = warnIfLargeConditionNumber(R)
if isa(R, 'double')
    flag = (condest(R) > 1e+10);
else
    flag = (condest(R) > 1e+05);
end
