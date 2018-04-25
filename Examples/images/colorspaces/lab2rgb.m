function rgb = lab2rgb(lab,varargin)
%LAB2RGB Convert CIE 1976 L*a*b* to RGB
%
%   rgb = LAB2RGB(lab) converts CIE 1976 L*a*b* values to RGB values. lab
%   can be a P-by-3 matrix of color values (one color per row), or it can
%   an M-by-N-by-3 image array, or it can be an M-by-N-by-3-by-F image
%   stack.
%
%   rgb = LAB2RGB(lab,Name,Value,...) specifies additional options with one
%   or more name-value pair arguments:
%
%     'ColorSpace'  -  Color space of the input RGB values.
%                      'srgb' (default) | 'adobe-rgb-1998' | 'linear-rgb'
%
%     'WhitePoint'  -  Reference white point
%                      1-by-3 vector | 'a' | 'c' | 'd50' | 'd55' |
%                      'd65' (default) | 'icc' | 'e'
%
%     'OutputType'  -  Data type of returned RGB values
%                      'double' | 'single' | 'uint8' | 'uint16'
%
%                      Default: class(lab)
%
%   Class Support
%   -------------
%   The type of lab can be single or double. The output has the same shape
%   as the input. The output type is the same as the input type unless the
%   OutputType parameter is specified.
%
%   Examples
%   --------
%   [1] Convert L*a*b* white to RGB.
%
%     lab2rgb([100 0 0])
%
%   [2] Convert an L*a*b* color to Adobe RGB (1998).
%
%     lab2rgb([70 5 10],'ColorSpace','adobe-rgb-1998')
%
%   [3] Convert an L*a*b* color to sRGB using D50 as the reference white point.
%
%     lab2rgb([70 5 10],'WhitePoint','d50')
%
%   [4] Convert an L*a*b* color to an 8-bit-encoded RGB color.
%
%     lab2rgb([70 5 10],'OutputType','uint8')
%
%   See also RGB2LAB, RGB2XYZ, XYZ2RGB, XYZ2LAB, LAB2XYZ.

%   Copyright 2014-2017 The MathWorks, Inc.

validateattributes(lab,{'single','double'},{'real'},mfilename,'LAB',1)

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(args{:});

converter1 = images.color.labToXYZConverter(options.WhitePoint);

switch options.ColorSpace
    case 'adobe-rgb-1998'
        converter2 = images.color.xyzToAdobeRGBConverter(options.WhitePoint);
    case 'srgb'
        converter2 = images.color.xyzToSRGBConverter(options.WhitePoint);
    otherwise
        converter2 = images.color.xyzToLinearRGBConverter(options.WhitePoint);
end

converter = images.color.ColorConverter({converter1, converter2});
converter.OutputType = options.OutputType;
rgb = converter(lab);

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
defaultOutputType = 'float';
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
