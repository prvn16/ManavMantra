function Q = integral2(fun,xmin,xmax,ymin,ymax,varargin)
%INTEGRAL2  Numerically evaluate double integral.
%   Q = INTEGRAL2(FUN,XMIN,XMAX,YMIN,YMAX) approximates the integral of
%   FUN(X,Y) over the planar region XMIN <= X <= XMAX and YMIN(X) <= Y <=
%   YMAX(X). FUN is a function handle, YMIN and YMAX may each be a scalar
%   value or a function handle.
%
%   All input functions must accept arrays as input and operate
%   elementwise. The function Z = FUN(X,Y) must accept arrays X and Y of
%   the same size and return an array of corresponding values. The
%   functions YMIN(X) and YMAX(X) must accept arrays and return arrays of
%   the same size with corresponding values.
%
%   Q = INTEGRAL2(FUN,XMIN,XMAX,YMIN,YMAX,PARAM1,VAL1,PARAM2,VAL2,...)
%   performs the integration as above with specified values of optional
%   parameters:
%
%   'AbsTol', absolute error tolerance
%   'RelTol', relative error tolerance
%
%       INTEGRAL2 attempts to satisfy |Q - I| <= max(AbsTol,RelTol*|Q|),
%       where I denotes the exact value of the integral. Usually RelTol
%       determines the accuracy of the integration. However, if |Q| is
%       sufficiently small, AbsTol determines the accuracy of the
%       integration, instead. The default value of AbsTol is 1.e-10, and
%       the default value of RelTol is 1.e-6. Single precision integrations
%       may require larger tolerances.
%
%   'Method', integration method -- 'tiled', 'iterated', or 'auto'
%
%       See the documentation for more information on the different
%       methods. The default method is 'auto', which uses the 'iterated'
%       method if any of the limits is Inf or -Inf. Otherwise, it uses the
%       'tiled' method. The 'tiled' method requires finite limits.
%
%   Example:
%   Integrate y*sin(x)+x*cos(y) over pi <= x <= 2*pi, 0 <= y <= pi.
%   The true value of the integral is -pi^2.
%       Q = integral2(@(x,y) y.*sin(x)+x.*cos(y),pi,2*pi,0,pi)
%
%   Example:
%   Integrate 1./(sqrt(x+y).*(1+x+y).^2 over the triangle 0 <= x <= 1,
%   0 <= y <= 1-x. The integrand is infinite at (0,0). The true value of
%   the integral is pi/4 - 1/2.
%       fun = @(x,y) 1./( sqrt(x + y) .* (1 + x + y).^2 )
%
%       % In Cartesian coordinates:
%       ymax = @(x) 1 - x
%       Q = integral2(fun,0,1,0,ymax)
%
%       % In polar coordinates:
%       polarfun = @(theta,r) fun(r.*cos(theta),r.*sin(theta)).*r
%       rmax = @(theta) 1./(sin(theta) + cos(theta))
%       Q = integral2(polarfun,0,pi/2,0,rmax)
%
%   Class support for inputs XMIN, XMAX, YMIN, YMAX, and the output of FUN:
%      float: double, single
%
%   See also INTEGRAL, INTEGRAL3, TRAPZ, FUNCTION_HANDLE

%   The 'tiled' method is based on "TwoD" by Lawrence F. Shampine.
%   Ref: L.F. Shampine, "Matlab Program for Quadrature in 2D",
%   Appl. Math. Comp., 202 (2008) 266-274.

%   Copyright 2008-2013 The MathWorks, Inc.

narginchk(5,inf);
if ~(isfloat(xmin) && isscalar(xmin))
    % Example:
    % integral2(@(x,y)x+y,[0,1],1,0,1)
    error(message('MATLAB:integral2:invalidXMin'));
end
if ~(isfloat(xmax) && isscalar(xmax))
    % Example:
    % integral2(@(x,y)x+y,0,[0,1],0,1)
    error(message('MATLAB:integral2:invalidXMax'));
end
isImproper = isinf(xmin) || isinf(xmax);
if ~isa(fun,'function_handle')
    % Example:
    % integral2('x+y',0,1,0,1)
    error(message('MATLAB:integral2:invalidIntegrand'));
end
if isa(ymin,'function_handle')
    yminfun = ymin;
elseif isfloat(ymin) && isscalar(ymin)
    isImproper = isImproper || isinf(ymin);
    yminfun = @(x)ymin*ones(size(x));
else
    % Example:
    % integral2(@(x,y)x+y,0,1,[1,2],3)
    error(message('MATLAB:integral2:invalidYMin'));
end
if isa(ymax,'function_handle')
    ymaxfun = ymax;
elseif isfloat(ymax) && isscalar(ymax)
    isImproper = isImproper || isinf(ymax);
    ymaxfun = @(x)ymax*ones(size(x));
else
    % Example:
    % integral2(@(x,y)x+y,0,1,0,[1,2])
    error(message('MATLAB:integral2:invalidYMax'));
end
opstruct = integral2ParseArgs(isImproper,varargin{:});
try
    Q = integral2Calc(fun,xmin,xmax,yminfun,ymaxfun,opstruct);
catch ME
    if strcmp(ME.identifier,'MATLAB:integral:unsuccessful')
        warning(message('MATLAB:integral2:unsuccessful'));
        Q = nan(outclass(fun,xmin,xmax,yminfun,ymaxfun));
    else
        rethrow(ME);
    end
end

%--------------------------------------------------------------------------

function cls = outclass(fun,xmin,xmax,ymin,ymax)
% Determine the output class. This is used when the integration
% has already failed and we need to return the right class of NaN.
xmid = interiorPoint(xmin,xmax);
ymid = interiorPoint(ymin(xmid),ymax(xmid));
cls = class(fun(xmid,ymid)*xmid*ymid);

%--------------------------------------------------------------------------

function x = interiorPoint(a,b)
% Try to return a value between a and b.
if a == b
    x = cast(a,superiorfloat(a,b));
elseif isnan(a) || isnan(b)
    x = nan(superiorfloat(a,b));
elseif ~isfinite(a) || ~isfinite(b)
    if a > b
        % Make a <= b.
        tmp = a;
        a = b;
        b = tmp;
    end
    if isfinite(a) % b = Inf
        x = cast(a,superiorfloat(a,b));
        x = x + eps(x);
    elseif isfinite(b) % a = -Inf
        x = cast(b,superiorfloat(a,b));
        x = x - eps(x);
    else % a = -Inf, b = Inf
        x = zeros(superiorfloat(a,b));
    end
else % Both a and b are finite and a ~= b.
    x = a/2 + b/2;
end

%--------------------------------------------------------------------------
