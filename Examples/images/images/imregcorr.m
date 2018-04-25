function tform = imregcorr(varargin)
%IMREGCORR Register two 2-D images using phase correlation.
%
%   TFORM = IMREGCORR(MOVING, FIXED) estimates the geometric tansformation
%   that aligns the moving image MOVING with the fixed image FIXED. The
%   output TFORM is a geometric transformation object that maps MOVING to
%   FIXED.
%
%   TFORM = IMREGCORR(MOVING, FIXED, TRANSFORMTYPE) estimates the
%   geometric transformation that aligns the moving image MOVING with the
%   fixed image FIXED. TRANSFORMTYPE is a string that defines the type of
%   transformation to estimate. The default TRANSFORMTYPE is 'similarity'.
%
%   TRANSFORMTYPE is a string specifying one of the following geometric
%   transform types:
%
%      TRANSFORMTYPE         TYPES OF DISTORTION
%      -------------         -----------------------
%      'translation'         Translation
%      'rigid'               Translation, Rotation
%      'similarity'          Translation, Rotation, Scale
%
%   TFORM = IMREGCORR(MOVING,RMOVING,FIXED,RFIXED,___) estimates
%   the geometric transformation that aligns the spatially referenced image
%   defined by MOVING and RMOVING with the spatially referenced image
%   defined by FIXED and RFIXED. The output TFORM defines the point mapping
%   in the world coordinate system.
%
%   TFORM = IMREGCORR(___,Name, Value,...) registers the moving image
%   to the fixed image using name-value pairs to control various aspects of
%   the registration algorithm.
%
%   Parameters include:
%                      
%      'Window' -     A scalar logical specifying whether windowing is used
%                     to suppress spectral leakage effects in the frequency
%                     domain. When 'Window' is true, a Blackman window
%                     is used to increase the stability of registration
%                     results. If the common features you are trying to
%                     align in your images are oriented along the edges,
%                     setting 'Window' to false will sometimes provide
%                     superior registration results.
%
%                     Default value: true
%
%     Notes
%     -----
%     1. When using the 'similarity' option, the phase correlation
%     algorithm is only scale invariant within some range of scale
%     difference between the fixed and moving images. IMREGCORR limits the
%     search space to scale differences within the range (1/4,4). Scale
%     differences less than 1/4 or greater than 4 cannot be detected by
%     IMREGCORR.
%
%     2. If RGB images are provided for fixed or moving, the inputs are
%     pre-processed with rgb2gray to convert to intensity images.
%
%     3. Input images of type double will cause the algorithm to compute FFTs
%     in double. You can achieve performance improvements by casting double
%     images to single with im2single prior to registration.
%
%     Class Support
%     -------------
%     MOVING and FIXED are numeric arrays. MOVING and FIXED can be
%     grayscale, logical, or RGB. The output TFORM is a geometric transformation
%     object.
%
% Example
% ---------
% This example solves a registration problem in which the cameraman image
% is synthetically scaled and rotated.
%
% fixed  = imread('cameraman.tif');
% theta = 20;
% S = 2.3;
% tform = affine2d([S.*cosd(theta) -S.*sind(theta) 0; S.*sind(theta) S.*cosd(theta) 0; 0 0 1]);
% moving = imwarp(fixed,tform);
% moving = moving + uint8(10*rand(size(moving)));
%
% tformEstimate = imregcorr(moving,fixed);
%
% figure, imshowpair(fixed,moving,'montage');
%
% % Apply estimated geometric transform to moving. Specify 'OutputView' to
% % get registered moving image that is the same size as the fixed image.
% Rfixed = imref2d(size(fixed));
% movingReg = imwarp(moving,tformEstimate,'OutputView',Rfixed);
%
% figure, imshowpair(fixed,movingReg,'montage');
% figure, imshowpair(fixed,movingReg,'falsecolor');
%
% See also IMREGISTER, IMREGTFORM, IMSHOWPAIR, IMWARP, registrationEstimator.

