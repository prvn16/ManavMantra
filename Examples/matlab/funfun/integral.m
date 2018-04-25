function Q = integral(fun,a,b,varargin)
%INTEGRAL  Numerically evaluate integral.
%   Q = INTEGRAL(FUN,A,B) approximates the integral of function FUN from A
%   to B using global adaptive quadrature and default error tolerances.
%
%   FUN must be a function handle. A and B can be -Inf or Inf. If both are
%   finite, they can be complex. If at least one is complex, INTEGRAL
%   approximates the path integral from A to B over a straight line path.
%
%   For scalar-valued problems the function Y = FUN(X) must accept a vector
%   argument X and return a vector result Y, the integrand function
%   evaluated at each element of X. For array-valued problems (see the
%   'ArrayValued' option below) FUN must accept a scalar and return an
%   array of values.
%
%   Q = INTEGRAL(FUN,A,B,PARAM1,VAL1,PARAM2,VAL2,...) performs the
%   integration with specified values of optional parameters. The available
%   parameters are
%
%   'AbsTol', absolute error tolerance
%   'RelTol', relative error tolerance
%
%       INTEGRAL attempts to satisfy |Q - I| <= max(AbsTol,RelTol*|Q|),
%       where I denotes the exact value of the integral. Usually RelTol
%       determines the accuracy of the integration. However, if |Q| is
%       sufficiently small, AbsTol determines the accuracy of the
%       integration, instead. The default value of AbsTol is 1.e-10, and
%       the default value of RelTol is 1.e-6. Single precision integrations
%       may require larger tolerances.
%
%   'ArrayValued', FUN is an array-valued function when the input is scalar
%
%       When 'ArrayValued' is true, FUN is only called with scalar X, and
%       if FUN returns an array, INTEGRAL computes a corresponding array of
%       outputs Q. The default value is false.
%
%   'Waypoints', vector of integration waypoints
%
%       If FUN(X) has discontinuities in the interval of integration, the
%       locations should be supplied as a 'Waypoints' vector. Waypoints
%       should not be used for singularities in FUN(X). Instead, split the
%       interval and add the results from separate integrations with
%       singularities at the endpoints. If A, B, or any entry of the
%       waypoints vector is complex, the integration is performed over a
%       sequence of straight line paths in the complex plane, from A to the
%       first waypoint, from the first waypoint to the second, and so
%       forth, and finally from the last waypoint to B.
%
%   Examples:
%       % Integrate f(x) = exp(-x^2)*log(x)^2 from 0 to infinity:
%       f = @(x) exp(-x.^2).*log(x).^2
%       Q = integral(f,0,Inf)
%
%       % To use a parameter in the integrand:
%       f = @(x,c) 1./(x.^3-2*x-c)
%       Q = integral(@(x)f(x,5),0,2)
%
%       % Specify tolerances:
%       Q = integral(@(x)log(x),0,1,'AbsTol',1e-6,'RelTol',1e-3)
%
%       % Integrate f(z) = 1/(2z-1) in the complex plane over the
%       % triangular path from 0 to 1+1i to 1-1i to 0:
%       Q = integral(@(z)1./(2*z-1),0,0,'Waypoints',[1+1i,1-1i])
%
%       % Integrate the vector-valued function sin((1:5)*x) from 0 to 1:
%       Q = integral(@(x)sin((1:5)*x),0,1,'ArrayValued',true)
%
%   Class support for inputs A, B, and the output of FUN:
%      float: double, single
%
%   See also INTEGRAL2, INTEGRAL3, FUNCTION_HANDLE

%   Portions based on "quadva" by Lawrence F. Shampine.
%   Ref: L.F. Shampine, "Vectorized Adaptive Quadrature in Matlab",
%   Journal of Computational and Applied Mathematics 211, 2008, pp.131-140

%   Copyright 2007-2013 The MathWorks, Inc.

% Validate the first three inputs.
narginchk(3,inf);
if ~isa(fun,'function_handle')
    error(message('MATLAB:integral:funArgNotHandle'));
end
if ~(isscalar(a) && isfloat(a) && isscalar(b) && isfloat(b))
    error(message('MATLAB:integral:invalidEndpoint'));
end
opstruct = integralParseArgs(varargin{:});
Q = integralCalc(fun,a,b,opstruct);
