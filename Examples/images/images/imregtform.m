function tform = imregtform(varargin)
%IMREGTFORM Estimate geometric transformation that aligns two 2-D or 3-D images.
%
%   TFORM = IMREGTFORM(MOVING, FIXED, TRANSFORMTYPE, OPTIMIZER, METRIC)
%   estimates the geometric transformation that aligns the moving image
%   MOVING with the fixed image FIXED. TRANSFORMTYPE is a string that
%   defines the type of transformation to estimate. OPTIMIZER is an object
%   that describes the method for optimizing the metric. METRIC is an
%   object that defines the quantitative measure of similarity between the
%   images to optimize.  The output TFORM is a geometric transformation
%   object that maps MOVING to FIXED.
%
%   TFORM = IMREGTFORM(MOVING, RMOVING, FIXED, RFIXED, TRANSFORMTYPE,
%   OPTIMIZER, METRIC) estimates the geometric transformation that aligns
%   the spatially referenced moving image MOVING with the spatially
%   referenced fixed image FIXED. MOVING and FIXED specify the image data
%   of the MOVING and FIXED image. RMOVING and RFIXED specify the spatial
%   referencing objects associated with MOVING and FIXED. The output
%   geometric transformation TFORM is in units defined by the spatial
%   referencing objects RMOVING and RFIXED. When there is known spatial
%   referencing information, it is important to use this syntax because it
%   helps IMREGTFORM converge to better results more quickly because scale
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
%   TFORM = IMREGISTER(...,PARAM1,VALUE1,PARAM2,VALUE2,...) registers the
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
%   OPTIMIZER is an object from the registration.optimizer package. When
%   MOVING and FIXED are 2-D, TFORM is an affine2d object. When MOVING and
%   FIXED are 3-D, TFORM is an affine3d object.
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
%   % Find geometric transformation that maps moving to fixed.
%   tform = imregtform(moving, fixed, 'affine', optimizer, metric);
%
%   % Use imwarp to apply tform to moving so that it aligns with fixed.
%   % Preserve world limits and resolution of the fixed image when forming
%   % the transformed image using the 'OutputView' Name/Value pair.
%   movingRegistered = imwarp(moving,tform,'OutputView',imref2d(size(fixed)));
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%   
%   See also AFFINE2D, AFFINE3D, IMREGCONFIG, IMREGISTER, IMREF2D, IMREF3D, IMSHOWPAIR, IMWARP, 
%   registrationEstimator,
%   registration.metric.MattesMutualInformation,
%   registration.metric.MeanSquares,
%   registration.optimizer.RegularStepGradientDescent
%   registration.optimizer.OnePlusOneEvolutionary

%   Copyright 2011-2016 The MathWorks, Inc.

parsedInputs = parseInputs(varargin{:});

moving             = parsedInputs.MovingImage;
mref               = parsedInputs.MovingRef;
fixed              = parsedInputs.FixedImage; 
fref               = parsedInputs.FixedRef;
transformType      = parsedInputs.TransformType;
dispOptim          = parsedInputs.DisplayOptimization;
optimObj           = parsedInputs.OptimConfig;
metricConfig       = parsedInputs.MetricConfig;
pyramidLevels      = parsedInputs.PyramidLevels;
initialTrans       = parsedInputs.InitialTransformation;


% Obtain the default optimization parameters and the corresponding scales
[defaultLinearPortionOfTransform, defaultTranslationVector, defaultOptimScales] = ...
    computeDefaultRegmexSettings(transformType,...
    mref,...
    fref);

% Use the defaults transform parameters as initial conditions for the
% optimizer if required.
if (isempty(initialTrans))
    linearPortionOfTransformInit = defaultLinearPortionOfTransform;
    translationVectorInit = defaultTranslationVector; 
else
    [linearPortionOfTransformInit,translationVectorInit] = convertGeotransToRegmexMatrices(initialTrans, transformType);
end

% Set the optimizer scales.
optimObj.Scales = defaultOptimScales;

% Extract required spatial info


