function rgb = xyz2rgb(xyz,varargin)
%XYZ2RGB Convert CIE 1931 XYZ to RGB
%
%   rgb = XYZ2RGB(xyz) converts CIE 1931 XYZ values to RGB values. xyz can
%   be a P-by-3 matrix of color values (one color per row), or it can an
%   M-by-N-by-3 image array, or it can be an M-by-N-by-3-by-F image stack.
%
%   rgb = xyz2rgb(xyz,Name,Value,...) specifies additional options with one
%   or more name-value pair arguments:
%
%     'ColorSpace'  -  Color space of the output RGB values.
%                      'srgb' (default) | 'adobe-rgb-1998' | 'linear-rgb'
%
%     'WhitePoint'  -  Reference white point.
%                      1-by-3 vector | 'a' | 'c' | 'd50' | 'd55' |
%                      'd65' (default) | 'icc' | 'e'
%
%     'OutputType'  -  Data type of returned RGB values.
%                      'double' | 'single' | 'uint8' | 'uint16'
%
%                      Default: class(xyz)
%
%   Class Support
%   -------------
%   The type of xyz can be single or double. The output has the same shape
%   as the input. The output type is the same as the input type unless the
%   OutputType parameter is specified.
%
%   Examples
%   --------
%   [1] Convert an XYZ color to sRGB.
%
%     xyz2rgb([0.25 0.40 0.10])
%
%   [2] Convert an XYZ color to Adobe RGB (1998).
%
%     xyz2rgb([0.25 0.40 0.10],'ColorSpace','adobe-rgb-1998')
%
%   [3] Convert an XYZ color to sRGB using D50 as the reference white point.
%
%     xyz2rgb([0.25 0.40 0.10],'WhitePoint','d50')
%
%   [4] Convert an XYZ color to an 8-bit-encoded RGB color.
%
%     xyz2rgb([0.25 0.40 0.10],'OutputType','uint8')
%
%   See also RGB2XYZ, RGB2LAB, LAB2RGB, XYZ2LAB, LAB2XYZ.

%    Copyright 2014-2017 The MathWorks, Inc.

validateattributes(xyz,{'single','double'},{'real'},mfilename,'XYZ',1)

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(args{:});

switch options.ColorSpace
    case 'adobe-rgb-1998'
        converter = images.color.xyzToAdobeRGBConverter(options.WhitePoint);
    case 'srgb'
        converter = images.color.xyzToSRGBConverter(options.WhitePoint);
    otherwise
        converter = images.color.xyzToLinearRGBConverter(options.WhitePoint);
end

if isempty(options.OutputType)
    converter.OutputType = 'float';
else
    converter.OutputType = options.OutputType;
end

rgb = converter(xyz);

function options = parseInputs(varargin)

narginchk(0,6);

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

% 'OutputType'
defaultOutputType = [];
validOutputTypes = {'double', 'single', 'uint8', 'uint16'};
validateOutputType = @(x) validateattributes(x, ...
    {'char'}, ...
    {}, ...
    mfilename,'OutputType');
parser.addParameter('OutputType', ...
    defaultOutputType, ...
    validateOutputType);

parser.parse(varargin{:});
options = parser.Results;

% InputParser doesn't work with validatestring, so use it after parsing.
options.ColorSpace = validatestring( ...
    options.ColorSpace, ...
    validColorSpaces, ...
    mfilename,'ColorSpace');

if ~isequal(options.OutputType, defaultOutputType)
    options.OutputType = validatestring( ...
        options.OutputType, ...
        validOutputTypes, ...
        mfilename,'OutputType');
end

% Use checkWhitePoint to validate the white point
options.WhitePoint = ...
    images.color.internal.checkWhitePoint(options.WhitePoint);
