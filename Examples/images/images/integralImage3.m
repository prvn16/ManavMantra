function intVolume = integralImage3(I)
%integralImage3 Compute upright 3-D integral image.
%   J = integralImage3(I) computes integral image of a 3-D intensity image
%   I. The output integral image, J, is zero padded on top, left and along
%   the first plane, resulting in size(J) = size(I) + 1. This facilitates
%   easy computation of pixel sums along all image boundaries. Integral
%   image, J, is essentially a padded version of
%   CUMSUM(CUMSUM(CUMSUM(I),2),3).
%
%   Class Support
%   -------------
%   Intensity image I can be any numeric class of 3 dimensions. The class
%   of output integral volume, J, is double.
%
%   Example
%   -------
%   % Compute the integral image and use it to compute sum of pixels
%   % over a sub-volume in I.
%   I = reshape(1:125,5,5,5);
%   
%   % define a 3x3x3 sub-volume as
%   % [startRow, startCol, startPlane, endRow, endCol, endPlane]
%   [sR, sC, sP, eR, eC, eP] = deal(2, 2, 2, 4, 4, 4);
% 
%   % compute the sum over a 3x3x3 sub-volume of I
%   J = integralImage3(I);
%   regionSum = J(eR+1,eC+1,eP+1) - J(eR+1,eC+1,sP) - J(eR+1,sC,eP+1) ...
%       - J(sR,eC+1,eP+1) + J(sR,sC,eP+1) + J(sR,eC+1,sP) ... 
%       + J(eR+1,sC,sP) -J(sR,sC,sP)
%
%   % verify that the sum of pixels is accurate
%   sum(sum(sum(I(sR:eR, sC:eC, sP:eP))))
%   
%
%   See also integralImage,integralBoxFilter3.

%   Copyright 2014-2015 The MathWorks, Inc.

validateattributes(I, {'numeric','logical'}, {'3d', 'nonsparse', 'real'},...
    'integralImage3', 'I');

if ~isempty(I)
    
    if ismatrix(I)
        outputSize = [size(I) 1] + 1;
        intVolume = zeros(outputSize);
        intVolume(:,:,2) = integralimagemex(I);
    else
        outputSize = size(I) + 1;
        intVolume = zeros(outputSize);
        intVolume(:, :, 2:end) = cumsum(integralimagemex(I),3);
    end
else
    intVolume = [];
end
