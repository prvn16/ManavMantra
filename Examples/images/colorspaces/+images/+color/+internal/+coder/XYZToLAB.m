function [L,a,b] = XYZToLAB(X,Y,Z,whitePoint) %#codegen
%XYZ2LAB Convert unencoded CIE 1931 XYZ values to 1976 CIE L*a*b*
%
%   The tristimulous input values are expected to be single or double.
%   The returned L*a*b* values are of the same class as the input.
%
%   whitePoint is a 1x3 vector containing the reference white point.
%
%   The conversion is done as:
%
%     L = 116 * f(yr) - 16
%     a = 500 * (f(xr) - f(yr))
%     b = 200 * (f(yr) - f(zr))
%
%   where xr, yr and zr are normalized by the reference white point,
%
%     xr = X/Xr
%     yr = Y/Yr
%     zr = Z/Zr
%
%   the function f is defined as,
%
%     f(x) = x^(1/3),              x > epsilon
%     f(x) = (kappa*x + 16)/116,   otherwise
%
%   and the constants epsilon and kappa are (6/29)^3 and (29/3)^3, resp.

%   Copyright 2015 The MathWorks, Inc.

coder.internal.prefer_const(whitePoint);

xr = X / cast(whitePoint(1),'like',X);
yr = Y / cast(whitePoint(2),'like',X);
zr = Z / cast(whitePoint(3),'like',X);

fx = f(xr);
fy = f(yr);
fz = f(zr);

L = 116 * fy - 16;
a = 500 * (fx - fy);
b = 200 * (fy - fz);

%--------------------------------------------------------------------------
function y = f(x)

a = cast(216/24389,'like',x);
b = cast(24389/27,'like',x);

if x > a
    y = x.^(1/3);
else
    y = (b*x + 16)/116;
end