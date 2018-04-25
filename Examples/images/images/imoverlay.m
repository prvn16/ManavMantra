function B = imoverlay(A,BW,colorSpec)
%IMOVERLAY Burn binary mask into a 2-D image.
%   B = IMOVERLAY(A,BW) fills the input image with a solid color where the
%   input binary mask, BW, is true. The input image A may be grayscale or
%   RGB.
%
%   B = IMOVERLAY(___,COLOR) burns a binary image into the input image
%   using a COLOR specified by a valid MATLAB ColorSpec. For example, valid
%   specifications of a red fill color are: 'red','r', and [1 0 0].
%
%   Class Support
%   ------------- 
%   The input image A is a 2-D matrix of type uint8, uint16, single,
%   double, logical, or int16. The input mask BW is a binary image of the
%   same size as A. The output image B is of class 'uint8'.
%
%   Example
%   -------
%   A = imread('cameraman.tif');
%   BW = imread('text.png');
%   B = imoverlay(A,BW,'yellow');
%   figure
%   imshow(B)
%
%   See also boundarymask, superpixels

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(2,3);

validateattributes(A,{'uint8','uint16','single','double','logical','int16'},...
                   {'nonsparse','real'},mfilename,'A');
               
validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
if ~(ismatrix(A) || validColorImage)
    error(message('images:validate:invalidImageFormat','Input image A'));
end
               
validateattributes(BW,cat(2,'logical',images.internal.iptnumerictypes()),...
                   {'nonsparse','real','2d'},mfilename,'BW');

if ((size(A,1) ~= size(BW,1)) || (size(A,2) ~= size(BW,2)))
   error(message('images:validate:unequalNumberOfRowsAndCols','A','BW')); 
end

A = im2uint8(A);
if ismatrix(A)
    A = repmat(A,[1 1 3]);
end

sizeA = size(A);
sizeA = sizeA(1:2);

BW = BW~=0;
               
if (nargin < 3)
    colorSpec = 'yellow';
end
colorSpec = matlab.images.internal.stringToChar(colorSpec);

rgbFill = convertColorSpec(images.internal.ColorSpecToRGBConverter,colorSpec);
rgbFill = im2uint8(rgbFill);
rgbFill = reshape(rgbFill,[1 1 3]);
rgbFill = repmat(rgbFill,[sizeA,1]);

BW = repmat(BW,[1 1 3]);
B = zeros(size(A),'like',A);
B(BW)  = rgbFill(BW);
B(~BW) = A(~BW); 

end
