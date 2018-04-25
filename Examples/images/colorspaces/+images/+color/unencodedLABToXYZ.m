function xyz = unencodedLABToXYZ(lab,wp)
% unencodedLABToXYZ Convert CIE 1976 L*a*b* values to CIE 1931 XYZ values
%
%    xyz = images.color.unencodedLABToXYZ(lab)
%    xyz = images.color.unencodedLABToXYZ(lab,wp)
%
%    xyz = images.color.unencodedLABToXYZ(lab) converts unencoded L*a*b* values to CIE 1931 XYZ
%    values. lab is a P-by-3 single or double matrix, one L*a*b* color per row. xyz is also P-by-3,
%    one XYZ color per row.
%
%    xyz = images.color.unencodedLABToXYZ(lab,wp) uses the specified reference white point, where wp
%    is a 1-by-3 vector or the name of a standard white point. If wp is not specified, then 'd65' is
%    used by default.

%    Copyright 2014 The MathWorks, Inc.

if nargin < 2
    wp = whitepoint('d65');
else
    wp = images.color.internal.checkWhitePoint(wp);
end

LL = (lab(:,1) + 16)/116;

Y = wp(2) * g(LL);
X = wp(1) * g(LL + (lab(:,2)/500));
Z = wp(3) * g(LL - (lab(:,3)/200));

xyz = [X Y Z];

function out = g(in)

out = zeros(size(in),'like',in);

lin_range = (in <= (6/29));
gamma_range = ~lin_range;

out(gamma_range) = in(gamma_range).^3;
out(lin_range) = 3*(6/29)^2 * (in(lin_range) - (4/29));
