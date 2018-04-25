function xyz = lab2xyz(lab)
%lab2xyz Convert L*a*b* colors to XYZ
%
%   xyz = lab2xyz(lab) converts a P-by-3 matrix of L*a*b* colors to a
%   P-by-3 matrix of XYZ colors assuming a D65 whitepoint.

%   Copyright 2013 The MathWorks, Inc.

wp = [.9504 1.0 1.0889];  % D65
n = size(lab,1);
fxyz_n = zeros(n,3);   
fxyz_n(:,2) = (lab(:,1) + 16) / 116;  
fxyz_n(:,1) = (lab(:,2) / 500) + fxyz_n(:,2);   
fxyz_n(:,3) = fxyz_n(:,2) - (lab(:,3) / 200);

xyz = fxyz_n .^3;
k = 841 / 108;
l = fxyz_n <= 6/29;
xyz(l) = (fxyz_n(l) -(16/116)) / k;

% scale by white point
xyz = bsxfun(@times, xyz, wp);