if(isa(mref,'imref3d'))
    mspacing = [mref.PixelExtentInWorldX mref.PixelExtentInWorldY mref.PixelExtentInWorldZ];
    [mfirstx, mfirsty, mfirstz] = mref.intrinsicToWorld(1,1,1);
    mfirst   = [mfirstx mfirsty mfirstz];

    fspacing = [fref.PixelExtentInWorldX fref.PixelExtentInWorldY fref.PixelExtentInWorldZ];
    [ffirstx, ffirsty, ffirstz] = fref.intrinsicToWorld(1,1,1);
    ffirst   = [ffirstx ffirsty ffirstz];
    
    moving = permute(moving,[2 1 3]);
    fixed  = permute(fixed,[2 1 3]);
    
else
% assume 2d

    mspacing = [mref.PixelExtentInWorldX mref.PixelExtentInWorldY];
    [mfirstx, mfirsty] = mref.intrinsicToWorld(1,1);
    mfirst   = [mfirstx mfirsty];

    fspacing = [fref.PixelExtentInWorldX fref.PixelExtentInWorldY];
    [ffirstx, ffirsty] = fref.intrinsicToWorld(1,1);
    ffirst   = [ffirstx ffirsty];
    
    moving = moving';
    fixed  = fixed';

end

numPhysicalCores = feature('numthreads');

% Cast images to double before handing to regmex.
[linearPortionOfTransform, translationVector] = ...
    regmex(...
    double(moving), ...
    mfirst,...
    mspacing,...
    double(fixed),...
    ffirst,...
    fspacing,...
    dispOptim,...
    transformType, ...
    double(linearPortionOfTransformInit), ...
    double(translationVectorInit),...
    optimObj, ...
    metricConfig,...
    pyramidLevels,...
    numPhysicalCores);

% Convert the mex registration parameters to a tform object
tform = convertRegmexMatricesToGeotrans(linearPortionOfTransform, translationVector, transformType);

% If 'InitialTransformation' specified using single precision
% transformation, return a single precision transformation.
if isa(linearPortionOfTransformInit,'single')
    tform.T = single(tform.T);
end

end


function validateSpatialReferencingAgreementWithImage(A,RA,inputName)

if ~sizesMatch(RA,A)
    error(message('images:imregtform:spatialRefAgreementWithImage','ImageSize',inputName,inputName));
end

if (isequal(ndims(A),3) && ~isa(RA,'imref3d'))
    error(message('images:imregtform:volumetricDataRequiresImref3d','RMOVING','RFIXED','imref3d'));
end

end

% Parse inputs
function parsedInputs = parseInputs(varargin)

% We pre-parse spatial referencing objects before we start input parsing so that
% we can separate spatially referenced syntax from other syntaxes. 
[R_moving,R_fixed,varargin] = preparseSpatialRefObjects(varargin{:});

parser = inputParser();

parser.addRequired('MovingImage',  @checkMovingImage);
parser.addRequired('FixedImage',   @checkFixedImage);
parser.addRequired('TransformType',@checkTransform);
parser.addRequired('OptimConfig',  @checkOptim);
parser.addRequired('MetricConfig', @checkMetric);

parser.addParamValue('DisplayOptimization', false, @checkDisplay);
parser.addParamValue('PyramidLevels',3,@checkPyramidLevels);
parser.addParamValue('InitialTransformation',affine2d.empty(),@checkInitialTransformation);

% Function scope for partial matching
parsedTransformString = '';

% Parse input, replacing partial name matches with the canonical form.
if (nargin > 5)
  varargin(6:end) = images.internal.remapPartialParamNames({'DisplayOptimization',...
                                                            'PyramidLevels',...
                                                            'InitialTransformation'}, ...
                                                            varargin{6:end});
end

parser.parse(varargin{:});

parsedInputs = parser.Results;

% Make sure that there are enough pixels in the fixed and moving images for
% the number of pyramid levels requested.
validatePyramidLevels(parsedInputs.FixedImage,parsedInputs.MovingImage, parsedInputs.PyramidLevels);

% Allows us to be consistent with rest of toolbox in allowing scalar
% numeric values to be used interchangeably with logicals.
parsedInputs.DisplayOptimization = logical(parsedInputs.DisplayOptimization);

% ensure that the number of dimensions match.
if(ndims(parsedInputs.FixedImage) ~= ndims(parsedInputs.MovingImage))
    error(message('images:imregtform:dimMismatch'));
