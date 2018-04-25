function B = imdilate(A,se,varargin)
%IMDILATE Dilate image.
%   IM2 = IMDILATE(IM,SE) dilates the grayscale or binary gpuArray image
%   IM, returning the dilated image, IM2 as a gpuArray. SE is a structuring
%   element object or an array of structuring element objects returned by
%   the STREL function.
%
%   If SE is an array of structuring element objects, IMDILATE performs
%   multiple dilations, using each structuring element in SE in succession.
%
%   IM2 = IMDILATE(IM,NHOOD) dilates the gpuArray image IM with the 
%   structuring element STREL(NHOOD), if NHOOD is an array of 0s and 1s 
%   that specifies the structuring element neighborhood, or 
%   STREL(GATHER(NHOOD)) if NHOOD is a gpuArray of 0s and 1s that specifies
%   the structuring element neighborhood. IMDILATE determines the center 
%   element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2).
%
%   IM2 = IMDILATE(...,SHAPE) determines the size of the output image.
%   SHAPE is a string that can have one of the following values. The
%   default value is enclosed in braces ({}).
%
%       {'same'}      Make the output image the same size as the input
%                     image. This is the default value.
%
%       'full'        Compute the full dilation.
%
%   Class Support
%   -------------
%   IM must be a gpuArray of type uint8 or logical. It can have any
%   dimension. The output has the same class as the input.
%
%   Notes
%   -----
%   1.  The structuring element must be flat and two-dimensional. If an 
%       array of structuring elements is passed, each structuring element 
%       must be flat and two-dimensional.
%   2.  Packed binary images are not supported on the GPU.
%
%   Examples
%   --------
%   Dilate the binary image in text.png with a vertical line:
%
%       originalBW = imread('text.png');
%       se = strel('line',11,90);
%       dilatedBW = imdilate(gpuArray(originalBW),se);
%       figure, imshow(originalBW), figure, imshow(dilatedBW)
%
%   Dilate the grayscale image in cameraman.tif with a disk:
%
%       originalI = imread('cameraman.tif');
%       se = strel('disk',5);
%       dilatedI = imdilate(gpuArray(originalI),se);
%       figure, imshow(originalI), figure, imshow(dilatedI)
%
%   See also BWHITMISS, BWPACK, BWUNPACK, GPUARRAY/CONV2, GPUARRAY/FILTER2,
%            GPUARRAY/IMCLOSE, GPUARRAY/IMERODE, GPUARRAY/IMOPEN, STREL,
%            GPUARRAY.

%   Copyright 2012-2014 The MathWorks, Inc.

if isa(A,'gpuArray')
    narginchk(2,3);
    B = morphop(A,se,'dilate',mfilename,varargin{:});
else
    %dispatch to CPU.
    narginchk(2,4);
    args = {A se varargin{:}};
    args = gatherIfNecessary(args{:});
    B = imdilate(args{:});
end
