function [linearR,linearG,linearB] = linearizeSRGB(R,G,B) %#codegen
%linearizeSRGB Linearize unencoded sRGB tristimulous values
%
%   The linearization is done using the following parametric curve:
%     f(u) = -f(-u),               u < 0
%     f(u) = c*u,             0 <= u < d
%     f(u) = (a*u + b)^gamma,      u >= d
%
%   where u represents a color value and with parameters:
%     a = 1/1.055
%     b = 0.055/1.055
%     c = 1/12.92
%     d = 0.04045
%     gamma = 2.4
%
%   The tristimulous input values are expected to be single or double.

%   Copyright 2015 The MathWorks, Inc.

linearR = parametricCurveA(R);
linearG = parametricCurveA(G);
linearB = parametricCurveA(B);

%--------------------------------------------------------------------------
function y = parametricCurveA(x)

% Curve parameters
gamma = cast(2.4,'like',x);
a     = cast(1/1.055,'like',x);
b     = cast(0.055/1.055,'like',x);
c     = cast(1/12.92,'like',x);
d     = cast(0.04045,'like',x);

if x <= -d
    % gamma part: (-inf,-d]
    y = -(b - a*x).^gamma;
elseif x < d
    % linear part: (-d,d)
    y = c.*x;
else
    % gamma part: [d,inf)
    y = (a*x + b).^gamma;
end