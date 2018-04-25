function s = im2single(img, varargin) %#codegen
%IM2SINGLE Convert image to single precision.     
%   IM2SINGLE takes an image as input, and returns an image of class
%   single.  If the input image is of class single, the output image is
%   identical to it.  If the input image is not single, IM2SINGLE returns
%   the equivalent image of class single, rescaling or offsetting the data
%   as necessary.
%
%   I2 = IM2SINGLE(I1) converts the intensity image I1 to single precision,
%   rescaling the data if necessary.
%
%   RGB2 = IM2SINGLE(RGB1) converts the truecolor image RGB1 to
%   single precision, rescaling the data if necessary.
%
%   I = IM2SINGLE(BW) converts the binary image BW to a single-
%   precision intensity image.
%
%   X2 = IM2SINGLE(X1,'indexed') converts the indexed image X1 to
%   single precision, offsetting the data if necessary.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is single.
% 
%   Example
%   -------
%       I1 = reshape(uint8(linspace(1,255,25)),[5 5])
%       I2 = im2single(I1)
%  
%   See also IM2DOUBLE, IM2INT16, IM2UINT8, IM2UINT16, SINGLE.  

%   Copyright 1993-2015 The MathWorks, Inc.

narginchk(1,2);
validateattributes(img, {'double','logical','uint8','uint16','int16','single'}, ...
    {'nonsparse'}, mfilename,'Image',1); %#ok<*EMCA>

if nargin == 2
    validatestring(varargin{1}, {'indexed'}, mfilename, 'type', 2);
end

if isa(img, 'single')
    s = img;
    
elseif isa(img, 'logical') || isa(img, 'double')
    s = single(img);
    
elseif isa(img, 'uint8')
    if nargin==1
        s = single(img) / 255;
    else
        s = single(img)+1;
    end
    
elseif isa(img, 'uint16')
    if nargin==1
        s = single(img) / 65535;
    else
        s = single(img)+1;
    end    
    
else %int16
    if nargin == 1
        s = (single(img) + 32768) / 65535;
    else
        coder.internal.errorIf(true,'images:im2single:invalidIndexedImage');
    end
end
