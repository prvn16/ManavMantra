function [X,Y,Z] = LABToXYZ(L,a,b,whitePoint) %#codegen
%LAB2XYZ Convert unencoded CIE 1976 L*a*b* values to CIE 1946 XYZ values
%
%   The tristimulous input values are expected to be single or double.
%   The returned XYZ values are of the same class as the input.
%
%   whitePoint is a 1x3 vector containing the reference white point.
%
%   The conversion is done as:
%
%     X = xr * Xr
%     Y = yr * Yr
%     Z = zr * Zr
%
%   where (Xy,Yr,Zr) is the reference white point and,
%
%     xr = g{ (L+16)/116 + a/500 }
%     yr = g{ (L+16)/116 }
%     zr = g{ (L+16)/116 - b/200 }
%
%   the function g is defined as,
%
%     g(x) = x^3,                  x^3 > epsilon
%     g(x) = (116*x - 16)/kappa,   otherwise
%
%   and the constants epsilon and kappa are (6/29)^3 and (29/3)^3, resp.

%   Copyright 2015 The MathWorks, Inc.

coder.internal.prefer_const(whitePoint);

L = (L + 16)/116;

X = cast(whitePoint(1),'like',L) * g(L + a/500);
Y = cast(whitePoint(2),'like',L) * g(L);
Z = cast(whitePoint(3),'like',L) * g(L - b/200);

%--------------------------------------------------------------------------
function y = g(x)

epsilon = cast(6/29,'like',x);

if x > epsilon
    y = x.^3;
else
    y = 3*(epsilon)^2*(x - 4/29);
end