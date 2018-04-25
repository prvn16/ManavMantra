function c = labToXYZConverter(wp)
% labToXYZConverter Color converter from CIE 1976 L*a*b* to CIE 1931 XYZ
%
%    converter = images.color.labToXYZConverter
%    converter = images.color.labToXYZConverter(wp)
%
%    converter = images.color.labToXYZConverter returns a color converter that converts CIE 1976
%    L*a*b* color values to CIE 1931 XYZ color values.
%
%    converter = images.color.labToXYZConverter(wp) returns a color converter that uses the
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

f = @(in) images.color.unencodedLABToXYZ(in,wp);

c = images.color.ColorConverter(f);
c.Description = getString(message('images:color:convertLABToXYZ'));
c.InputSpace = 'Lab';
c.OutputSpace = 'XYZ';
c.NumInputComponents = 3;
c.NumOutputComponents = 3;
c.InputEncoder = images.color.ICCLab2Encoder;
c.OutputEncoder = images.color.XYZEncoder;
c.OutputType = 'float';
