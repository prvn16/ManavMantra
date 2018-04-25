function converter = xyzToSRGBConverter(wp)
% xyzToSRGBConverter Color converter from CIE 1931 XYZ to sRGB
%
%    converter = images.color.xyzToSRGBConverter
%    converter = images.color.xyzToSRGBConverter(wp)
%
%    converter = images.color.xyzToSRGBConverter returns a color converter that converts CIE 1931
%    XYZ color values to sRGB color values.
%
%    converter = images.color.xyzToSRGBConverter(wp) returns a color converter that adapts to the
%    specified reference white point. If the reference white point is not specified, then D65 is
%    used by default.
%
%    See also images.color.ColorConverter

%    Copyright 2014-2015 The MathWorks, Inc.

wp_d65 = whitepoint('d65');
if nargin < 1
    wp = wp_d65;
else
    wp = images.color.internal.checkWhitePoint(wp);
end

converter = getBasicConverter;

if ~isequal(wp, wp_d65)
    % Add a chromatic adaptation step
    f = @(in) images.color.adaptXYZ(in,wp,wp_d65);
    adapt_converter = images.color.ColorConverter(f);
    adapt_converter.Description = getString(message('images:color:adaptXYZValues'));
    adapt_converter.InputSpace = 'XYZ';
    adapt_converter.OutputSpace = 'XYZ';
    adapt_converter.NumInputComponents = 3;
    adapt_converter.NumOutputComponents = 3;
    adapt_converter.InputEncoder = images.color.XYZEncoder;
    adapt_converter.OutputEncoder = images.color.XYZEncoder;
    
    converter.ConversionSteps = [{adapt_converter}, converter.ConversionSteps];
end

function converter = getBasicConverter

% Function for converting XYZ tristimulous values to linear
% RGB tristimulous values.
M = images.color.internal.linearRGBToXYZTransform(true);
M = M';
M = M \ eye(3);

g = @(in) in * M;
converter1 = images.color.ColorConverter(g);
converter1.Description = getString(message('images:color:convertXYZToLinearRGB'));
converter1.InputSpace = 'XYZ';
converter1.OutputSpace = 'RGB';
converter1.NumInputComponents = 3;
converter1.NumOutputComponents = 3;
converter1.InputEncoder = images.color.XYZEncoder;

gamma = 2.4;
a = 1.055;
b = -0.055;
c = 12.92;
d = 0.0031308;
f = @(in) images.color.parametricCurveB(in,1/gamma,a,b,c,d);
converter2 = images.color.ColorConverter(f);
converter2.Description = getString(message('images:color:convertLinearRGBToNonlinearRGB'));
converter2.InputSpace = 'RGB';
converter2.OutputSpace = 'RGB';

converter = images.color.ColorConverter({converter1, converter2});
converter.Description = getString(message('images:color:convertXYZToSRGB'));
converter.InputSpace = 'XYZ';
converter.OutputSpace = 'RGB';
converter.InputEncoder = images.color.XYZEncoder;
