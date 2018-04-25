function [dfield,moving_reg] = imregdemons(moving,fixed,varargin)
%IMREGDEMONS Estimate displacement field that aligns two 2-D or 3-D images.
%
%   [D,MOVING_REG] = IMREGDEMONS(MOVING,FIXED) estimates the displacement
%   field D that aligns the moving image, MOVING, with the fixed image,
%   FIXED. MOVING and FIXED can be 2-D or 3-D intensity images. For a 2-D
%   registration problem with a FIXED image of size MxN, the output
%   displacement field D is a double matrix of size MxNx2 in which D(:,:,1)
%   contains X displacements and D(:,:,2) contains Y displacements with
%   magnitude values in units of pixels. For a 3-D registration problem
%   with a FIXED image size of MxNxP, the output displacement field D is a
%   double matrix of size MxNxPx3 in which D(:,:,:,1) contains X
%   displacements, D(:,:,:,2) contains Y displacements, and D(:,:,:,3)
%   contains Z displacements in units of pixels. The displacement vectors
%   at each pixel location map locations from the FIXED image grid to a
%   corresponding location in the MOVING image. MOVING_REG is a warped
%   version of the MOVING image that is warped by D and resampled using
%   linear interpolation.
%
%   [___] = IMREGDEMONS(MOVING,FIXED,N) estimates the displacement field D
%   that aligns the moving image, MOVING, with the fixed image, FIXED. The
%   optional third input argument, N, controls the number of iterations
%   that will be computed. If N is not specified, a default value of 100
%   iterations is used at each pyramid level. This function does not use a
%   convergence criterion and therefore is always guaranteed to run for the
%   specified or default number of iterations, N. N must be integer valued
%   and greater than 0. When P PyramidLevels are used, N can also be a
%   vector of length P in which the vector specifies the number of
%   iterations to perform at each resolution level, [N1, N2,...,NP], where
%   N1 represents the number of iterations at the lowest resolution level
%   of the pyramid and NP represents the number of iterations at the full
%   resolution of MOVING and FIXED. For example, if PyramidLevels = 3 and N
%   = [100,50,25], then 100 iterations will be run at the lowest resolution
%   level of the pyramid, 50 iterations will be run at the next level of
%   the pyramid, and 25 iterations will be run at the full resolution of
%   MOVING and FIXED. Because the lower resolution levels of the pyramid
%   take less time to run per iteration, a good speed vs. quality tradeoff
%   can sometimes be achieved by running more iterations at low resolution
%   and fewer iterations at the higher resolution sections of the pyramid.
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
%      'PyramidLevels'              -   The number of multi-resolution image pyramid
%                                       levels to use. 
%
%                                           Default: 3.
%
%      'DisplayWaitbar'             -   A logical scalar. When set to true,
%                                       IMREGDEMONS displays a waitbar to
%                                       indicate progress. To prevent
%                                       IMREGDEMONS from displaying a
%                                       waitbar, set DisplayWaitbar to
%                                       false.
%                   
%                                           Default: true.
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
% fixed  = rgb2gray(fixed);
% moving = rgb2gray(moving);
%
% % Observe initial misalignment. Fingers are in different poses.
% figure
% imshowpair(fixed,moving,'montage')
% figure
% imshowpair(fixed,moving)
% 
% % Use histogram matching to correct illumination differences between
% % moving and fixed. This is a common pre-processing step.
% moving = imhistmatch(moving,fixed);
% 
% [~,movingReg] = imregdemons(moving,fixed,[500 400 200],'AccumulatedFieldSmoothing',1.3);
% 
% figure
% imshowpair(fixed,movingReg)
% figure
% imshowpair(fixed,movingReg,'montage')
%
% See also IMREGISTER, IMREGTFORM, IMSHOWPAIR, IMWARP, registrationEstimator.

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

args = matlab.images.internal.stringToChar(varargin);
options = images.registration.internal.parseOptionalDemonsInputs(args{:});

images.registration.internal.validatePyramiding(moving,fixed,options.PyramidLevels);

