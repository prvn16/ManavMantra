function [D,movingReg] = imregdemons(moving,fixed,varargin)
%IMREGDEMONS Estimate displacement field that aligns two 2-D or 3-D images.
%
%   [D,MOVING_REG] = IMREGDEMONS(MOVING,FIXED) estimates the displacement
%   field gpuArray D that aligns the moving image in gpuArray MOVING with
%   the fixed image in gpuArray FIXED. MOVING and FIXED are 2-D or 3-D
%   intensity images. For a 2-D registration problem with a FIXED image of
%   size MxN, the output displacement field D is a double matrix of size
%   MxNx2 in which D(:,:,1) contains X displacements and D(:,:,2) contains
%   Y displacements with magnitude values in units of pixels.  For a 3-D
%   registration problem with a FIXED image of size MxNxP, the output
%   displacement field D is a double matrix of size MxNxPx3 in which
%   D(:,:,:,1) contains X displacements, D(:,:,:,2) contains Y
%   displacements, and D(:,:,:,3) contains Z displacements with magnitude
%   values in units of pixels.  The displacement vectors at each pixel
%   location map locations from the FIXED image grid to a corresponding
%   location in the MOVING image. MOVING_REG is a gpuArray which contains a
%   warped version of the MOVING image that is warped by D and resampled
%   using linear interpolation.
%
%   [___] = IMREGDEMONS(MOVING,FIXED,N) estimates the displacement field D
%   that aligns the moving image, MOVING, with the fixed image, FIXED. The
%   optional third input argument, N, controls the number of iterations
%   that will be computed. If N is not specified, a default value of 100
%   iterations is used at each pyramid level. This function does not use a
%   convergence criterion and therefore is always guaranteed to run for the
%   specified or default number of iterations, N. N must be integer valued
%   and greater than 0.
%
%   D = IMREGDEMONS(___,NAME,VALUE) registers the
%   moving image using name-value pairs to control aspects of the
%   registration.
%
%   Parameters include:
%
%      'AccumulatedFieldSmoothing'  -   Standard deviation of the Gaussian
%                                       smoothing applied to regularize the
%                                       accumulated field at each
%                                       iteration. This parameter controls
%                                       the amount of diffusion-like
%                                       regularization. Larger values will
%                                       result in more smooth output
%                                       displacement fields. Smaller values
%                                       will result in more localized
%                                       deformation in the output
%                                       displacement field.
%                                       AccumulatedFieldSmoothing is
%                                       typically in the range [0.5, 3.0].
%                                       When multiple PyramidLevels are
%                                       used, the standard deviation used
%                                       in Gaussian smoothing remains the
%                                       same at each pyramid level.
%
%                                           Default: 1.0.
%
% Example
% ---------
% This example solves a registration problem in which the same hand has
% been photographed in two different poses. The misalignment of the images
% varies locally throughout each image. This is therefore a non-rigid
% registration problem.
%
% fixed  = imread('hands1.jpg');
% moving = imread('hands2.jpg');
%
% % Observe initial misalignment. Fingers are in different poses.
% figure
% imshowpair(fixed,moving,'montage')
% figure
% imshowpair(fixed,moving)
%
% fixedGPU  = gpuArray(fixed);
% movingGPU = gpuArray(moving);
%
% fixedGPU  = rgb2gray(fixedGPU);
% movingGPU = rgb2gray(movingGPU);
%
% % Use histogram matching to correct illumination differences between
% % moving and fixed. This is a common pre-processing step.
% fixedHist = imhist(fixedGPU);
% movingGPU = histeq(movingGPU,fixedHist);
%
% [~,movingReg] = imregdemons(movingGPU,fixedGPU,[500 400 200],'AccumulatedFieldSmoothing',1.3);
%
% % Bring movingReg back to CPU
% movingReg = gather(movingReg);
% 
% figure
% imshowpair(fixed,movingReg)
% figure
% imshowpair(fixed,movingReg,'montage')
%
% See also IMREGCORR, IMREGISTER, IMREGTFORM, IMSHOWPAIR, IMWARP.
 
%   Copyright 2014-2017 The MathWorks, Inc.
 
