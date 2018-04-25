function [R,G,B] = delinearizeSRGB(linearR,linearG,linearB) %#codegen
%delinearizeSRGB Delinearize unencoded sRGB tristimulous values
%
%   The delinearization is done using the following parametric curve:
%     f(u) = -f(-u),               u < 0
%     f(u) = c*u,             0 <= u < d
%     f(u) = a*u^gamma + b,        u >= d
%
%   where u represents a color value and with parameters:
%     a = 1.055
%     b = -0.055
%     c = 12.92
%     d = 0.0031308
%     gamma = 1/2.4
%
%   The tristimulous input values are expected to be single or double.

%   Copyright 2015 The MathWorks, Inc.

R = parametricCurveB(linearR);
G = parametricCurveB(linearG);
B = parametricCurveB(linearB);

%--------------------------------------------------------------------------
function y = parametricCurveB(x)

% Curve parameters
gamma = cast(1/2.4,'like',x);
a     = cast(1.055,'like',x);
b     = cast(-0.055,'like',x);
c     = cast(12.92,'like',x);
d     = cast(0.0031308,'like',x);

if x <= -d
    % gamma part: (-inf,-d]
    y = -a*(-x).^gamma - b;
elseif x < d
    % linear part: (-d,d)
    y = c.*x;
else
    % gamma part: [d,inf)
    y = a*x.^gamma + b;
end