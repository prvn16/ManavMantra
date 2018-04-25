function converter = adobeRGBToXYZConverter(wp)
% adobeRGBToXYZConverter Color converter from Adobe RGB 1998 to CIE 1931 XYZ
%
%    converter = images.color.adobeRGBToXYZConverter
%    converter = images.color.adobeRGBToXYZConverter(wp)
%
%    converter = images.color.adobeRGBToXYZConverter returns a color converter that converts Adobe
%    RGB 1998 color values to CIE 1931 XYZ color values.
%
%    converter = images.color.adobeRGBToXYZConverter(wp) returns a color converter that adapts to
%    the specified reference white point. If the reference white point is not specified, then D65 is
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
    f = @(in) images.color.adaptXYZ(in,wp_d65,wp);
    adapt_converter = images.color.ColorConverter(f);
    adapt_converter.Description = getString(message('images:color:adobeRGBToXYZConverterDescription'));
    adapt_converter.InputSpace = 'XYZ';
    adapt_converter.OutputSpace = 'XYZ';
    adapt_converter.NumInputComponents = 3;
    adapt_converter.NumOutputComponents = 3;
    adapt_converter.InputEncoder = images.color.XYZEncoder;
    adapt_converter.OutputEncoder = images.color.XYZEncoder;
    
    converter.ConversionSteps{end+1} = adapt_converter;
end

function converter = getBasicConverter
% Function for computing linear RGB tristimulous values
% Reference: Section 4.3.5.2, Adobe RGB (1998) Color Image Encoding, May
% 2005, p. 12
f = @(in) in.^2.19921875;
converter1 = images.color.ColorConverter(f);
converter1.Description = getString(message('images:color:linearizeRGBValues'));
converter1.InputSpace = 'RGB';
converter1.OutputSpace = 'RGB';

% Function for computing linear RGB tristimulous values to XYZ
% tristimulous values.
M = images.color.internal.linearRGBToXYZTransform(false);
M = M';

g = @(in) in * M;
converter2 = images.color.ColorConverter(g);
converter2.Description = getString(message('images:color:convertLinearRGBToXYZ'));
converter2.InputSpace = 'RGB';
converter2.OutputSpace = 'XYZ';
converter2.NumInputComponents = 3;
converter2.NumOutputComponents = 3;
converter2.OutputEncoder = images.color.XYZEncoder;
converter2.OutputType = 'float';

converter = images.color.ColorConverter({converter1, converter2});
converter.Description = getString(message('images:color:convertAdobeRGBToXYZ'));
converter.InputSpace = 'RGB';
converter.OutputSpace = 'XYZ';
converter.OutputEncoder = images.color.XYZEncoder;
converter.OutputType = 'float';