%   Copyright 2013-2016 The MathWorks, Inc.

%   References:
%   -----------
%   [1] B. S. Reddy and B. N. Chatterji, "An FFT-Based Technique for
%   Translation, Rotation, and Scale-Invariant Image Registration",
%   IEEE Transactions On Image Processing, VOL. 5, NO. 8, AUGUST 1996

narginchk(2,inf)

[moving,fixed,transformationType,windowing,Rmoving,Rfixed] = parseInputs(varargin{:});

% FFT2 is fastest for single inputs. Work in single unless double precision
% floating point data was specified.
if ~isa(moving,'double')
    moving = single(moving);
end

if ~isa(fixed,'double')
    fixed = single(fixed);
end

switch (transformationType)
    
    case 'translation'
        [tform,peak] = findTranslation(moving,fixed,windowing);
    case 'rigid'
        [tform,peak] = findRigid(moving,fixed,windowing);
    case 'similarity'
        [tform,peak] = findSimilarity(moving,fixed,windowing);
    otherwise
        assert('Unexpected transformationType.');
        
end

spatialReferencingSpecified = ~isempty(Rmoving);
if spatialReferencingSpecified
    tform = moveTransformationToWorldCoordinateSystem(tform,Rmoving,Rfixed);
end

% Use peak correlation threshold suggested in (Reddy,Chatterji). If peak
% correlation during translation recovery is less than 0.03, provide
% warning.
if peak < 0.03
    warning(message('images:imregcorr:weakPeakCorrelation'));
end

end %end imregcorr

%-----------------------------------------------------------------------
function [M,F] = getFourierMellinSpectra(moving,fixed,windowing)

% Move Moving and Fixed into frequency domain
M_size = size(moving);
F_size = size(fixed);
outsize = M_size + F_size - 1;

% Apply windowing function to moving and fixed to reduce aliasing in
% frequency domain.
moving = manageWindowing(moving,windowing);
fixed  = manageWindowing(fixed,windowing);

% Obtain the spectra of moving and fixed: M and F.
M = fft2(moving,outsize(1),outsize(2));
F = fft2(fixed,outsize(1),outsize(2));

% Shift DC of fft to center
F = fftshift(F);
M = fftshift(M);

% Form Magnitude Spectra
F = abs(F);
M = abs(M);

% Apply High-Pass Emphasis filter to each image (Reddy, Chatterji)
H = createHighPassEmphasisFilter(outsize);

F = F .* H;
M = M .* H;

end


%----------------------------------------------------------------
function [tform,peak] = solveForTranslationGivenScaleAndRotation(moving,fixed,S,theta,windowing)
% There is a 180 degree ambiguity in theta solved in R,Theta space. This
% ambiguity stems from the conjugate symmetry of the Fourier spectrum for real
% valued input images.
%
% This function resolves the ambiguity by forming two resampled versions of moving
% rotated by theta, theta+180, phase correlating each version of the
% resampled image with fixed, and choose the S,Theta that has the highest
% final peak correlation during recovery of translation.
%
% We save 1 FFT2 operation at full scale with the following
% optimizations:
%
% 1) By directly performing the phase correlation here instead of calling
% phasecorr/findTranslationPhaseCorr directly, we save 1 FFT operation by
% not computing the spectra of fixed twice.

theta1 = theta;
theta2 = theta+pi;

tform1 = affine2d([S.*cos(theta1) -S.*sin(theta1) 0; S.*sin(theta1) S.*cos(theta1) 0; 0 0 1]);
tform2 = affine2d([S.*cos(theta2) -S.*sin(theta2) 0; S.*sin(theta2) S.*cos(theta2) 0; 0 0 1]);

[scaledRotatedMoving1,RrotatedScaled1] = imwarp(moving,tform1,'SmoothEdges', true);

scaledRotatedMoving1 = manageWindowing(scaledRotatedMoving1,windowing);