end

isSpatiallyReferencedSyntax = ~isempty(R_moving);
if isSpatiallyReferencedSyntax
    validateSpatialReferencingAgreementWithImage(parsedInputs.MovingImage,R_moving,'moving');
    validateSpatialReferencingAgreementWithImage(parsedInputs.FixedImage,R_fixed,'fixed');
    parsedInputs.MovingRef = R_moving;
    parsedInputs.FixedRef = R_fixed;
else
    % Create default spatial reference objects
    if(ndims(parsedInputs.MovingImage)==3)
        parsedInputs.MovingRef = imref3d(size(parsedInputs.MovingImage));
        parsedInputs.FixedRef  = imref3d(size(parsedInputs.FixedImage));
    else
        % assume 2D
        parsedInputs.MovingRef = imref2d(size(parsedInputs.MovingImage));
        parsedInputs.FixedRef  = imref2d(size(parsedInputs.FixedImage));
    end
end

% Validate InitialTransformation
validateInitialTransformation(parsedInputs.InitialTransformation,...
                              parsedInputs.MovingImage,...
                              parsedInputs.TransformType)

parsedInputs.TransformType = parsedTransformString;


    function tf = checkPyramidLevels(levels)
        
        validateattributes(levels,{'numeric'},{'scalar','real','positive','nonnan'},'imregtform','PyramidLevels');
        
        tf = true;
        
    end

    function tf = checkOptim(optimConfig)
       
        validOptimizer = isa(optimConfig,'registration.optimizer.RegularStepGradientDescent') ||...
                         isa(optimConfig,'registration.optimizer.GradientDescent') ||...
                         isa(optimConfig,'registration.optimizer.OnePlusOneEvolutionary');
                     
        if ~validOptimizer
           error(message('images:imregtform:invalidOptimizerConfig'))
        end
        tf = true;
        
    end

    function tf = checkMetric(metricConfig)
       
        validMetric = isa(metricConfig,'registration.metric.MeanSquares') ||...
                      isa(metricConfig,'registration.metric.MutualInformation') ||...
                      isa(metricConfig,'registration.metric.MattesMutualInformation');
                  
        if ~validMetric
           error(message('images:imregtform:invalidMetricConfig'))
        end
        tf = true;
        
    end

    function tf = checkFixedImage(img)
        
        validateattributes(img,{'numeric'},...
            {'real','nonempty','nonsparse','finite','nonnan'},'imregtform','fixed',1);
                
        if(ndims(img)>3)
            error(message('images:imregtform:fixedImageNot2or3D'));
        end
        tf = true;
        
    end

    function tf = checkMovingImage(img)
        
        validateattributes(img,{'numeric'},...
            {'real','nonempty','nonsparse','finite','nonnan'},'imregtform','moving',2);

        if(ndims(img)>3)
            error(message('images:imregtform:movingImageNot2or3D'));
        end
        
        
        if (any(size(img)<4))
             error(message('images:imregtform:minMovingImageSize'));
        end
 
        tf = true;
        
    end

    function tf = checkTransform(tform)
        parsedTransformString = validatestring(lower(tform), {'affine','translation','rigid','similarity'}, ...
            'imregtform', 'TransformType');
        
        tf = true;
        
    end

    function tf = checkInitialTransformation(tform)
        % We only use the input parser to do simple type checking on the
        % transformation. We do additional validation on the
        % initialTransformation after the initial call to parse.

        if ~(isa(tform,'affine2d') || isa(tform,'affine3d'))
            error(message('images:imregtform:invalidInitialTransformationType','affine2d','affine3d'));
        end

        tf = true;

    end
    
    function tf = checkDisplay(TF)
        
        validateattributes(TF,{'logical','numeric'},{'real','scalar'});
        
        tf = true;
        
    end

end


% Validate input pyramid levels against image sizes
function validatePyramidLevels(fixed,moving,numLevels)

requiredPixelsPerDim = 4.^(numLevels-1);

fixedTooSmallToPyramid  = any(size(fixed) < requiredPixelsPerDim);
movingTooSmallToPyramid = any(size(moving) < requiredPixelsPerDim);

