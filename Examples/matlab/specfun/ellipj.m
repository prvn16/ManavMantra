function [sn,cn,dn] = ellipj(u,m,tol)
%ELLIPJ Jacobi elliptic functions.
%   [SN,CN,DN] = ELLIPJ(U,M) returns the values of the Jacobi elliptic 
%   functions Sn, Cn and Dn, evaluated for corresponding elements of 
%   argument U and parameter M.  U and M must be arrays of the same 
%   size or either can be scalar.  As currently implemented, M is 
%   limited to 0 <= M <= 1. 
%
%   [SN,CN,DN] = ELLIPJ(U,M,TOL) computes the elliptic functions to
%   the accuracy TOL instead of the default TOL = EPS.  
%
%   Some definitions of the Jacobi elliptic functions use the modulus
%   k instead of the parameter M.  They are related by M = k^2.
%
%   See also ELLIPKE.

%   Copyright 1984-2013 The MathWorks, Inc. 

%   ELLIPJ uses the method of the arithmetic-geometric mean
%   described in [1].
%
%   References:
%   [1] M. Abramowitz and I.A. Stegun, "Handbook of Mathematical
%       Functions" Dover Publications", 1965, Ch. 16-17.6.

if nargin<2
  error(message('MATLAB:ellipj:NotEnoughInputs')); 
end

classin = superiorfloat(u,m);

if nargin<3, tol = eps(classin); end


if ~isreal(u) || ~isreal(m) || ~isreal(tol)
    error(message('MATLAB:ellipj:ComplexInputs'))
end

if isscalar(m), m = m(ones(size(u))); end
if isscalar(u), u = u(ones(size(m))); end
if ~isequal(size(m),size(u)) 
  error(message('MATLAB:ellipj:InputSizeMismatch')); 
end

mmax = numel(u);

cn = zeros(size(u),classin);
sn = cn;
dn = sn;
m = m(:).';    % make a row vector
u = u(:).';

if any(m < 0) || any(m > 1), 
  error(message('MATLAB:ellipj:MOutOfRange'));
end
if ~isscalar(tol) || tol<0 || ~isfinite(tol)
  error(message('MATLAB:ellipj:NegativeTolerance'));
end

% pre-allocate space and augment if needed
chunk = 10;
a = zeros(chunk,mmax);
c = a;
b = a;
a(1,:) = ones(1,mmax);
c(1,:) = sqrt(m);
b(1,:) = sqrt(1-m);
n = zeros(1,mmax);
i = 1;
while any(abs(c(i,:)) > tol)
    i = i + 1;
    if i > size(a,1)
      a = [a; zeros(chunk,mmax)];
      b = [b; zeros(chunk,mmax)];
      c = [c; zeros(chunk,mmax)];
    end
    a(i,:) = 0.5 * (a(i-1,:) + b(i-1,:));
    b(i,:) = sqrt(a(i-1,:) .* b(i-1,:));
    c(i,:) = 0.5 * (a(i-1,:) - b(i-1,:));
    
    % test for stagnation (may happen for TOL < machine precision)
    if isequal(c(i, :), c(i-1, :))
        error(message('MATLAB:ellipj:FailedConvergence'));
    end
    
    in = find((abs(c(i,:)) <= tol) & (abs(c(i-1,:)) > tol));
    if ~isempty(in)
      [mi,ni] = size(in);
      n(in) = repmat((i-1), mi, ni);
    end
end
phin = zeros(i,mmax,classin);
phin(i,:) = (2 .^ n).*a(i,:).*u;
while i > 1
    i = i - 1;
    in = find(n >= i);
    phin(i,:) = phin(i+1,:);
    if ~isempty(in)
      phin(i,in) = 0.5 * ...
      (asin(c(i+1,in).*sin(rem(phin(i+1,in),2*pi))./a(i+1,in)) + phin(i+1,in));
    end
end
sn(:) = sin(rem(phin(1,:),2*pi));
cn(:) = cos(rem(phin(1,:),2*pi));
dn(:) = sqrt(1 - m .* (sn(:).').^2);

% special case m = 1 
m1 = find(m==1);
sn(m1) = tanh(u(m1));
cn(m1) = sech(u(m1));
dn(m1) = sech(u(m1));
% special case m = 0
dn(m==0) = 1;
