function lab = unencodedXYZToLAB(xyz,wp)
% unencodedXYZToLab Convert CIE 1931 XYZ values to CIE 1976 L*a*b* values
%
%    lab = images.color.unencodedXYZToLAB(xyz)
%    lab = images.color.unencodedXYZToLAB(xyz,wp)
%
%    lab = images.color.unencodedXYZToLAB(xyz) converts unencoded CIE 1931 XYZ values to CIE 1976
%    L*a*b* values. xyz is a P-by-3 single or double matrix, one XYZ color per row. lab is also
%    P-by-3, one L*a*b* color per row.
%
%    lab = images.color.unencodedXYZToLAB(xyz,wp) uses the specified white point, where wp is a
%    1-by-3 vector or the name of a standard white point. If wp is not specified, then 'd65' is used
%    by default.

%    Copyright 2014 The MathWorks, Inc.

if nargin < 2
    wp = whitepoint('d65');
else
    wp = images.color.internal.checkWhitePoint(wp);
end

xyz = bsxfun(@rdivide,xyz,wp);

X = xyz(:,1);
Y = xyz(:,2);
Z = xyz(:,3);

fY = f(Y);
L = 116 * fY - 16;
a = 500 * (f(X) - fY);
b = 200 * (fY - f(Z));

lab = [L a b];

function out = f(in)

out = zeros(size(in),'like',in);

lin_range = (in <= (6/29)^3);
gamma_range = ~lin_range;

% exp(1/3 * log(x)) is a faster way of computing x.^(1/3).
out(gamma_range) = exp((1/3) * log(in(gamma_range)));
out(lin_range) = ((24389/27) * in(lin_range) + 16)/116;