% This step is equivalent to: 
%   [scaledRotatedMoving2,RrotatedScaled2] = imwarp(moving,tform2)
% We do this to gain efficiency in computing scaledRotatedMoving2,
scaledRotatedMoving2 = rot90(scaledRotatedMoving1,2);
RrotatedScaled2 = imref2d(size(scaledRotatedMoving1),...
                          sort(-RrotatedScaled1.XWorldLimits),...
                          sort(-RrotatedScaled1.YWorldLimits));

% Form 2-D spectra associated with scaledRotatedMoving1, scaledRotatedMoving2, and fixed.
size_moving  = size(scaledRotatedMoving1);
size_fixed  = size(fixed);
outSize = size_moving + size_fixed - 1;
M1 = fft2(scaledRotatedMoving1,outSize(1),outSize(2));
F  = fft2(fixed,outSize(1),outSize(2));
M2 = fft2(scaledRotatedMoving2,outSize(1),outSize(2));

% Form the phase correlation matrix d1 for M1 correlated with F.
ABConj = F .* conj(M1);
d1 = ifft2(ABConj ./ abs(eps+ABConj),'symmetric');

% Form the phase correlation matrix d2 for M2 correlated with F.
ABConj = F .* conj(M2);
d2 = ifft2(ABConj ./ abs(eps+ABConj),'symmetric');

% Find the translation vector that aligns scaledRotatedMoving1 with fixed and
% scaledRotatedMoving2 with fixed. Choose S,theta,translation estimate that has
% the highest peak correlation in the final translation recovery step.
[vec1,peak1] = findTranslationPhaseCorr(d1);
[vec2,peak2] = findTranslationPhaseCorr(d2);

if peak1 >= peak2
    vec = vec1;
    tform = tform1;
    RrotatedScaled = RrotatedScaled1;
    peak = peak1;
else
    vec = vec2;
    tform = tform2;
    RrotatedScaled = RrotatedScaled2;
    peak = peak2;
end

% The scale/rotation operation performed prior to the final
% phase-correlation step results in a translation. The translation added
% during scaling/rotation is defined by RrotatedScaled. Form the final
% effective translation by summing the translation added during
% rotation/scale to the translation recovered in the final translation
% step.
finalXOffset  = vec(1) + (RrotatedScaled.XIntrinsicLimits(1)-RrotatedScaled.XWorldLimits(1));
finalYOffset  = vec(2) + (RrotatedScaled.YIntrinsicLimits(1)-RrotatedScaled.YWorldLimits(1));

tform.T(3,1:2) = [finalXOffset, finalYOffset];

end

%--------------------------------------------------------------
function [tform,peak] = findTranslation(moving,fixed,windowing)

moving = manageWindowing(moving,windowing);
fixed  = manageWindowing(fixed,windowing);

[vec,peak] = findTranslationPhaseCorr(moving,fixed);
tform = affine2d([1, 0, 0; 0, 1, 0; vec(1), vec(2), 1]);

end

%------------------------------------------------------------------------
function [tform,peak] = findRigid(moving,fixed,windowing)

% A nice block diagram of the pure rigid algorithm appears in:
%   Y Keller, "Pseduo-polar based estimation of large translations rotations and
%   scalings in images", Application of Computer Vision, 2005. WACV/MOTIONS
%   2005 Volume 1. 
%
% This follows directly from the derivation in Reddy, Chatterji.

% Move Moving and Fixed into frequency domain
[M,F] = getFourierMellinSpectra(moving,fixed,windowing);

thetaRange = [0 pi];
Fpolar = images.internal.Polar(F,thetaRange);
Mpolar = images.internal.Polar(M,thetaRange);

Fpolar.resampledImage = manageWindowing(Fpolar.resampledImage,windowing);
Mpolar.resampledImage = manageWindowing(Mpolar.resampledImage,windowing);

% Solve a 1-D phase correlation problem to resolve theta. We already know
% scale. Choose a 1-D profile in our Polar FFT grid parallel to the theta axis.
numSamplesRho = size(Fpolar.resampledImage,1);
rhoCenter = round(0.5+numSamplesRho/2);
vec = findTranslationPhaseCorr(Mpolar.resampledImage(rhoCenter,:),Fpolar.resampledImage(rhoCenter,:));

