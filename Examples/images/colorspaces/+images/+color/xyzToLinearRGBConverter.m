function converter = xyzToLinearRGBConverter(wp)
%xyzToLinearRGBConverter Color converter from CIE 1931 XYZ to Linear RGB
%
%   converter = images.color.xyzToLinearRGBConverter
%   converter = images.color.xyzToLinearRGBConverter(wp)
%
%   converter = images.color.xyzToLinearRGBConverter returns a color
%   converter that converts CIE 1931 XYZ color values to sRGB color values.
%
%   converter = images.color.xyzToLinearRGBConverter(wp) returns a color
%   converter that adapts to the specified reference white point. If the
%   reference white point is not specified, then D65 is used by default.
%
%   See also images.color.ColorConverter

%   Copyright 2016 The MathWorks, Inc.

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
    
    new_converter = images.color.ColorConverter({adapt_converter,converter});
    new_converter.InputSpace = adapt_converter.InputSpace;
    new_converter.OutputSpace = adapt_converter.OutputSpace;
    new_converter.OutputType = adapt_converter.OutputType;
    new_converter.InputEncoder = adapt_converter.InputEncoder;
    new_converter.Description = adapt_converter.Description;
    converter = new_converter;
end

function converter = getBasicConverter

% Function for converting XYZ tristimulous values to linear
% RGB tristimulous values.
M = images.color.internal.linearRGBToXYZTransform(true);
M = M';
M = M \ eye(3);

g = @(in) in * M;
converter = images.color.ColorConverter(g);
converter.Description = getString(message('images:color:convertXYZToLinearRGB'));
converter.InputSpace = 'XYZ';
converter.OutputSpace = 'RGB';
converter.NumInputComponents = 3;
converter.NumOutputComponents = 3;
converter.InputEncoder = images.color.XYZEncoder;
