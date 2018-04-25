function [M,P] = imgaborfilt(varargin)
%IMGABORFILT Apply Gabor filter or set of filters to 2-D image
% [MAG,PHASE] = imgaborfilt(A,WAVELENGTH,ORIENTATION) computes the
% magnitude and phase response of a Gabor filter with an input greyscale
% image A. WAVELENGTH describes the wavelength in pixels/cycle of the
% sinusoidal carrier. Valid values for WAVELENGTH are in the range [2,
% Inf). ORIENTATION is the orientation of the filter in degrees, where the
% orientation is defined as the normal direction to the sinusoidal plane
% wave. Valid values for ORIENTATION are in the range [0 360]. The output
% MAG and PHASE are the magnitude and phase responses of the Gabor filter.
%
% [MAG,PHASE] = imgaborfilt(A,WAVELENGTH,ORIENTATION,Name,Value,___)
% applies a single Gabor filter using name-value pairs to control various
% aspects of filtering.
%
%   Parameters include:
%
%   'SpatialFrequencyBandwidth' -   A numeric scalar that defines the
%                                   spatial-frequency bandwidth in units of
%                                   octaves. The spatial-frequency
%                                   bandwidth determines the cutoff of the
%                                   filter response as frequency content in
%                                   the input image varies from the
%                                   preferred frequency, 1/LAMBDA. Typical
%                                   values for spatial-frequency bandwidth
%                                   are in the range [0.5 2.5].
%
%                                   Default value: 1.0.
%
%   'SpatialAspectRatio' -          A numeric scalar that defines the ratio 
%                                   of the semi-major and semi-minor axes
%                                   of the gaussian envelope:
%                                   semi-minor/semi-major. This parameter
%                                   controls the ellipticity of the
%                                   gaussian envelope. Typical values for
%                                   spatial aspect ratio are in the range
%                                   [0.23 0.92].
%
%                                   Default value: 0.5.
%
% [MAG,PHASE] = imgaborfilt(A,gaborBank) applies an array of Gabor filters
% to A. gaborBank is a 1xP array of gabor objects that specifies a Gabor
% filter bank. MAG and PHASE are image stacks where each plane in the stack
% corresponds to one of the outputs of the filter bank. For inputs of size
% A, the outputs MAG and PHASE contain the magnitude and phase response for
% each filter in gaborBank and are of size MxNxP. Each plane in the
% magnitude and phase responses, MAG(:,:,ind),PHASE(:,:,ind), is the result
% of applying the Gabor filter of the same index, gaborBank(ind).
%
%   Class Support
%   -------------
%   The input image A must be a real, non-sparse, 2-D matrix of the
%   following classes: uint8, int8, uint16, int16, uint32, int32, single or
%   double.
%
%   Notes
%   -----
%   1. The range of ORIENTATION is [0 360] degrees because this function
%      uses a complex Gabor filter in the spatial domain which is not
%      conjugate symmetric in the frequency domain. If you are only
%      interested in Gabor magnitude response, the range of ORIENTATION can
%      be restricted to [0 180] degrees.
%
%   2. If the image A contains Infs or NaNs, the behavior of imgaborfilt
%      is undefined. This is because Gabor filtering is performed in the
%      frequency domain.
%
%   3. At the boundaries of the image where the convolution is not fully
%      defined, replication padding is used to reduce boundary artifacts.
%
%   4. For all input datatypes of A other than single, computation is
%      performed in double. Input images of type single are filtered in
%      type single. Performance optimizations may result from casting the
%      input image A to single prior to calling imgaborfilt.
%
%   Example 1
%   ---------
%   This example applies a Gabor filter bank of 2 orientations and 2
%   different wavelengths to an input image. The magnitude response is
%   shown for each filter. 
%
%   I = imread('cameraman.tif');
%   gaborBank = gabor([4 8],[0 90]);
%   gaborMag = imgaborfilt(I,gaborBank);
%   figure
%   subplot(2,2,1);
%   for p = 1:4
%       subplot(2,2,p)
%       imshow(gaborMag(:,:,p),[]);
%       theta = gaborBank(p).Orientation;
%       lambda = gaborBank(p).Wavelength;
%       title(sprintf('Orientation=%d, Wavelength=%d',theta,lambda));
%   end
%
%   Example 2
%   ---------
%   This example applies a single Gabor filter to an input image and obtains
%   the magnitude and phase response.
%
%   I = imread('board.tif');
%   I = rgb2gray(I);
%   wavelength = 4;
%   orientation = 90;
%   [mag,phase] = imgaborfilt(I,wavelength,orientation);
%   figure
%   subplot(1,3,1);
%   imshow(I);
%   title('Original Image');
%   subplot(1,3,2);
%   imshow(mag,[])
%   title('Gabor magnitude');
%   subplot(1,3,3);
%   imshow(phase,[]);
%   title('Gabor phase');
%
%   See also edge, gabor, imfilter, imgradient

% Copyright 2015, The MathWorks, Inc.

%   References:
%   -----------
%   [1] A. K. Jain and F. Farrokhnia, "Unsupervised Texture Segmentation
%   Using Gabor Filters", Pattern recognition, VOL. 24, ISSUE 12, DECEMBER
%   1991
%
%   [2] P. Kruizinga and N. Petkov, "Nonlinear Operator For Oriented
%   Texture", IEEE Transactions on Image Processing, VOL. 8, NO. 10,
%   OCTOBER 1999
%
%   [3] J. Daugman, "Uncertainty relation for resolution in space, spatial
%   frequency, and orientation optimized by two-dimensional visual cortical
%   filters", J. Opt. Soc. Am. A, VOL. 2, NO.7, JULY 1985


narginchk(2,inf)

[A,GaborBank] = parseInputs(varargin{:});
displayWaitBar = false;
[M,P] = images.internal.gaborFilterFFT(A,GaborBank,displayWaitBar);

end

function [A,GaborBank,displayWaitBar] = parseInputs(varargin)

displayWaitBar = false;

validateattributes(varargin{1},{'numeric'},{'2d','real','finite','nonsparse'},...
    mfilename,'A');

A = varargin{1};

if (nargin == 2)
    validateattributes(varargin{2},{'gabor'},{'vector'},mfilename,...
        'GaborBank');
    GaborBank = varargin{2};
else
    
    % Enforce that syntax: imgaborfilt(A,wavelength,orientation,___) must
    % have scalar valued property values. Let gabor class do rest of the
    % input validation.
    for i = 2:length(varargin)
       if isnumeric(varargin{i})
           validateattributes(varargin{i},{'numeric'},{'scalar'},mfilename)
       end
    end
    
    % Construct a gabor object to perform single gabor filter syntaxes:
    % [___] = imgaborfilt(A,WAVELEGTH,ORIENTATION,___)
    GaborBank = gabor(varargin{2:end});
end

end