% Translation vector is zero based. We want to translate vector
% into one based intrinsic coordinates within the polar grid.
thetaIntrinsic = abs(vec(1))+1;
% We passed a vector to findTranslationPhaseCorr;
rhoIntrinsic   = 1;

% The translation vector implies intrinsic coordinates in the
% Fixed/Moving log-polar grid. We want to convert these intrinsic
% coordinate locations into world coordinates that tell us
% rho/theta.
[theta,~] = intrinsicToWorld(Fpolar,thetaIntrinsic,rhoIntrinsic);

% Use sign of correlation offset to figure out whether rotation
% is positive or negative.
theta = -sign(vec(1))*theta;

% By definition, Scale is 1 for a rigid transformation.
S = 1;

[tform,peak] = solveForTranslationGivenScaleAndRotation(moving,fixed,S,theta,windowing);

end

%------------------------------------------------------------------------------
function [tform,peak] = findSimilarity(moving,fixed,windowing)

% Move Moving and Fixed into frequency domain
[M,F] = getFourierMellinSpectra(moving,fixed,windowing);

% (Reddy,Chatterji) recommends taking advantage of the conjugate
% symmetry of the Fourier-Mellin spectra. All of the unique
% spectral information is in the interval [0,pi].
thetaRange = [0 pi];
Fpolar = images.internal.LogPolar(F,thetaRange);
Mpolar = images.internal.LogPolar(M,thetaRange);

% Use phase-correlation to determine the translation within the
% log-polar resampled Fourier-Mellin spectra that aligns moving
% with fixed.
Fpolar.resampledImage = manageWindowing(Fpolar.resampledImage,windowing);
Mpolar.resampledImage = manageWindowing(Mpolar.resampledImage,windowing);

% Obtain full phase correlation matrix
d = phasecorr(Fpolar.resampledImage,Mpolar.resampledImage);

% Constrain our search in D to the range 1/4 < S < 4.
d = suppressCorrelationOutsideScale(d,Fpolar,4);

% Find the translation vector in log-polar space.
vec = findTranslationPhaseCorr(d);

% Translation vector is zero based. We want to translate vector
% into one based intrinsic coordinates within the log-polar grid.
thetaIntrinsic = abs(vec(1))+1;
rhoIntrinsic   = abs(vec(2))+1;

% The translation vector implies intrinsic coordinates in the
% Fixed/Moving log-polar grid. We want to convert these intrinsic
% coordinate locations into world coordinates that tell us
% rho/theta.
[theta,rho] = intrinsicToWorld(Fpolar,thetaIntrinsic,rhoIntrinsic);

% Use sign of correlation offset to figure out whether rotation
% is positive or negative.
theta = -sign(vec(1))*theta;

% Use sign of correlation offset to figure out whether or not to invert scale factor
S = rho .^ -sign(vec(2));

[tform,peak] = solveForTranslationGivenScaleAndRotation(moving,fixed,S,theta,windowing);

end

%-----------------------------------------------------------
function d = suppressCorrelationOutsideScale(d,Fpolar,scale)
% This function takes a phase correlation matrix that relates the same
% sized log-polar grids Fpolar and Mpolar. We return a phase correlation
% matrix in which we set regions of the phase correlation matrix outside
% the symmetric range (1/scale, scale) to -Inf. This allows us to limit the
% search space of the phase correlation matrix during peak detection so
% that we will never find peaks that correspond to a scale value outside of
% the limits of scale.

[~,logRhoIndex] = worldToIntrinsic(Fpolar,0,scale);
logRhoIndex = floor(logRhoIndex);

% Create mask that is false where S is outside the range (1/scale,scale).
phaseCorrMask = false(size(d));
phaseCorrMask((logRhoIndex+1):(end-logRhoIndex+1),:) = true;

% Constrain our search in D to the range 1/scale < S < scale.
d(phaseCorrMask) = 0;

