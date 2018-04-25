function d = im2double(img, varargin) %#codegen
%IM2DOUBLE Convert image to double precision.
%   IM2DOUBLE takes an image as input, and returns an image of class double.  If
%   the input image is of class double, the output image is identical to it.  If
%   the input image is not double, IM2DOUBLE returns the equivalent image of
%   class double, rescaling or offsetting the data as necessary.
%
%   I2 = IM2DOUBLE(I1) converts the intensity image I1 to double
%   precision, rescaling the data if necessary.
%
%   RGB2 = IM2DOUBLE(RGB1) converts the truecolor image RGB1 to
%   double precision, rescaling the data if necessary.
%
%   I = IM2DOUBLE(BW) converts the binary image BW to a double-
%   precision intensity image.
%
%   X2 = IM2DOUBLE(X1,'indexed') converts the indexed image X1 to
%   double precision, offsetting the data if necessary.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is double.
%
%   Example
%   -------
%       I1 = reshape(uint8(linspace(1,255,25)),[5 5])
%       I2 = im2double(I1)
%
%   See also DOUBLE.

%   Copyright 1993-2014 The MathWorks, Inc.

narginchk(1,2);
validateattributes(img,{'double','logical','uint8','uint16','int16','single'},{}, ...
    mfilename,'Image',1);

if nargin == 2
    validatestring(varargin{1}, {'indexed'}, mfilename, 'type', 2);
end

if isa(img, 'double')
    d = img;
    
elseif isa(img, 'logical') || isa(img, 'single')
    d = double(img);
    
elseif isa(img, 'uint8')
    if nargin==1
        d = double(img) / 255;
    else
        d = double(img)+1;
    end
    
elseif isa(img, 'uint16')
    if nargin==1
        d = double(img) / 65535;
    else
        d = double(img)+1;
    end    
    
else %int16
    if nargin == 1
        d = (double(img) + 32768) / 65535;
    else
        coder.internal.errorIf(true,'MATLAB:images:im2double:invalidIndexedImage', 'single, or logical.');
    end
end
