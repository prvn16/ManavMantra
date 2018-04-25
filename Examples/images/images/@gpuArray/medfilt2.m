function b = medfilt2(varargin)
%MEDFILT2 2-D median filtering.
%   B = MEDFILT2(A,[M N]) performs median filtering of the gpuArray matrix
%   A in two dimensions. Each output pixel contains the median value in the
%   M-by-N neighborhood around the corresponding pixel in the input image.
%   MEDFILT2 pads the image with zeros on the edges, so the median values
%   for the points within [M N]/2 pixels of any image edge may appear
%   distorted.
%
%   B = MEDFILT2(A) performs median filtering of the gpuArray matrix A
%   using the default 3-by-3 neighborhood.
%
%   Class Support
%   -------------
%   The input gpuArray image A can be logical or numeric.  The output image
%   B is of the same underlying class as A.
%
%   Remarks
%   -------
%   The GPU implementation of this function only supports square 
%   neighborhoods with odd side length between 3 and 15.
%
%   Example
%   -------
%       I = gpuArray(imread('eight.tif'));
%       J = imnoise(I,'salt & pepper',0.02);
%       K = medfilt2(J);
%       figure, imshow(J), figure, imshow(K)
%
%   See also GPUARRAY/FILTER2, ORDFILT2, WIENER2, GPUARRAY.

%   Copyright 2013-2016 The MathWorks, Inc.

if (nargin == 1)
    b = images.internal.gpu.medfilt2(varargin{1}, [3 3]);
else
    b = images.internal.gpu.medfilt2(varargin{:});
end
