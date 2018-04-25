function v = parametricCurveA(u, gamma, a, b, c, d)
% parametricCurveA Parametric curve with power and linear pieces
%
%    v = images.color.parametricCurveA(u,gamma,a,b,c,d)
%
%    Computes the following piecewise function:
%
%        f(u) = (a*u + b).^gamma         d <= u
%
%        f(u) = c*u                      0 <= u && u < d
%
%        f(u) = -f(-u)                   u < 0
%
%    If u is an array, then the computation is performed elementwise.
%
%    This function does not validate its inputs.

%    Copyright 2014-2015 The MathWorks, Inc.

in_sign = -2 * (u < 0) + 1;
u = abs(u);

lin_range = (u < d);
gamma_range = ~lin_range;

% The following call to zeros is written so that a single-precision input produces a
% single-precision output.
v = zeros(size(u),'like',u);

% Performance optimization: x.^a == exp(a.*log(x));
%v(gamma_range) = (a*u(gamma_range) + b).^gamma;
v(gamma_range) = exp(gamma .* log(a*u(gamma_range) + b));
v(lin_range) = c*u(lin_range);

v = v .* in_sign;

