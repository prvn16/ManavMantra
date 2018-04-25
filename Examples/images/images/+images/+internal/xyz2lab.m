function lab = xyz2lab(xyz)
%xyz2lab Convert XYZ colors to L*a*b* colors
%
%   lab = xyz2lab(xyz) converts a P-by-3 matrix of XYZ colors to a P-by-3
%   matrix of L*a*b* colors assuming a D65 white point.

%   Copyright 2013 The MathWorks, Inc.

% normalize by white point
wp = [.9504 1.0 1.0888];  % D65
n = size(xyz,1);
xyz = bsxfun(@rdivide, xyz, wp);

% cube root normalized xyz
fxyz_n = xyz .^ (1/3);
% if normalized x, y, or z less than or equal to 216 / 24389 apply function 2  
L = xyz <= 216 / 24389;
% function 2
k = 841 / 108;
fxyz_n(L) = k * xyz(L) + 16/116;
clear xyz L;

lab = zeros(n,3);
% calculate L*  
lab(:,1) = 116 * fxyz_n(:,2) - 16;
% calculate a*  
lab(:,2) = 500 * (fxyz_n(:,1) - fxyz_n(:,2));
% calculate b*  
lab(:,3) = 200 * (fxyz_n(:,2) - fxyz_n(:,3));
