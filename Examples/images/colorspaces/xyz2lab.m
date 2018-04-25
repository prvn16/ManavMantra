function lab = xyz2lab(xyz,varargin)
% xyz2lab Convert CIE 1931 XYZ to CIE 1976 L*a*b*
%
%    lab = xyz2lab(xyz)
%
%    lab = xyz2lab(xyz,Name,Value)
%
%    lab = xyz2lab(xyz) converts CIE 1931 XYZ values to CIE 1976 L*a*b* values. xyz can be a P-by-3 matrix of
%    color values (one color per row), or it can an M-by-N-by-3 image array, or it can be an
%    M-by-N-by-3-by-F image stack. The type of xyz can be single or double. The output has the same
%    shape and type as the input.
%
%    lab = xyz2lab(xyz,Name,Value) specifies additional options with one or more Name,Value pair
%    arguments.
%
%    NAME-VALUE PAIR ARGUMENTS
%
%    'WhitePoint' - Reference white point
%                   1-by-3 vector | 'a' | 'c' | 'd50' | 'd55' | 'd65' (default) | 'icc' | 'e'
%
%    EXAMPLES
%
%    Convert an XYZ color to L*a*b*.
%
%        xyz2lab([0.25 0.40 0.10])
%
%    Convert an XYZ color to L*a*b* using D50 as the reference white point.
%
%        xyz2lab([0.25 0.40 0.10],'WhitePoint','d50')
%
%    See also lab2xyz, rgb2lab, lab2rgb, rgb2xyz, xyz2rgb

%    Copyright 2014-2017 The MathWorks, Inc.

validateattributes(xyz,{'single','double'},{'real'},mfilename,'XYZ',1)

args = matlab.images.internal.stringToChar(varargin);
options = parseInputs(args{:});

converter = images.color.xyzToLABConverter(options.WhitePoint);
converter.OutputType = 'float';

lab = converter(xyz);

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