if fixedTooSmallToPyramid || movingTooSmallToPyramid
    % Convert dims to strings, since they can be large enough to overflow
    % into a floating point type.
    error(message('images:imregtform:tooSmallToPyramid', ...
                  sprintf('%d', requiredPixelsPerDim), ...                  
                  numLevels));
end

end

function [linearPortionOfTransform,translationVector] = convertGeotransToRegmexMatrices(initialTrans, transformType)
% Convert affine2d/affine3d representation of geometric transformation to
% the form that regmex expects.

if strcmpi(transformType,'translation')
    % In the special case of translation, the inverse is just the
    % non-diagonal section of the matrix flipping sign. This avoids
    % floating point errors during inversion.
    initialTrans.T = 2.*eye(size(initialTrans.T)) - initialTrans.T;
else
    % regmex expects inverse mapping.
    initialTrans = invert(initialTrans);
end

% Unpack linear and additive portions of transformation separately.
linearPortionOfTransform = initialTrans.T(1:initialTrans.Dimensionality,1:initialTrans.Dimensionality);
translationVector = initialTrans.T(end,1:initialTrans.Dimensionality);

end

function tform = convertRegmexMatricesToGeotrans(linearPortionOfTransform, translationVector, transformType)
% Convert the regmex representation of the separate linear portion of the
% transform and an additive translation vector to a geometric
% transformation object.

% The incoming rotation and translation information aligns the *fixed* to
% the *moving*.

nDims = numel(translationVector);

finalTransform = eye(nDims+1);
finalTransform(1:nDims,1:nDims) = linearPortionOfTransform;
finalTransform(end,1:nDims) = translationVector;


if nDims == 2
    tform = affine2d(finalTransform);
else
    tform = affine3d(finalTransform);
end

if strcmpi(transformType,'translation')
    % In the special case of translation, the inverse is just the
    % non-diagonal section of the matrix flipping sign. This avoids
    % floating point errors during inversion.
    tform.T = 2.*eye(size(tform.T)) - tform.T;
else
    % While optimizing, regmex works with a transform which moves the fixed image
    % to the moving image. Invert the transform to return the transformation
    % which maps moving to fixed.
    tform = invert(tform);
end

end

function [Aref,Bref,varargin] = preparseSpatialRefObjects(varargin)

spatialRefPositions   = cellfun(@(c) isa(c,'imref2d'), varargin);

Aref = [];
Bref = [];

if ~any(spatialRefPositions)
    return
end

if ~isequal(find(spatialRefPositions), [2 4])
    error(message('images:imregtform:spatialRefPositions'));
end

Aref = varargin{2};
Bref = varargin{4};
varargin([2 4]) = [];

end

function validateInitialTransformation(tform,movingImage,transformationType)

if isempty(tform)
    return
end

% 2-D InitialTransformation, 3-D problem.
if ( (tform.Dimensionality==2) && (ndims(movingImage)==3) )
    error(message('images:imregtform:invalidInitialTransformDimensionality',...
        'Dimensionality','InitialTransformation','3','MOVING','FIXED','3-D'))
end

% 3-D InitialTransformation, 2-D problem.
if ( (tform.Dimensionality==3) && ismatrix(movingImage) )
    error(message('images:imregtform:invalidInitialTransformDimensionality',...
        'Dimensionality','InitialTransformation','2','MOVING','FIXED','2-D'))
end

% Make sure InitialTransformation state agrees with TransformationType
switch (lower(transformationType))

    case 'translation'

        if ~tform.isTranslation()
            error(message('images:imregtform:invalidInitialTransformation',...
                  'isTranslation', 'InitialTransformation', 'TransformationType', '''translation'''));
        end

    case 'rigid'

        if ~tform.isRigid();
            error(message('images:imregtform:invalidInitialTransformation',...
                  'isRigid', 'InitialTransformation', 'TransformationType', '''rigid'''));
        end

    case 'similarity'

        if ~tform.isSimilarity();
            error(message('images:imregtform:invalidInitialTransformation',...
                  'isSimilarity', 'InitialTransformation', 'TransformationType', '''similarity'''));
        end

    case 'affine'
        % No additional validation needed.

    otherwise
        assert('Unexpected transformationType.');


end

end



