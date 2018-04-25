function [movingReg,Rreg] = imregister(varargin)
%IMREGISTER Register two 2-D or 3-D images using intensity metric optimization.
%
%   MOVING_REG = IMREGISTER(MOVING, FIXED, TRANSFORMTYPE, OPTIMIZER,
%   METRIC) transforms the moving image MOVING so that it is spatially
%   registered with the FIXED image. TRANSFORMTYPE is a string that defines
%   the type of transformation to perform. OPTIMIZER is an object that
%   describes the method for optimizing the metric. METRIC is an object
%   that defines the quantitative measure of similarity between the images
%   to optimize.  The output MOVING_REG is a transformed version of MOVING.
%
%   [MOVING_REG,R_REG] = IMREGISTER(MOVING, RMOVING, FIXED, RFIXED,
%   TRANSFORMTYPE, OPTIMIZER, METRIC) transforms the spatially referenced
%   moving image MOVING so that it is registered with the spatially
%   referenced FIXED image. MOVING and FIXED specify the image data of the
%   MOVING and FIXED image. RMOVING and RFIXED specify the spatial
%   referencing objects associated with MOVING and FIXED. TRANSFORMTYPE is
%   a string that defines the type of transformation to perform. The first
%   output argument, MOVING_REG, is a transformed version of MOVING. The
%   second output argument, R_REG, is the spatial referencing object
%   associated with MOVING_REG that describes the world limits and
%   resolution of the output image. When there is known spatial referencing
%   information, it is important to use this syntax because it helps
%   IMREGISTER converge to better results more quickly because scale
%   differences can be taken into account.
%
%   TRANSFORMTYPE is a string specifying one of the following geometric
%   transform types:
%
%      TRANSFORMTYPE         TYPES OF DISTORTION
%      -------------         -----------------------
%      'translation'         Translation
%      'rigid'               Translation, Rotation
%      'similarity'          Translation, Rotation, Scale
%      'affine'              Translation, Rotation, Scale, Shear
%
%   The 'similarity' and 'affine' transform types always involve
%   nonreflective transformations.
%
%   [...] = IMREGISTER(...,PARAM1,VALUE1,PARAM2,VALUE2,...) registers the
%   moving image using name-value pairs to control aspects of the
%   registration.
%
%   Parameters include:
%
%      'DisplayOptimization'   - A logical scalar specifying whether or
%                                not to display optimization information
%                                to the MATLAB command prompt. The default
%                                is false.
%
%      'InitialTransformation' - An affine2d or affine3d object specifying
%                                the initial condition used as the starting
%                                transformation in the solution of the
%                                registration.
%                                
%      'PyramidLevels'         - The number of multi-level image pyramid
%                                levels to use. The default is 3.
%
%   Class Support
%   -------------
%   MOVING and FIXED are numeric matrices. RMOVING and RFIXED are spatial
%   referencing objects of class imref2d or imref3d. TRANSFORMTYPE is a
%   string. METRIC is an object from the registration.metric package.
%   OPTIMIZER is an object from the registration.optimizer package.
%
%   Notes
%   -------------
%   Both IMREGTFORM and IMREGISTER use the same underlying registration
%   algorithm. IMREGISTER performs an additional step of resampling MOVING
%   to produce the registered output image from the geometric
%   transformation estimate calculated by IMREGTFORM. Use IMREGTFORM when
%   you want access to the geometric transformation that relates MOVING to
%   FIXED. Use IMREGISTER when you want a registered output image.
%
%   Getting good results from optimization-based image registration usually
%   requires modifying optimizer and/or metric settings for the pair of
%   images being registered.  The imregconfig function provides a default
%   configuration that should only be considered a starting point. See the
%   output of the imregconfig for more information on the different
%   parameters that can be modified.
%   
%   Example 
%   -------------
%   % Read in two slightly misaligned magnetic resonance images of a knee
%   % obtained using different protocols.
%   fixed  = dicomread('knee1.dcm');
%   moving = dicomread('knee2.dcm');
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Get a configuration suitable for registering images from different
%   % sensors.
%   [optimizer, metric] = imregconfig('multimodal')
%
%   % Tune the properties of the optimizer to get the problem to converge
%   % on a global maxima and to allow for more iterations.
%   optimizer.InitialRadius = 0.009;
%   optimizer.Epsilon = 1.5e-4;
%   optimizer.GrowthFactor = 1.01;
%   optimizer.MaximumIterations = 300;
%
%   % Align the moving image with the fixed image
%   movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%   
%   See also AFFINE2D, AFFINE3D, IMREF2D, IMREF3D, IMREGCONFIG, IMREGTFORM, IMSHOWPAIR, IMWARP, 
%   registrationEstimator,
%   registration.metric.MattesMutualInformation,
%   registration.metric.MeanSquares,
%   registration.optimizer.RegularStepGradientDescent
%   registration.optimizer.OnePlusOneEvolutionary

%   Copyright 2011-2016 The MathWorks, Inc.

tform = imregtform(varargin{:});

 % Rely on imregtform to input parse and validate. If we were passed
 % spatially referenced input, use spatial referencing during resampling.
 % Otherwise, just use identity referencing objects for the fixed and
 % moving images.
 spatiallyReferencedInput = isa(varargin{2},'imref2d') && isa(varargin{4},'imref2d');
 if spatiallyReferencedInput
     moving  = varargin{1};
     Rmoving = varargin{2};
     Rfixed  = varargin{4};
 else
     moving = varargin{1};
     fixed = varargin{2};
     if (tform.Dimensionality == 2)
        Rmoving = imref2d(size(moving));
        Rfixed = imref2d(size(fixed));
     else
         Rmoving = imref3d(size(moving));
         Rfixed = imref3d(size(fixed));
     end
 end
 
 % Transform the moving image using the transform estimate from imregtform.
 % Use the 'OutputView' option to preserve the world limits and the
 % resolution of the fixed image when resampling the moving image.
 [movingReg,Rreg] = imwarp(moving,Rmoving,tform,'OutputView',Rfixed, 'SmoothEdges', true);