%   References:
%   -----------
%   [1] J.-P. Thirion, "Image matching as a diffusion process: an analogy
%   with Maxwell's demons", Medical Image Analysis, VOL. 2, NO. 3, 1998
%
%   [2] T. Vercauteren, X. Pennec, A. Perchant, N. Ayache, "Diffeomorphic
%   Demons: Efficient Non-parametric Image Registration", NeuroImage, VOL.
%   45, ISSUE 1, SUPPLEMENT 1, MARCH 2009

narginchk(2,inf);

[moving,fixed] = validateInputImages(moving,fixed);

is3DProblem = ~ismatrix(fixed);

args     = matlab.images.internal.stringToChar(varargin);
varargin = gatherIfNecessary(args{:});

options = images.registration.internal.parseOptionalDemonsInputs(varargin{:});

images.registration.internal.validatePyramiding(moving,fixed,options.PyramidLevels);

classMoving = classUnderlying(moving);

% Do intermediate math in double precision floating point.
fixed  = double(fixed);
moving = double(moving);

%   Check if image is 2D or 3D
if is3DProblem
    [D, movingReg] = multiResolutionDemons3d(moving,fixed,options,classMoving);
else
    [D, movingReg] = multiResolutionDemons2d(moving,fixed,options,classMoving);
end

end


function [D, movingReg] = multiResolutionDemons3d(moving,fixed,options,classMoving)

if (options.PyramidLevels > 1)

    [fixed,padVec]  = images.registration.internal.padForPyramiding(fixed,options.PyramidLevels);
    moving = images.registration.internal.padForPyramiding(moving,options.PyramidLevels);
    
    % Initialize accumulated field
    sizeFixed = size(fixed);
    Da_x = gpuArray.zeros(sizeFixed);
    Da_y = gpuArray.zeros(sizeFixed);
    Da_z = gpuArray.zeros(sizeFixed);

    % As an initialization, we have to move the initial condition of the
    % accumulated field to the resolution of the lowest resolution section
    % of the pyramid.
    Da_x = resampleFieldComponentByScaleFactor(Da_x,0.5^(options.PyramidLevels-1));
    Da_y = resampleFieldComponentByScaleFactor(Da_y,0.5^(options.PyramidLevels-1));
    Da_z = resampleFieldComponentByScaleFactor(Da_z,0.5^(options.PyramidLevels-1));

    for p = 1:options.PyramidLevels

        % Form the downsampled image grids for the current resolution
        % level.
        movingAtLevel = downsampleFromFullResToPyramidLevel(moving,p,options.PyramidLevels);
        fixedAtLevel  = downsampleFromFullResToPyramidLevel(fixed,p,options.PyramidLevels);

        if p > 1
            % Upsample the displacement field estimate for use in the next
            % resolution level.
            Da_x = resampleFieldComponentByScaleFactor(Da_x,2);
            Da_y = resampleFieldComponentByScaleFactor(Da_y,2);              
            Da_z = resampleFieldComponentByScaleFactor(Da_z,2);

        end

        % Solve displacement field at current resolution level.
        [Da_x,Da_y,Da_z] = demons3d(movingAtLevel,fixedAtLevel,options.NumIterations(p),...
             options.AccumulatedFieldSmoothing,Da_x,Da_y,Da_z);

    end

    % Trim accumulated field pixels that are artifacts of padding used in
    % pyramiding.
    Da_x = trimPaddingFromOutputFieldComponent(Da_x,padVec);
    Da_y = trimPaddingFromOutputFieldComponent(Da_y,padVec);
    Da_z = trimPaddingFromOutputFieldComponent(Da_z,padVec);
    moving = trimPaddingFromOutputFieldComponent(moving,padVec);

else
    % Initialize accumulated field
    sizeFixed = size(fixed);
    Da_x = gpuArray.zeros(sizeFixed);
    Da_y = gpuArray.zeros(sizeFixed);
    Da_z = gpuArray.zeros(sizeFixed);
    [Da_x,Da_y,Da_z] = demons3d(moving,fixed,options.NumIterations,...
         options.AccumulatedFieldSmoothing,Da_x,Da_y,Da_z);
end

D = cat(4,Da_x,Da_y,Da_z);

if nargout > 1
    movingReg = resampleMovingWithEdgeSmoothing3d(moving,Da_x,Da_y,Da_z);  
    
    % Return output resampled image in a datatype consistent with the input moving image.    
    movingReg = cast(movingReg,classMoving);
end

end

function [Da_x,Da_y,Da_z] = demons3d(moving,fixed,N,sigma,Da_x,Da_y,Da_z)

