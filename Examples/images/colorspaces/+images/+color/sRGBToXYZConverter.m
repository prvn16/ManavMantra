function converter = sRGBToXYZConverter(wp)
% sRGBToXYZConverter Color converter from sRGB to CIE 1931 XYZ
%
%    converter = images.color.sRGBToXYZConverter
%    converter = images.color.sRGBToXYZConverter(wp)
%
%    converter = images.color.sRGBToXYZConverter returns a color converter that converts sRGB color
%    values to CIE 1931 XYZ color values.
%
%    converter = images.color.sRGBToXYZConverter(wp) returns a color converter that adapts to the
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
    f = @(in) images.color.adaptXYZ(in,wp_d65,wp);
    adapt_converter = images.color.ColorConverter(f);
    adapt_converter.Description = getString(message('images:color:adaptXYZValues'));
    adapt_converter.InputSpace = 'XYZ';
    adapt_converter.OutputSpace = 'XYZ';
    adapt_converter.NumInputComponents = 3;
    adapt_converter.NumOutputComponents = 3;
    adapt_converter.InputEncoder = images.color.XYZEncoder;
    adapt_converter.OutputEncoder = images.color.XYZEncoder;
    
    new_converter = images.color.ColorConverter({converter,adapt_converter});
    new_converter.InputSpace = converter.InputSpace;
    new_converter.OutputSpace = converter.OutputSpace;
    new_converter.OutputType = converter.OutputType;
    new_converter.InputEncoder = converter.InputEncoder;
    new_converter.Description = converter.Description;
    converter = new_converter;

end

function converter = getBasicConverter

% Function for computing linear RGB tristimulous values to XYZ
% tristimulous values.
M = images.color.internal.linearRGBToXYZTransform(true);
M = M';

g = @(in) in * M;
converter = images.color.ColorConverter(g);
converter.Description = getString(message('images:color:convertLinearRGBToXYZ'));
converter.InputSpace = 'RGB';
converter.OutputSpace = 'XYZ';
converter.OutputType = 'float';
converter.OutputEncoder = images.color.XYZEncoder;
converter.InputEncoder = images.color.sRGBLinearEncoder;

