function B = imerode(A,se,varargin)
%IMERODE Erode image.
%   IM2 = IMERODE(IM,SE) erodes the grayscale or binary gpuArray image
%   IM, returning the eroded image, IM2 as a gpuArray. SE is a structuring
%   element object or an array of structuring element objects returned by
%   the STREL function.
%
%   If SE is an array of structuring element objects, IMERODE performs
%   multiple erosions, using each structuring element in SE in succession.
%
%   IM2 = IMERODE(IM,NHOOD) erodes the gpuArray image IM with the 
%   structuring element STREL(NHOOD), if NHOOD is an array of 0s and 1s 
%   that specifies the structuring element neighborhood, or 
%   STREL(GATHER(NHOOD)) if NHOOD is a gpuArray of 0s and 1s that specifies
%   the structuring element neighborhood. IMERODE determines the center 
%   element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2).
%
%   IM2 = IMERODE(...,SHAPE) determines the size of the output image.
%   SHAPE is a string that can have one of the following values. The
%   default value is enclosed in braces ({}).
%
%       {'same'}      Make the output image the same size as the input
%                     image. This is the default value.
%
%       'full'        Compute the full erosion.
%
%   Class Support
%   -------------
%   IM must be a gpuArray of type uint8 or logical. It can have any
%   dimension. The output has the same class as the input.
%
%   Notes
%   -----
%   1.  The structuring element must be flat and two-dimensional. If an 
%       array of structuring elements is passed, each structureing element 
%       must be flat and its neighborhood must be two-dimensional.
%   2.  Packed binary images are not supported on the GPU.
%
%   Examples
%   --------
%   Erode the binary image in text.png with a vertical line:
%
%       originalBW = imread('text.png');
%       se = strel('line',11,90);
%       erodedBW = imerode(gpuArray(originalBW),se);
%       figure, imshow(originalBW), figure, imshow(erodedBW)
%
%   Erode the grayscale image in cameraman.tif with a disk:
%
%       originalI = imread('cameraman.tif');
%       se = strel('disk',5);
%       erodedI = imerode(gpuArray(originalI),se);
%       figure, imshow(originalI), figure, imshow(erodedI)
%
%
%   See also BWHITMISS, BWPACK, BWUNPACK, GPUARRAY/CONV2, GPUARRAY/FILTER2,
%            GPUARRAY/IMCLOSE, GPUARRAY/IMDILATE, GPUARRAY/IMOPEN, STREL, 
%            GPUARRAY.

%   Copyright 2012-2013 The MathWorks, Inc.

if isa(A,'gpuArray')
    narginchk(2,3);
    B = morphop(A,se,'erode',mfilename,varargin{:});
else
    %dispatch to CPU.
    narginchk(2,5);
    args = {A se varargin{:}};
    args = gatherIfNecessary(args{:});
    B = imerode(args{:});
end    