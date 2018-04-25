function Q = integral3(FUN,xmin,xmax,ymin,ymax,zmin,zmax,varargin)
%INTEGRAL3  Numerically evaluate triple integral.
%   Q = INTEGRAL3(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX) approximates the
%   integral of FUN(X,Y,Z) over the region XMIN <= X <= XMAX, YMIN(X) <= Y
%   <= YMAX(X), and ZMIN(X,Y) <= Z <= ZMAX(X,Y). FUN is a function handle,
%   YMIN, YMAX, ZMIN, and ZMAX may each be a scalar value or a function
%   handle.
%
%   All input functions must accept arrays and operate elementwise.  The
%   function FUN(X,Y,Z) must accept arrays X, Y, and Z of the same size and
%   return an array of corresponding values. Functions YMIN(X), YMAX(X),
%   ZMIN(X,Y), and ZMAX(X,Y) must accept arrays and return arrays of the
%   same size with corresponding values.
%
%   Q = INTEGRAL3(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,PARAM1,VAL1, ...
%   PARAM2,VAL2,...) performs the integration as above with specified
%   values of optional parameters:
%
%   'AbsTol', absolute error tolerance
%   'RelTol', relative error tolerance
%
%       INTEGRAL3 attempts to satisfy |Q - I| <= max(AbsTol,RelTol*|Q|),
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
%       method if any of the Y or Z limits is Inf or -Inf. Otherwise, it
%       uses the 'tiled' method. The 'tiled' method requires finite limits.
%
%   Example:
%   Integrate over the region 0 <= x <= pi, 0 <= y <= 1, -1 <= z <= 1:
%       f = @(x,y,z) y.*sin(x)+z.*cos(x)
%       Q = integral3(f,0,pi,0,1,-1,1)
%
%   Example:
%   Integrate over the unit sphere in Cartesian coordinates:
%       f = @(x,y,z) x.*cos(y) + x.^2.*cos(z)
%       xmin = -1
%       xmax = 1
%       ymin = @(x)-sqrt(1 - x.^2)
%       ymax = @(x) sqrt(1 - x.^2)
%       zmin = @(x,y)-sqrt(1 - x.^2 - y.^2)
%       zmax = @(x,y) sqrt(1 - x.^2 - y.^2)
%       Q = integral3(f,xmin,xmax,ymin,ymax,zmin,zmax)
%
%   Class support for inputs XMIN, XMAX, YMIN, YMAX, ZMIN, ZMAX, and the
%   output of FUN:
%      float: double, single
%
%   See also INTEGRAL, INTEGRAL2, TRAPZ, FUNCTION_HANDLE

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(7,inf);
if ~(isfloat(xmin) && isscalar(xmin))
    error(message('MATLAB:integral3:invalidXMin'));
end
if ~(isfloat(xmax) && isscalar(xmax))
    error(message('MATLAB:integral3:invalidXMax'));
end
isImproper = false; % XMIN and XMAX do not matter.
if ~isa(FUN,'function_handle')
    error(message('MATLAB:integral3:invalidIntegrand'));
end
if isa(ymin,'function_handle')
    YMINX = ymin;
elseif isfloat(ymin) && isscalar(ymin)
    isImproper = isImproper || isinf(ymin);
    YMINX = @(x) ymin*ones(size(x));
else
    error(message('MATLAB:integral3:invalidYMin'));
end
if isa(ymax,'function_handle')
    YMAXX = ymax;
elseif isfloat(ymax) && isscalar(ymax)
    isImproper = isImproper || isinf(ymax);
    YMAXX = @(x) ymax*ones(size(x));
else
    error(message('MATLAB:integral3:invalidYMax'));
end
if isa(zmin,'function_handle')
    ZMINXY = zmin;
elseif isfloat(zmin) && isscalar(zmin)
    isImproper = isImproper || isinf(zmin);
    ZMINXY = @(x,y) zmin*ones(size(y));
