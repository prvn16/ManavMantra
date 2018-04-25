function v = parametricCurveB(u, gamma, a, b, c, d)
% parametricCurveB Parametric curve with power and linear pieces
%
%    v = images.color.parametricCurveB(u,gamma,a,b,c,d)
%
%    Computes the following piecewise function:
%
%        f(u) = a*u.^gamma + b      d <= u
%
%        f(u) = c*u                 0 <= u && u < d
%
%        f(u) = -f(-u)              u < 0
%
%    If u is an array, then the computation is performed elementwise.
%
%    This function does not validate its inputs.

%    Copyright 2014 The MathWorks, Inc.

v = zeros(size(u),'like',u);

in_sign = -2 * (u < 0) + 1;
u = abs(u);

lin_range = (u < d);
gamma_range = ~lin_range;

v(gamma_range) = a*u(gamma_range).^gamma + b;
v(lin_range) = c*u(lin_range);

v = v .* in_sign;

