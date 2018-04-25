function xyz = rgb2xyz(rgb,varargin)
%RGB2XYZ Convert RGB to CIE 1931 XYZ
%
%   xyz = RGB2XYZ(rgb) converts RGB values to CIE 1931 XYZ values. rgb can
%   be a P-by-3 matrix of color values (one color per row), or it can be an
%   M-by-N-by-3 image array, or it can be an M-by-N-by-3-by-F image stack.
%
%   xyz = RGB2XYZ(rgb,Name,Value,...) specifies additional options with one
%   or more name-value pair arguments:
%
%     'ColorSpace'  -  Color space of the input RGB values.
%                      'srgb' (default) | 'adobe-rgb-1998' | 'linear-rgb'
%
%     'WhitePoint'  -  Reference white point.
%                      1-by-3 vector | 'a' | 'c' | 'd50' | 'd55' |
%                      'd65' (default) | 'icc' | 'e'
%
%   Class Support
%   -------------
%   rgb can be uint8, uint16, single, or double. The output has the same
%   shape as the input. The output type is double unless the input type is
%   single, in which case the output type is also single.
%
%   Examples
%   --------
%   [1] Convert RGB white to XYZ.
%
%     rgb2xyz([1 1 1])
%
%   [2] Convert an RGB color to XYZ using D50 as the reference white.
%
%     rgb2xyz([.2 .3 .4],'WhitePoint','d50')
%
%   [3] Convert an Adobe RGB (1998) color value to XYZ.
%
%     rgb2xyz([.2 .3 .4],'ColorSpace','adobe-rgb-1998')
%
%   [4] Convert RGB image to XYZ.
%
%     rgb = imread('peppers.png');
%     xyz = rgb2xyz(rgb);
%
%   See also XYZ2RGB, RGB2LAB, LAB2RGB, XYZ2LAB, LAB2XYZ.

%   Copyright 2014-2017 The MathWorks, Inc.

validateattributes(rgb, ...
    {'single','double','uint8','uint16'}, ...
    {'real'},mfilename,'RGB',1)

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(args{:});

switch options.ColorSpace
    case 'adobe-rgb-1998'
        converter = images.color.adobeRGBToXYZConverter(options.WhitePoint);
    case 'srgb'
        converter = images.color.sRGBToXYZConverter(options.WhitePoint);
    otherwise
        converter = images.color.linearRGBToXYZConverter(options.WhitePoint);
end

converter.OutputType = 'float';
xyz = converter(rgb);

function options = parseInputs(varargin)

narginchk(0,4);

parser = inputParser();
parser.FunctionName = mfilename;

% 'ColorSpace'
defaultColorSpace = 'srgb';
validColorSpaces = {defaultColorSpace, 'adobe-rgb-1998', 'linear-rgb'};
validateColorSpace = @(x) validateattributes(x, ...
    {'char'}, ...
    {}, ...
    mfilename,'ColorSpace');
parser.addParameter('ColorSpace', ...
    defaultColorSpace, ...
    validateColorSpace);

% 'WhitePoint'
defaultWhitePoint = 'd65';
parser.addParameter('WhitePoint', ...
    defaultWhitePoint, ...
    @(~) true);

parser.parse(varargin{:});
options = parser.Results;

% InputParser doesn't work with validatestring, so use it after parsing.
options.ColorSpace = validatestring( ...
    options.ColorSpace, ...
    validColorSpaces, ...
    mfilename,'ColorSpace');

% Use checkWhitePoint to validate the white point
options.WhitePoint = ...
    images.color.internal.checkWhitePoint(options.WhitePoint);
