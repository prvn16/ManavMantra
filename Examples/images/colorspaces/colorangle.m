function angle = colorangle(RGB1,RGB2)
%COLORANGLE Angle between two RGB vectors
%
%   angle = COLORANGLE(RGB1,RGB2) computes the angle in degrees between two
%   RGB vectors.
%
%   Class Support
%   -------------
%   RGB1 and RGB2 must be 1-by-3 vectors of one of the following classes:
%   uint8, uint16, single or double.
%
%   Note
%   ----
%   The angular error is a useful metric to evaluate the estimation of an
%   illuminant against the ground truth. The smaller the angle between the
%   ground truth illuminant and the estimated illuminant, the better the
%   estimate.
%
%   Example
%   -------
%   Compare illuminant estimation algorithms
%
%     % Open a test image. The image is the raw data captured with a Canon
%     % EOS 30D digital camera after having corrected the black level and
%     % scaled the intensities to 16 bits per pixel. No demosaicking, white
%     % balancing, color enhancement, noise filtering or gamma correction
%     % of any kind has been applied.
%     A = imread('foosballraw.tiff');
%
%     % Interpolate to obtain a color image. The Color Filter Array pattern
%     % of the Canon EOS 30D is RGGB.
%     A_demosaicked = demosaic(A,'rggb');
%
%     % The image contains a ColorChecker Chart. The ground truth
%     % illuminant has been calculated using the neutral patches
%     % of the chart.
%     illuminant_groundtruth = [0.0717 0.1472 0.0975];
%
%     % To avoid skewing the estimation of the illuminant the ColorChecker
%     % Chart should be excluded. Create a mask excluding the chart.
%     mask = true(size(A_demosaicked,1), size(A_demosaicked,2));
%     mask(920:1330,1360:1900) = false;
%
%     % Run three different illuminant estimation algorithms.
%     illuminant_whitepatch = illumwhite(A_demosaicked,'Mask',mask);
%     illuminant_grayworld = illumgray(A_demosaicked,'Mask',mask);
%     illuminant_cheng = illumpca(A_demosaicked,'Mask',mask);
%
%     % Compare each estimation against the ground truth by calculating
%     % the angle between each estimated illuminant and the ground truth.
%     % The smaller the angle, the better the estimation. The magnitude
%     % of the estimation does not matter as only the direction of the
%     % illuminant is used to white balance an image with chromatic
%     % adaptation.
%     angle_whitepatch = colorangle(illuminant_whitepatch, illuminant_groundtruth);
%     angle_grayworld = colorangle(illuminant_grayworld, illuminant_groundtruth);
%     angle_cheng = colorangle(illuminant_cheng, illuminant_groundtruth);
%
%     fprintf('Color angle for White Patch: %f deg\n', angle_whitepatch);
%     fprintf('Color angle for Gray World: %f deg\n', angle_grayworld);
%     fprintf('Color angle for Cheng''s PCA method: %f deg\n', angle_cheng);
%
%   See also CHROMADAPT, ILLUMGRAY, ILLUMPCA, ILLUMWHITE.

%   Copyright 2016 The MathWorks, Inc.

f = @(x,n) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty','vector','numel',3}, ...
    mfilename,['RGB' num2str(n)],n);

% illuminant
f(RGB1,1);

% reference
f(RGB2,2);

if ~isa(RGB1, class(RGB2))
    error(message('images:validate:differentClassMatrices','RGB1','RGB2'));
end

RGB1 = im2double(RGB1(:));
RGB2 = im2double(RGB2(:));
N1 = norm(RGB1);
N2 = norm(RGB2);
if isequal(RGB1,RGB2)
    angle = 0;
else
    angle = acos(RGB1' * RGB2 / (N1 * N2));
    angle = 180 / pi * angle;
end