end

function tform = moveTransformationToWorldCoordinateSystem(tform,Rmoving,Rfixed)
% If spatial referencing is specified, we want to output the forward
% transformation that maps points in the world coordinate system of the
% fixed image to points in the world coordinate system of the moving
% image. To accomplish this, observe that the following sequence of
% operations can be used to map world points in moving to world points in
% fixed using a transformation defined in the intrinsic system:
%
% pointsMovingWorld -> tMovingWorldToIntrinsic ->
% tMovingIntrinsicToFixedIntrinsic -> tFixedIntrinsicToWorld
%
%  tMovingIntrinsicToFixedIntrinsic is the output of phase correlation in
% the intrinsic coordinate system.
%
% tMovingWorldToIntrinsic and tFixedIntrinsicToWorld are formed from
% the spatial referencing information in Rmoving,Rfixed.

Sx = Rmoving.PixelExtentInWorldX;
Sy = Rmoving.PixelExtentInWorldY;
Tx = Rmoving.XWorldLimits(1)-Rmoving.PixelExtentInWorldX*(Rmoving.XIntrinsicLimits(1));
Ty = Rmoving.YWorldLimits(1)-Rmoving.PixelExtentInWorldY*(Rmoving.YIntrinsicLimits(1));
tMovingIntrinsicToWorld = [Sx 0 0; 0 Sy 0; Tx Ty 1];
tMovingWorldToIntrinsic = inv(tMovingIntrinsicToWorld);

Sx = Rfixed.PixelExtentInWorldX;
Sy = Rfixed.PixelExtentInWorldY;
Tx = Rfixed.XWorldLimits(1)-Rfixed.PixelExtentInWorldX*(Rfixed.XIntrinsicLimits(1));
Ty = Rfixed.YWorldLimits(1)-Rfixed.PixelExtentInWorldY*(Rfixed.YIntrinsicLimits(1));
tFixedIntrinsicToWorld = [Sx 0 0; 0 Sy 0; Tx Ty 1];

tMovingIntrinsicToFixedIntrinsic = tform.T;

tComposite = tMovingWorldToIntrinsic * tMovingIntrinsicToFixedIntrinsic * tFixedIntrinsicToWorld; %#ok<MINV>
% We only touch the affine elements of the matrix. Small amounts of
% numeric error can cause the third column to drift from being
% strictly [0;0;1], which is strictly enforced by the set of
% affine2d.
tform.T(1:3,1:2) = tComposite(1:3,1:2);

end

%--------------------------------------------
function img = manageWindowing(img,windowing)

if windowing
    img = img .* createBlackmanWindow(size(img));
end

end

%--------------------------------------------
function h = createBlackmanWindow(windowSize)
% Define Blackman window to reduce finite image replication effects in
% frequency domain. Blackman window is recommended in (Stone, Tao,
% McGuire, Analysis of image registration noise due to rotationally
% dependent aliasing).

M = windowSize(1);
N = windowSize(2);

a0 = 7938/18608;
a1 = 9240/18608;
a2 = 1430/18608;

n = 1:N;
m = 1:M;

% Make outer product degenerate if M or N is equal to 1.
h1 = 1;
h2 = 1;
if M > 1
    h1 = a0 - a1*cos(2*pi*m / (M-1)) + a2*cos(4*pi*m / (M-1));
end
if N > 1
    h2 = a0 - a1*cos(2*pi*n / (N-1)) + a2*cos(4*pi*n / (N-1));
end

h = h1' * h2;

end

%---------------------------------------------
function H = createHighPassEmphasisFilter(outsize)
% Defines High-Pass emphasis filter used in Reddy and Chatterji

numRows = outsize(1);
numCols = outsize(2);

x = linspace(-0.5,0.5,numCols);
y = linspace(-0.5,0.5,numRows);

[x,y] = meshgrid(x,y);

X = cos(pi*x).*cos(pi*y);

H = (1-X).*(2-X);

end