% Cache plaid representation of fixed image grid.
sizeFixed = size(fixed);
xIntrinsicFixed = gpuArray.colon(1,sizeFixed(2));
yIntrinsicFixed = gpuArray.colon(1,sizeFixed(1));
zIntrinsicFixed = gpuArray.colon(1,sizeFixed(3));
[xIntrinsicFixed,yIntrinsicFixed,zIntrinsicFixed] = meshgrid(xIntrinsicFixed,yIntrinsicFixed,zIntrinsicFixed);

% Initialize gradient of F for passive force Thirion Demons
[FgradX,FgradY,FgradZ] = gradient(fixed);
FgradMagSquared = FgradX.^2+FgradY.^2+FgradZ.^2;

% Function scoped broadcast variables for use in zeroUpdateThresholding
IntensityDifferenceThreshold = 0.001;
DenominatorThreshold = 1e-9;

for i = 1:N
    
    movingWarped = interp3(moving,...
                    xIntrinsicFixed + Da_x,...
                    yIntrinsicFixed + Da_y,...
                    zIntrinsicFixed + Da_z,...
                    'linear',...
                    NaN);

   [Da_x,Da_y,Da_z] = arrayfun(@computeUpdateFieldAndComposeWithAccumulatedField3d,fixed,FgradX,FgradY,FgradZ,FgradMagSquared,movingWarped,Da_x,Da_y,Da_z);             
          
    % Regularize vector field by gaussian smoothing.
    r = ceil(3*sigma);
    d = 2*r+1;    
    Da_x = imgaussfilt3(Da_x, sigma, 'FilterSize', d);
    Da_y = imgaussfilt3(Da_y, sigma, 'FilterSize', d);
    Da_z = imgaussfilt3(Da_z, sigma, 'FilterSize', d);

end

    function [Da_x,Da_y,Da_z] = computeUpdateFieldAndComposeWithAccumulatedField3d(fixed,FgradX,FgradY,FgradZ,FgradMagSquared,movingWarped,Da_x,Da_y,Da_z)
        
    FixedMinusMovingWarped = fixed-movingWarped;
    denominator =  (FgradMagSquared + FixedMinusMovingWarped.^2);
    
    % Compute additional displacement field - Thirion
    directionallyConstFactor = FixedMinusMovingWarped ./ denominator;
    Du_x = directionallyConstFactor .* FgradX;
    Du_y = directionallyConstFactor .* FgradY;
    Du_z = directionallyConstFactor .* FgradZ; 

    if (denominator < DenominatorThreshold) |...
            (abs(FixedMinusMovingWarped) < IntensityDifferenceThreshold) |...
            isnan(FixedMinusMovingWarped) %#ok<OR2>
        
        Du_x = 0;
        Du_y = 0;
        Du_z = 0;
        
    end
    
    % Compute total displacement vector - additive update
    Da_x = Da_x + Du_x;
    Da_y = Da_y + Du_y;
    Da_z = Da_z + Du_z;
    end

end

function out = antialiasResize(in,factor,varargin)

% Implement a volumetric resize function that applies a second order
% low-pass butterworth filter to the input image. The cutoff of the filter
% is chosen based on the resize scale factor to limit aliasing effects.

classIn = classUnderlying(in);

if factor == 1
    out = in;
    return
elseif factor < 1
    
    % Move to Frequency domain.
    I = fftshift(fftn(in));
    
    % Construct low-pass filter with cutoff based on scale factor.
    H = butterwth(0.5*factor,2,size(in));
    
    % Obtain low-pass filtered version of input spatial domain volume
    in = ifftn(ifftshift(I.*H),'symmetric');    
end

%   Mimic imwarp functionality
if ~strcmp(classIn,'double')
    in = double(in);
end

% Apply scale transform of input volume
ImageSize = size(in);
NewImageSize = round(ImageSize*factor);

% Define coordinate system for output image
Rout = imref3d(NewImageSize);

% Define affine transformation that maps from intrinsic system of
% output image to world system of output image.

T = [factor 0 0 0; 0 factor 0 0; 0 0 factor 0; 0 0 0 1];

Tx = Rout.XIntrinsicLimits(1)*factor-Rout.XIntrinsicLimits(1);
Ty = Rout.YIntrinsicLimits(1)*factor-Rout.YIntrinsicLimits(1);
Tz = Rout.ZIntrinsicLimits(1)*factor-Rout.ZIntrinsicLimits(1);

