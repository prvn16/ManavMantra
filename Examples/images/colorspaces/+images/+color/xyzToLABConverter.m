function c = xyzToLABConverter(wp)
% xyzToLABConverter Color converter from CIE 1931 XYZ to CIE 1976 L*a*b*
%
%    converter = images.color.xyzToLABConverter
%    converter = images.color.xyzToLABConverter(wp)
%
%    converter = images.color.xyzToLABConverter returns a color converter that converts CIE 1931 XYZ
%    color values to CIE 1976 L*a*b* color values.
%
%    converter = images.color.xyzToLABConverter(wp) returns a color converter that uses the
%    specified reference white point. The input argument wp is either a 1-by-3 vector or a string
%    containing the name of a standard white point. If the reference white point is not specified,
%    then 'd65' is used by default.
%
%    See also images.color.ColorConverter

%    Copyright 2014 The MathWorks, Inc

if nargin < 1
    wp = whitepoint('d65');
else
    wp = images.color.internal.checkWhitePoint(wp);
end

f = @(in) images.color.unencodedXYZToLAB(in,wp);

c = images.color.ColorConverter(f);
c.Description = getString(message('images:color:convertXYZToLAB'));
c.InputSpace = 'XYZ';
c.OutputSpace = 'Lab';
c.NumInputComponents = 3;
c.NumOutputComponents = 3;
c.InputEncoder = images.color.XYZEncoder;
c.OutputEncoder = images.color.ICCLab2Encoder;
c.OutputType = 'float';