%----------------------------------------------------------------------
function [moving,fixed,transformType,windowing,Rmoving,Rfixed] = parseInputs(varargin)

parser = inputParser();
parser.addRequired('moving',@validateMoving);
parser.addRequired('fixed',@validateFixed);
parser.addOptional('transformType','similarity',@validateTransformType)
parser.addParameter('window',true,@validateWindowing)

supportedImageClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'};
supportedImageAttributes = {'real','nonsparse','finite'};

% Use function scope variable to cache specified transformType in
% case user provided partial name.
fullTransformType = '';

[Rmoving,Rfixed,varargin] = preparseSpatialRefObjects(varargin{:});

parser.parse(varargin{:});

moving        = parser.Results.moving;
fixed         = parser.Results.fixed;
windowing     = parser.Results.window;

if ~isempty(fullTransformType)
    % The validation function for the optional argument is not run
    % unless a user actually specifes the transformType. We only
    % want/need to partial string complete in this case.
    transformType = fullTransformType;
else
    transformType = parser.Results.transformType;
end

% If we receive a dimensional image and the size of the third
% dimension is 3, we assume we have been given an RGB image. We
% rgb2gray convert so that we can provide a transformation estimate
% based on a grayscale interpretation of the image data.
isRGB = @(img) (ndims(img) == 3) && (size(img,3) == 3);
if isRGB(moving)
    moving = rgb2gray(moving);
end

if isRGB(fixed)
    fixed = rgb2gray(fixed);
end

% Make sure that input image dimensions agree with any specified spatial
% referencing objects.
if ~isempty(Rmoving)
    validateSpatialReferencingAgreementWithImage(moving,Rmoving,'moving');
    validateSpatialReferencingAgreementWithImage(fixed,Rfixed,'fixed');
end

    %---------------------------------
    function TF = validateFixed(fixed)
        
        validateattributes(fixed,supportedImageClasses,supportedImageAttributes,...
            mfilename,'FIXED');
        
        if ndims(fixed) > 3
            error(message('images:imregcorr:invalidImageSize','FIXED'));
        end
        
        TF = true;
        
    end

    %---------------------------------
    function TF = validateMoving(moving)
        
        validateattributes(moving,supportedImageClasses,supportedImageAttributes,...
            mfilename,'MOVING');
        
        if ndims(moving) > 3
            error(message('images:imregcorr:invalidImageSize','MOVING'));
        end
        
        TF = true;
        
    end

    %---------------------------------------------
    function TF = validateTransformType(tformType)
        
        fullTransformType = validatestring(tformType,{'translation','rigid','similarity'},...
            mfilename,'TRANSFORMTYPE');
        
        TF = true;
        
    end

    %-----------------------------------------------
    function TF = validateWindowing(window)
        
        validateattributes(window,{'logical','numeric'},{'scalar','finite','nonsparse'},...
            mfilename,'Windowing');
        
        TF = true;
        
    end


    %--------------------------------------------------------------------
    function validateSpatialReferencingAgreementWithImage(A,RA,inputName)
        
        if ~sizesMatch(RA,A)
            error(message('images:imregcorr:spatialRefAgreementWithImage','ImageSize',inputName,inputName));
        end
                
    end

    %-----------------------------------------------------------------------
    function [Rmoving,Rfixed,varargin] = preparseSpatialRefObjects(varargin)
        
        spatialRefPositions   = cellfun(@(c) isa(c,'imref2d'), varargin);
        
        Rmoving = [];
        Rfixed  = [];
        
        if ~any(spatialRefPositions)
            return
        end
        
        if ~isequal(find(spatialRefPositions), [2 4])
            error(message('images:imregcorr:spatialRefPositions'));
        end
        
        if isa(varargin{2},'imref3d') || isa(varargin{4},'imref3d')
            error(message('images:imregcorr:spatialRefMustBe2D'));
        end
        
        Rmoving = varargin{2};
        Rfixed = varargin{4};
        varargin([2 4]) = [];
        
    end

end
