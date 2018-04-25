function B = imbothat(A,SE)  %#codegen
%IMBOTHAT Bottom-hat filtering.
%   IM2 = IMBOTHAT(IM,SE) performs morphological bottom hat filtering on
%   the grayscale or binary input image, IM, using the structuring element
%   SE.  SE is a structuring element returned by the STREL function.  SE
%   must be a single structuring element object, not an array containing
%   multiple structuring element objects.
%
%   IM2 = IMBOTHAT(IM,NHOOD) performs morphological bottom hat filtering
%   where NHOOD is an array of 0s and 1s that specifies the size and
%   shape of the structuring element.  This is equivalent to
%   IMBOTHAT(IM,STREL(NHOOD)).
%
%   Class Support
%   -------------
%   IM can be numeric or logical and must be nonsparse.  The output image
%   has the same class as the input image.  If the input is binary
%   (logical), then the structuring element must be flat.
%
%   Example
%   -------
%   Tophat and bottom-hat filtering can be used together to enhance
%   contrast in an image.  The procedure is to add the original image to
%   the tophat-filtered image, and then subtract the bottom-hat-filtered
%   image.
%
%      original = imread('pout.tif');
%      se = strel('disk',3);
%      contrastFiltered = ...
%         imsubtract(imadd(original,imtophat(original,se)),...
%                          imbothat(original,se));
%      figure, imshow(original)
%      figure, imshow(contrastFiltered)
%
%   See also IMTOPHAT, STREL.

%   Copyright 1993-2017 The MathWorks, Inc.

% Testing notes
% =============
% IM     - N-D numeric nonsparse array
%          real
%          Inf's ok
%          NaN's ok for binary, but not allowed for grayscale
%          empty ok
%
% SE     - 1-by-1 STREL object or double array containing 0s and 1s.
%
% IM2    - same size as IM
%          uint8 logical if islogical(IM) & isflat(SE); otherwise same class
%          as IM.

validateattributes(A, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, ...
              'IM', 1);

SE = images.internal.strelcheck(SE,mfilename,'SE',2);

coder.internal.errorIf((islogical(A) && ~isflat(SE)), 'images:imtophat:binaryImageWithNonflatStrel');

if islogical(A)
    B = imclose(A,SE) & ~A;
else
    B = imclose(A,SE) -  A;
end
