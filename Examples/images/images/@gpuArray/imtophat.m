function B = imtophat(A,SE)
%IMTOPHAT Top-hat filtering.
%   IM2 = IMTOPHAT(IM,SE) performs morphological top hat filtering on the
%   grayscale or binary gpuArray image IM using the structuring element SE,
%   where SE is returned by STREL.  SE must be a single structuring
%   element object, not an array containing multiple structuring element
%   objects.
%
%   IM2 = IMTOPHAT(IM,NHOOD) performs morphological top hat filtering on 
%   the image IM with the structuring element STREL(NHOOD), if NHOOD is an 
%   array of 0s and 1s that specifies the structuring element neighborhood 
%   or STREL(GATHER(NHOOD)) if NHOOD is a gpuArray of 0s and 1s that 
%   specifies the structuring element neighborhood.
%
%   Class Support
%   -------------
%   IM must be a gpuArray of type uint8 or logical. It can have any
%   dimension. The output has the same class as the input.
%
%   Notes
%   -----
%   1.  The structuring element must be flat and two-dimensional.
%   2.  Packed binary images are not supported on the GPU.
%
%   Example
%   -------
%   Tophat filtering can be used to correct uneven illumination when the
%   background is dark.  This example uses tophat filtering with a disk to
%   remove the uneven background illumination from the rice.png image, and
%   then it uses imadjust and stretchlim to make the result more easily
%   visible.
%
%   original = imread('rice.png');
%   figure, imshow(original)
%   se = strel('disk',12);
%   tophatFiltered = imtophat(gpuArray(original),se);
%   figure, imshow(tophatFiltered)
%   contrastAdjusted = imadjust(gather(tophatFiltered));
%   figure, imshow(contrastAdjusted)
%
%   See also GPUARRAY/IMBOTHAT, STREL, GPUARRAY.

%   Copyright 2012-2015 The MathWorks, Inc.

% Testing notes
% =============
% IM     - N-D uint8, logical gpuArray
%          real
%          empty ok
%
% SE     - 1-by-1 STREL object or double array containing 0s and 1s or
%          gpuArray containing 0s and 1s.
%          must be flat and 2-D
%
% IM2    - same size as IM
%          same class as IM.

if islogical(A)
    B = A & ~imopen(A,SE);
else
    B = A - imopen(A,SE);
end
