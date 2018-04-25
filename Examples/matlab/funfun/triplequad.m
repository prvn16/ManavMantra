function Q = triplequad(intfcn,xmin,xmax,ymin,ymax,zmin,zmax,tol,quadf,varargin)
%TRIPLEQUAD Numerically evaluate triple integral.
%   Q = TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX) evaluates the triple
%   integral of FUN(X,Y,Z) over the three dimensional rectangular region
%   XMIN <= X <= XMAX, YMIN <= Y <= YMAX, ZMIN <= Z <= ZMAX. FUN is a
%   function handle. The function V=FUN(X,Y,Z) should accept a vector X and
%   scalar Y and Z and return a vector V of values of the integrand.
%
%   Q = TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL) uses a tolerance
%   TOL instead of the default, which is 1.e-6.
%
%   Q = TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL) uses
%   quadrature function QUADL instead of the default QUAD.
%   Q = TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,MYQUADF) uses
%   your own quadrature function MYQUADF instead of QUAD. MYQUADF is a
%   function handle. MYQUADF should have the same calling sequence as QUAD
%   and QUADL. Use [] as a placeholder to obtain the default value of TOL.
%   QUADGK is not supported directly as a quadrature function for
%   TRIPLEQUAD, but it can be called from MYQUADF.
%
%   TRIPLEQUAD will be removed in a future release. Use INTEGRAL3 instead.
%
%   Example:
%   Integrate over the region 0 <= x <= pi, 0 <= y <= 1, -1 <= z <= 1:
%      integrnd = @(x,y,z) y.*six(x)+z.*cos(x);
%      Q = triplequad(integrnd, 0, pi, 0, 1, -1, 1)
%
%   Note the integrand can be evaluated with a vector x and scalars y and z.
%
%   Class support for inputs XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX and the output of FUN:
%      float: double, single
%
%   See also INTEGRAL3, INTEGRAL, INTEGRAL2, QUADGK, QUAD2D,
%   FUNCTION_HANDLE.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin < 7
    error(message('MATLAB:triplequad:NotEnoughInputs'));
end
if nargin < 8 || isempty(tol), tol = 1.e-6; end
if nargin < 9 || isempty(quadf)
    quadf = @quad;
else
    quadf = fcnchk(quadf);
end
intfcn = fcnchk(intfcn);

Q = dblquad(@innerintegral, ymin, ymax, zmin, zmax, tol, quadf, intfcn, ...
    xmin, xmax, tol, quadf, varargin{:});

%---------------------------------------------------------------------------

function Q = innerintegral(y, z, intfcn, xmin, xmax, tol, quadf, varargin)
%INNERINTEGRAL Used with TRIPLEQUAD to evaluate inner integral.
%
%   Q = INNERINTEGRAL(Y,Z,INTFCN,XMIN,XMAX,TOL,QUADF)

% Evaluate the innermost integral at each value of the outer variables.

fcl = intfcn(xmin, y(1), z(1), varargin{:});
Q = zeros(size(y), superiorfloat(fcl, xmax, y, z, varargin{:}));
trace = [];
for i = 1:length(y)
    Q(i) = quadf(intfcn, xmin, xmax, tol, trace, y(i), z, varargin{:});
end