tIntrinsictoWorldOutput = [1 0 0 0; 0 1 0 0; 0 0 1 0; Tx Ty Tz 1];

tComp = tIntrinsictoWorldOutput / T;
tComp(:,4) = [0; 0; 0; 1];

% Form plaid grid of intrinsic points in output image.
[dstXIntrinsic,dstYIntrinsic,dstZIntrinsic] = meshgrid(gpuArray.colon(1,Rout.ImageSize(2)),...
    gpuArray.colon(1,Rout.ImageSize(1)),...
    gpuArray.colon(1,Rout.ImageSize(3)));

uvwvec = gpuArray.zeros([numel(dstXIntrinsic),4]);

% CPU code of following code block:
% uvwvec(:,1) = dstXIntrinsic(:);
% uvwvec(:,2) = dstYIntrinsic(:);
% uvwvec(:,3) = dstZIntrinsic(:);
% uvwvec(:,4) = ones(numel(dstXIntrinsic),1);
uvwvec = subsasgn(uvwvec,substruct('()',{':',1}),subsref(dstXIntrinsic,substruct('()',{':'})));
uvwvec = subsasgn(uvwvec,substruct('()',{':',2}),subsref(dstYIntrinsic,substruct('()',{':'})));
uvwvec = subsasgn(uvwvec,substruct('()',{':',3}),subsref(dstZIntrinsic,substruct('()',{':'})));
uvwvec = subsasgn(uvwvec,substruct('()',{':',4}),subsref(gpuArray.ones(numel(dstXIntrinsic),1),substruct('()',{':'})));

xyzvec = uvwvec*tComp;

srcXIntrinsic = gpuArray.zeros(length(xyzvec),1);
srcYIntrinsic = gpuArray.zeros(length(xyzvec),1);
srcZIntrinsic = gpuArray.zeros(length(xyzvec),1);

% CPU code of following code block:
% srcXIntrinsic = xyzvec(:,1);
% srcYIntrinsic = xyzvec(:,2);
% srcZIntrinsic = xyzvec(:,3);
srcXIntrinsic = subsasgn(srcXIntrinsic,substruct('()',{':',1}),subsref(xyzvec,substruct('()',{':',1})));
srcYIntrinsic = subsasgn(srcYIntrinsic,substruct('()',{':',1}),subsref(xyzvec,substruct('()',{':',2})));
srcZIntrinsic = subsasgn(srcZIntrinsic,substruct('()',{':',1}),subsref(xyzvec,substruct('()',{':',3})));

% Pad array to expand domain for interpolation at edges
pad = 3;
paddedImage = padarray(in,[pad pad,pad]);
srcXIntrinsic = srcXIntrinsic+pad;
srcYIntrinsic = srcYIntrinsic+pad;
srcZIntrinsic = srcZIntrinsic+pad;

out = interp3(paddedImage,srcXIntrinsic,srcYIntrinsic,srcZIntrinsic,'linear');
out = reshape(out,NewImageSize);
out = cast(out,classIn);

end

function [D, movingReg] = multiResolutionDemons2d(moving,fixed,options,classMoving)

if (options.PyramidLevels > 1)

    [fixed,padVec]  = images.registration.internal.padForPyramiding(fixed,options.PyramidLevels);
    moving = images.registration.internal.padForPyramiding(moving,options.PyramidLevels);
    
    % Initialize accumulated field
    sizeFixed = size(fixed);
    Da_x = gpuArray.zeros(sizeFixed);
    Da_y = gpuArray.zeros(sizeFixed);

    % As an initialization, we have to move the initial condition of the
    % accumulated field to the resolution of the lowest resolution section
    % of the pyramid.
    Da_x = resampleFieldComponentByScaleFactor(Da_x,0.5^(options.PyramidLevels-1));
    Da_y = resampleFieldComponentByScaleFactor(Da_y,0.5^(options.PyramidLevels-1));

    for p = 1:options.PyramidLevels

        % Form the downsampled image grids for the current resolution
        % level.
        movingAtLevel = downsampleFromFullResToPyramidLevel(moving,p,options.PyramidLevels);
        fixedAtLevel  = downsampleFromFullResToPyramidLevel(fixed,p,options.PyramidLevels);

        if p > 1
            % Upsample the displacement field estimate for use in the next
            % resolution level.
            Da_x = resampleFieldComponentByScaleFactor(Da_x,2);
            Da_y = resampleFieldComponentByScaleFactor(Da_y,2);
        end

        % Solve displacement field at current resolution level.
        [Da_x,Da_y] = demons2d(movingAtLevel,fixedAtLevel,options.NumIterations(p),...
            options.AccumulatedFieldSmoothing,Da_x,Da_y);  
    end

    % Trim accumulated field pixels that are artifacts of padding used in
    % pyramiding.
    Da_x = trimPaddingFromOutputFieldComponent(Da_x,padVec);
    Da_y = trimPaddingFromOutputFieldComponent(Da_y,padVec);
    moving = trimPaddingFromOutputFieldComponent(moving,padVec);