% We don't allow mixed 2-D/3-D case, so it is safe to just check
% dimensionality of problem based on fixed image.
is2DProblem = ismatrix(fixed);
if is2DProblem
    
    demons = images.registration.internal.MultiResolutionDemons2D(moving,fixed,...
        options.AccumulatedFieldSmoothing,...
        options.PyramidLevels);

else
    demons = images.registration.internal.MultiResolutionDemons3D(moving,fixed,...
        options.AccumulatedFieldSmoothing,...
        options.PyramidLevels);
end

[demons,userCancelled] = runMultiResolutionDemons(demons,options);

if userCancelled
    [dfield,moving_reg] = deal([]);
else
    
    dfield = demons.D;
    
    % Only form output resampled image if it is requested
    if nargout > 1
        moving_reg = imwarp(moving,dfield,'SmoothEdges', true);
    end
    
end

end


function [demons,userCancelled] = runMultiResolutionDemons(demons, options)

numIterations  = options.NumIterations;
pyramidLevels  = options.PyramidLevels;
displayWaitBar = options.DisplayWaitbar;

userCancelled = false;

if(displayWaitBar)
    waitBar = waitBarFactory(numIterations,1,pyramidLevels);
    % In case of Ctrl+C with graphical waitbar.
    cleanup_waitbar = onCleanup(@() destroy(waitBar));
end


for pyramidLevel = 1:pyramidLevels
                
    if pyramidLevel > 1 && displayWaitBar
	% This is necessary to prevent text based waitbar from displaying 1st pyramid level information twice
    	refreshWaitBarForPyramidLevel(waitBar,pyramidLevel,pyramidLevels,numIterations(pyramidLevel));
    end
    
    demons = demons.moveToPyramidLevel(pyramidLevel);
                   
    for n = 1:numIterations(pyramidLevel)
        demons = demons.iterate(1);
        if(displayWaitBar)
            update(waitBar,n)
            if waitBar.isCancelled
                userCancelled = true;
                return
            end
        end
        
    end
    
end

end

function refreshWaitBarForPyramidLevel(waitBar,pyramidLevel,totalPyramidLevels,numIterations)

statusFormatter = getString(message('images:imregdemons:graphicalStatusFormatter',...
    '%d',pyramidLevel,totalPyramidLevels));

dlgName = getString(message('images:imregdemons:waitDlgName',pyramidLevel,totalPyramidLevels));

waitBar.resetWaitbarState(dlgName, statusFormatter, numIterations);

end

function waitBar = waitBarFactory(numIterations,pyramidLevel,pyramidLevels)

    dlgName = getString(message('images:imregdemons:waitDlgName',pyramidLevel,pyramidLevels));
    if images.internal.isFigureAvailable()
        
        statusFormatter = getString(message('images:imregdemons:graphicalStatusFormatter',...
            '%d',pyramidLevel,pyramidLevels));
        
        waitBar = iptui.cancellableWaitbar(dlgName,...
            statusFormatter,numIterations(pyramidLevel),0);
        
    else
        
        statusFormatter = getString(message('images:imregdemons:textStatusFormatter',...
            '%d','%d',pyramidLevel,pyramidLevels));
                
        waitBar = iptui.textWaitUpdater(dlgName,...
            statusFormatter,numIterations(pyramidLevel));
        
    end

end

function [moving,fixed] = validateInputImages(moving,fixed)

supportedImageClasses = {'uint8','uint16','uint32','int8','int16','int32','single','double','logical'};
supportedImageAttributes = {'real','nonsparse','finite','nonempty'};

validateattributes(moving,supportedImageClasses,supportedImageAttributes,...
    mfilename,'MOVING');

validateattributes(fixed,supportedImageClasses,supportedImageAttributes,...
    mfilename,'FIXED');

hasInvalidNumberOfDimensions = @(im) ndims(im) < 2 || ndims(im) > 3;
if hasInvalidNumberOfDimensions(fixed) || hasInvalidNumberOfDimensions(moving);
    error(message('images:imregdemons:onlyTwoDOrThreeDAllowed','MOVING','FIXED'));
end

if ~isequal(ndims(moving),ndims(fixed))
    error(message('images:imregdemons:movingFixedDifferentDim','MOVING','FIXED'));
end

end
