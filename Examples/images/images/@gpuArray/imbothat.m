function B = imbothat(A,SE)
%IMBOTHAT Bottom-hat filtering.
%   IM2 = IMBOTHAT(IM,SE) performs morphological bottom hat filtering on
%   the grayscale or binary gpuArray image, IM, using the structuring 
%   element SE.  SE is a structuring element returned by the STREL
%   function. SE must be a single structuring element object, not an array 
%   containing multiple structuring element objects.
%
%   IM2 = IMBOTHAT(IM,NHOOD) performs morphological bottom hat filtering
%   on the gpuArray image IM with the structuring element STREL(NHOOD), if 
%   NHOOD is an array of 0s and 1s that specifies the structuring element 
%   neighborhood or STREL(GATHER(NHOOD)) if NHOOD is a gpuArray of 0s and 
%   1s that specifies the structuring element neighborhood.
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
%   Tophat and bottom-hat filtering can be used together to enhance
%   contrast in an image.  The procedure is to add the original image to
%   the tophat-filtered image, and then subtract the bottom-hat-filtered
%   image.
%
%      original = gpuArray(imread('pout.tif'));
%      se = strel('disk',3);
%      contrastFiltered = ...
%      (original+imtophat(original,se))-imbothat(original,se);
%      figure, imshow(original)
%      figure, imshow(contrastFiltered)
%
%   See also GPUARRAY/IMTOPHAT, STREL.

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
%          as IM.


if islogical(A)
    B = imclose(A,SE) & ~A;
else
    B = imclose(A,SE) - A;
end