else
    % Initialize accumulated field
    sizeFixed = size(fixed);
    Da_x = gpuArray.zeros(sizeFixed);
    Da_y = gpuArray.zeros(sizeFixed);
    [Da_x,Da_y] = demons2d(moving,fixed,options.NumIterations,...
        options.AccumulatedFieldSmoothing,Da_x,Da_y);   
end

D = cat(3,Da_x,Da_y);

if nargout > 1
    movingReg = resampleMovingWithEdgeSmoothing2d(moving,Da_x,Da_y);
    
    % Return output resampled image in a datatype consistent with the input moving image.    
    movingReg = cast(movingReg,classMoving); 
end
    
end

function [Da_x,Da_y] = demons2d(moving,fixed,N,sigma,Da_x,Da_y)

% Cache plaid representation of fixed image grid.
sizeFixed = size(fixed);
xIntrinsicFixed = gpuArray.colon(1,sizeFixed(2));
yIntrinsicFixed = gpuArray.colon(1,sizeFixed(1));
[xIntrinsicFixed,yIntrinsicFixed] = meshgrid(xIntrinsicFixed,yIntrinsicFixed);

% Initialize Gaussian filtering kernel
r = ceil(3*sigma);
d = 2*r+1;
hGaussian = gpuArray(fspecial('gaussian',[d d],sigma));

% Initialize gradient of F for passive force Thirion Demons
[FgradX,FgradY] = imgradientxy(fixed,'CentralDifference');
FgradMagSquared = FgradX.^2+FgradY.^2;

% Function scoped broadcast variables for use in zeroUpdateThresholding
IntensityDifferenceThreshold = 0.001;
DenominatorThreshold = 1e-9;

for i = 1:N
    
    movingWarped = interp2(moving,...
                    xIntrinsicFixed + Da_x,...
                    yIntrinsicFixed + Da_y,...
                    'linear',...
                    NaN);
    
   [Da_x,Da_y] = arrayfun(@computeUpdateFieldAndComposeWithAccumulatedField,fixed,FgradX, FgradY, FgradMagSquared, movingWarped,Da_x,Da_y);             
                
    % Regularize vector field by gaussian smoothing.
    Da_x = imfilter(Da_x, hGaussian,'replicate');
    Da_y = imfilter(Da_y, hGaussian,'replicate');
    
end

    function [Da_x, Da_y] = computeUpdateFieldAndComposeWithAccumulatedField(fixed,FgradX, FgradY, FgradMagSquared, movingWarped,Da_x,Da_y)
        
    FixedMinusMovingWarped = fixed-movingWarped;
    denominator =  (FgradMagSquared + FixedMinusMovingWarped.^2);
    
    % Compute additional displacement field - Thirion
    directionallyConstFactor = FixedMinusMovingWarped ./ denominator;
    Du_x = directionallyConstFactor .* FgradX;
    Du_y = directionallyConstFactor .* FgradY;       
    
    if (denominator < DenominatorThreshold) |...
            (abs(FixedMinusMovingWarped) < IntensityDifferenceThreshold) |...
            isnan(FixedMinusMovingWarped) %#ok<OR2>
        
        Du_x = 0;
        Du_y = 0;
        
    end
    
    % Compute total displacement vector - additive update
    Da_x = Da_x + Du_x;
    Da_y = Da_y + Du_y;
    
    end

end

function smoothedOutputImage = resampleMovingWithEdgeSmoothing3d(moving,Da_x,Da_y,Da_z)

