function xyz = lab2xyz(lab,varargin)
% lab2xyz Convert CIE 1976 L*a*b* to CIE 1931 XYZ
%
%    xyz = lab2xyz(lab)
%
%    xyz = lab2xyz(lab,Name,Value)
%
%    xyz = lab2xyz(lab) converts CIE 1976 L*a*b* values to CIE 1931 XYZ values. lab can be a P-by-3 matrix of
%    color values (one color per row), or it can an M-by-N-by-3 image array, or it can be an
%    M-by-N-by-3-by-F image stack. The type of lab can be single or double. The output has the same
%    shape and type as the input.
%
%    xyz = lab2xyz(xyz,Name,Value) specifies additional options with one or more Name,Value pair
%    arguments.
%
%    NAME-VALUE PAIR ARGUMENTS
%
%    'WhitePoint' - Reference white point
%                   1-by-3 vector | 'a' | 'c' | 'd50' | 'd55' | 'd65' (default) | 'icc' | 'e'
%
%    EXAMPLES
%
%    Convert an L*a*b* color to XYZ.
%
%        lab2xyz([50 10 -5])
%
%    Convert an L*a*b* color to XYZ using D50 as the reference white point.
%
%        lab2xyz([50 10 -5],'WhitePoint','d50')
%
%    See also xyz2lab, rgb2lab, lab2rgb, rgb2xyz, xyz2rgb

%    Copyright 2014-2017 The MathWorks, Inc.

validateattributes(lab,{'single','double'},{'real'},mfilename,'LAB',1)

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(args{:});

converter = images.color.labToXYZConverter(options.WhitePoint);
converter.OutputType = 'float';

xyz = converter(lab);

function options = parseInputs(varargin)
try
if rem(nargin,2) ~= 0
    error(message('images:color:invalidInput'))
end

valid_options = {'WhitePoint'};

options.WhitePoint = whitepoint('d65');

for k = 1:2:nargin
    name = varargin{k};
    idx = find(strncmpi(name, valid_options, length(name)));
    if isempty(idx)
        error(message('images:color:unrecognizedParameter',name))
    elseif length(idx) > 1
        error(message('images:color:ambiguousParameter',name))
    else
        name = valid_options{idx};
        
        switch name
            case 'WhitePoint'
                options.WhitePoint = images.color.internal.checkWhitePoint(varargin{k+1});
        end
    end    
end
catch e
    throwAsCaller(e);
end
