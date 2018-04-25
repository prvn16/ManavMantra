function [Gxx, Gyy, Gxy] = hessian2D(I, sigma)
%HESSIAN2D Computes hessian of an image, I. 
%   [GXX, GYY, GXY] = HESSIAN2D(I, SIGMA) computes the Hessian for each
%   pixel of image I, using SIGMA as parameter to Gaussian Filtering. GXX,
%   GYY, GXY are the unique elements of 2x2 real symmetric Hessian matrix.
%   They are of the same size as image, I.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within other toolbox classes and
%   functions. Its behavior may change, or the feature itself may be
%   removed in a future release.

%   Copyright 2016 The MathWorks, Inc.

Ig = imgaussfilt(I, sigma, 'FilterSize', 2*ceil(3*sigma)+1);
[Gx, Gy]   = imgradientxy(Ig, 'central');
[Gxx, Gxy] = imgradientxy(Gx, 'central');
[ ~ , Gyy] = imgradientxy(Gy, 'central');

Gxx = (sigma^2)*Gxx;
Gyy = (sigma^2)*Gyy;
Gxy = (sigma^2)*Gxy;