sizeFixed = size(Da_x);
xIntrinsicFixed = gpuArray.colon(1,sizeFixed(2));
yIntrinsicFixed = gpuArray.colon(1,sizeFixed(1));
zIntrinsicFixed = gpuArray.colon(1,sizeFixed(3));
[xIntrinsicFixed,yIntrinsicFixed,zIntrinsicFixed] = meshgrid(xIntrinsicFixed,yIntrinsicFixed,zIntrinsicFixed);

Uintrinsic = xIntrinsicFixed + Da_x + 1;
Vintrinsic = yIntrinsicFixed + Da_y + 1;
Wintrinsic = zIntrinsicFixed + Da_z + 1;
smoothedOutputImage = interp3(padarray(moving,[1 1 1]),Uintrinsic,Vintrinsic,Wintrinsic,'linear',0);

end

function smoothedOutputImage = resampleMovingWithEdgeSmoothing2d(moving,Da_x,Da_y)

sizeFixed = size(Da_x);
xIntrinsicFixed = gpuArray.colon(1,sizeFixed(2));
yIntrinsicFixed = gpuArray.colon(1,sizeFixed(1));
[xIntrinsicFixed,yIntrinsicFixed] = meshgrid(xIntrinsicFixed,yIntrinsicFixed);

Uintrinsic = xIntrinsicFixed + Da_x + 1;
Vintrinsic = yIntrinsicFixed + Da_y + 1;
smoothedOutputImage = interp2(padarray(moving,[1 1]),Uintrinsic,Vintrinsic,'linear',0);

end

function out = trimPaddingFromOutputFieldComponent(in,padVec)

if ismatrix(in)
    out = subsref(in,substruct('()',{gpuArray.colon(1,size(in,1)-padVec(1)),gpuArray.colon(1,size(in,2)-padVec(2))}));
else
    out = subsref(in,substruct('()',{gpuArray.colon(1,size(in,1)-padVec(1)),gpuArray.colon(1,size(in,2)-padVec(2)),gpuArray.colon(1,size(in,3)-padVec(3))}));
end

end

function B = downsampleFromFullResToPyramidLevel(A,level,numLevels)

imageScaleFactor = 0.5 .^ (numLevels-level);

if ~ismatrix(A)
    B = antialiasResize(A,imageScaleFactor);
else
    B = imresize(A,imageScaleFactor,'cubic');
end

end

function Dout = resampleFieldComponentByScaleFactor(Din,scaleFactor)

if ~ismatrix(Din)
    Dout = antialiasResize(Din,scaleFactor);
else
    Dout = imresize(Din,scaleFactor,'cubic');
end

% Now adjust for relative scale difference in displacement
% magnitudes
Dout = Dout .* scaleFactor;

end

function H = butterwth(Do,n,outsize)

numRows = outsize(1);
numCols = outsize(2);
numPlanes = outsize(3);

% Define normalized frequency mesh grid
u = createNormalizedFrequencyVector(numCols);
v = createNormalizedFrequencyVector(numRows);
w = createNormalizedFrequencyVector(numPlanes);
[U,V,W] = meshgrid(u,v,w);

D = sqrt(U.^2+V.^2+W.^2);

H = 1 ./ (1 + (D./Do).^(2*n));

end

function u = createNormalizedFrequencyVector(N)

if mod(N,2)
    u = linspace(-0.5+1/(2*N),0.5-1/(2*N),N);
else
    u = linspace(-0.5,0.5-1/N,N); 
end

end

function [moving,fixed] = validateInputImages(moving,fixed)

supportedImageClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'};
supportedImageAttributes = {'real','finite','nonempty'};

moving = gpuArray(moving);
fixed  = gpuArray(fixed);

hValidateAttributes(moving,supportedImageClasses,supportedImageAttributes,...
    mfilename,'MOVING',1);

hValidateAttributes(fixed,supportedImageClasses,supportedImageAttributes,...
    mfilename,'FIXED',2);

hasInvalidNumberOfDimensions = @(im) ndims(im) < 2 || ndims(im) > 3;
if hasInvalidNumberOfDimensions(fixed) || hasInvalidNumberOfDimensions(moving);
    error(message('images:imregdemons:onlyTwoDOrThreeDAllowed','MOVING','FIXED'));
end

if ~isequal(ndims(moving),ndims(fixed))
    error(message('images:imregdemons:movingFixedDifferentDim','MOVING','FIXED'));
end

end