else
    error(message('MATLAB:integral3:invalidZMin'));
end
if isa(zmax,'function_handle')
    ZMAXXY = zmax;
elseif isfloat(zmax) && isscalar(zmax)
    isImproper = isImproper || isinf(zmax);
    ZMAXXY = @(x,y) zmax*ones(size(y));
else
    error(message('MATLAB:integral3:invalidZMax'));
end
p = inputParser;
p.addParamValue('AbsTol',1e-10,@validateAbsTol);
p.addParamValue('RelTol',1e-6,@validateRelTol);
p.addParamValue('Method','auto',@validateMethod);
p.parse(varargin{:});
opstruct = p.Results;
atol = opstruct.AbsTol;
rtol = opstruct.RelTol;
INTEGRAL2OPTIONS = integral2ParseArgs(isImproper, ...
    'AbsTol',atol,'RelTol',rtol, ...
    'method',opstruct.Method);
INTEGRAL2OPTIONS.Persistence = 1;
INTEGRAL2OPTIONS.ThrowOnFail = true;
integralOptions = integralParseArgs('AbsTol',atol,'RelTol',rtol);
integralOptions.InitialIntervalCount = 3;
integralOptions.Persistence = 1;
try
    Q = integralCalc(@innerintegral,xmin,xmax,integralOptions);
catch ME
    if strcmp(ME.identifier,'MATLAB:integral:unsuccessful') || ...
            strcmp(ME.identifier,'MATLAB:integral2:unsuccessful')
        warning(message('MATLAB:integral3:unsuccessful'));
        Q = nan(outclass(FUN,xmin,xmax,YMINX,YMAXX,ZMINXY,ZMAXXY));
    else
        rethrow(ME);
    end
end

%--------------------------------------------------------------------------

    function Q = innerintegral(x)
        y1 = YMINX(x);
        y2 = YMAXX(x);
        Q1 = integral2Calc( ...
            @(y,z)FUN(x(1)*ones(size(z)),y,z), ...
            y1(1),y2(1), ...
            @(y)ZMINXY(x(1)*ones(size(y)),y), ...
            @(y)ZMAXXY(x(1)*ones(size(y)),y), ...
            INTEGRAL2OPTIONS);
        Q = zeros(size(x),class(Q1));
        Q(1) = Q1;
        for i = 2:numel(x)
            Q(i) = integral2Calc( ...
                @(y,z)FUN(x(i)*ones(size(z)),y,z), ...
                y1(i),y2(i), ...
                @(y)ZMINXY(x(i)*ones(size(y)),y), ...
                @(y)ZMAXXY(x(i)*ones(size(y)),y), ...
                INTEGRAL2OPTIONS);
        end
    end

%--------------------------------------------------------------------------

    function p = validateAbsTol(x)
        if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
            error(message('MATLAB:integral3:invalidAbsTol'));
        end
        p = true;
    end

%--------------------------------------------------------------------------

    function p = validateRelTol(x)
        if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
            error(message('MATLAB:integral3:invalidRelTol'));
        end
        p = true;
    end

%--------------------------------------------------------------------------

    function p = validateMethod(x)
        if ~(strcmpi(x,'auto') || strcmpi(x,'tiled') || strcmpi(x,'iterated'))
            error(message('MATLAB:integral3:invalidMethod'));
        end
        p = true;
    end

%--------------------------------------------------------------------------

    function cls = outclass(FUN,xmin,xmax,ymin,ymax,zmin,zmax)
        % Determine the output class. This is used when the integration
        % has already failed and we need to return the right class of NaN.
        xmid = interiorPoint(xmin,xmax);
        ymid = interiorPoint(ymin(xmid),ymax(xmid));
        zmid = interiorPoint(zmin(xmid,ymid),zmax(xmid,ymid));
        cls = class(FUN(xmid,ymid,zmid)*xmid*ymid*zmid);
    end

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
    end

%--------------------------------------------------------------------------

end
