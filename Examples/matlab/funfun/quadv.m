function [Q,fcnt] = quadv(funfcn,a,b,tol,trace,varargin)
%QUADV  Vectorized QUAD.
%   Q = QUADV(FUN,A,B) approximates the integral of the complex
%   array-valued function FUN from A to B to within an error of 1.e-6 using
%   recursive adaptive Simpson quadrature. FUN is a function handle. The
%   function Y=FUN(X) should accept a scalar argument X and return an array
%   result Y, whose components are the integrands evaluated at X.
%
%   Q = QUADV(FUN,A,B,TOL) uses the absolute error tolerance TOL for all
%   the integrals instead of the default, which is 1.e-6.
%
%   Q = QUADV(FUN,A,B,TOL,TRACE) with non-zero TRACE shows the values
%   of [fcnt a b-a Q(1)] during the recursion. Use [] as a placeholder to
%   obtain the default value of TOL.
%
%   [Q,FCNT] = QUADV(...) returns the number of function evaluations.
%
%   Note: The same tolerance is used for all components, so the results
%   obtained with QUADV are usually not the same as those obtained with
%   QUAD on the individual components.
%
%   QUADV will be removed in a future release. Use INTEGRAL with the
%   'ArrayValued' option.
%
%   Example:
%   For the parameterized array-valued function myarrayfun:
%      %--------------------------%
%      function Y = myarrayfun(x,n)
%      Y = 1./((1:n)+x);
%      %--------------------------%
%   integrate using parameter value n=10 between a=0 and b=1:
%      Qv = quadv(@(x)myarrayfun(x,10),0,1);
%   The resulting array Qv has elements estimating Q(k) = log((k+1)./(k)).
%   Qv is slightly different than if computed using QUAD in a loop:
%      for k = 1:10
%         Qs(k) = quad(@(x)myscalarfun(x,k),0,1);
%      end
%   where myscalarfun is:
%      %---------------------------%
%      function y = myscalarfun(x,k)
%      y = 1./(k+x);
%      %---------------------------%
%
%   Class support for inputs A, B, and the output of FUN:
%      float: double, single
%
%   See also INTEGRAL, INTEGRAL2, INTEGRAL3, QUAD, QUADL, QUADGK, QUAD2D,
%   DBLQUAD, TRIPLEQUAD, FUNCTION_HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.

f = fcnchk(funfcn);
if nargin < 4 || isempty(tol), tol = 1.e-6; end
if nargin < 5 || isempty(trace), trace = 0; end

% Initialize with three unequal subintervals.
h = 0.13579*(b-a);
x = [a a+h a+2*h (a+b)/2 b-2*h b-h b];
for j = 1:7
    y{j} = feval(f, x(j), varargin{:}); %#ok<AGROW>
end
fcnt = 7;

% Fudge endpoints to avoid infinities.
if any(~isfinite(y{1}(:)))
    y{1} = feval(f,a+eps(superiorfloat(a,b))*(b-a),varargin{:});
    fcnt = fcnt+1;
end
if any(~isfinite(y{7}(:)))
    y{7} = feval(f,b-eps(superiorfloat(a,b))*(b-a),varargin{:});
    fcnt = fcnt+1;
end

% Call the recursive core integrator.
hmin = eps(b-a)/1024;
[Q1,fcnt,warn1] = ...
    quadstep(f,x(1),x(3),y{1},y{2},y{3},tol,trace,fcnt,hmin,varargin{:});
[Q2,fcnt,warn2] = ...
    quadstep(f,x(3),x(5),y{3},y{4},y{5},tol,trace,fcnt,hmin,varargin{:});
[Q3,fcnt,warn3] = ...
    quadstep(f,x(5),x(7),y{5},y{6},y{7},tol,trace,fcnt,hmin,varargin{:});
Q = Q1+Q2+Q3;
warn = max([warn1 warn2 warn3]);

switch warn
    case 1
        warning(message('MATLAB:quadv:MinStepSize'))
    case 2
        warning(message('MATLAB:quadv:MaxFcnCount'))
    case 3
        warning(message('MATLAB:quadv:ImproperFcnValue'))
    otherwise
        % No warning.
end

% ------------------------------------------------------------------------

function [Q,fcnt,warn] = quadstep (f,a,b,fa,fc,fb,tol,trace,fcnt,hmin,varargin)
%QUADSTEP  Recursive core routine for function QUAD.

maxfcnt = 10000;

% Evaluate integrand twice in interior of subinterval [a,b].
h = b - a;
c = (a + b)/2;
d = (a + c)/2;
e = (c + b)/2;
fd = feval(f,d,varargin{:});
fe = feval(f,e,varargin{:});
fcnt = fcnt + 2;

% Three point Simpson's rule.
Q1 = (h/6)*(fa + 4*fc + fb);

% Five point double Simpson's rule.
Q2 = (h/12)*(fa + 4*fd + 2*fc + 4*fe + fb);

% One step of Romberg extrapolation.
Q = Q2 + (Q2 - Q1)/15;

if trace
    fprintf('%8.0f %16.10f %18.8e %16.10f\n',fcnt,a,h,Q(1));
end

% Check termination criteria.
if ~all(isfinite(Q))
    % Infinite or Not-a-Number function value encountered.
    warn = 3;
    return
end
if fcnt > maxfcnt
    % Maximum function count exceeded; singularity likely.
    warn = 2;
    return
end
if norm(Q2 - Q,Inf) <= tol
    % Accuracy over this subinterval is acceptable.
    warn = 0;
    return
end
if abs(h) < hmin || c == a || c == b
    % Minimum step size reached; singularity possible.
    warn = 1;
    return
end

% Subdivide into two subintervals.
[Qac,fcnt,warnac] = quadstep(f,a,c,fa,fd,fc,tol,trace,fcnt,hmin,varargin{:});
[Qcb,fcnt,warncb] = quadstep(f,c,b,fc,fe,fb,tol,trace,fcnt,hmin,varargin{:});
Q = Qac + Qcb;
warn = max(warnac,warncb);
