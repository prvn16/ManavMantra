function [outputImage,outputRef] = imwarp(varargin)
%IMWARP Apply geometric transformation to image.
%   B = IMWARP(A,TFORM) transforms the image A according to the geometric
%   transformation defined by TFORM, which is a geometric transformation
%   object. B is the output image. TFORM can be a 2-D or 3-D geometric
%   transformation. If TFORM is 2-D and ndims(A) > 2, such as for an RGB
%   image, then the same 2-D transformation is automatically applied to all
%   2-D planes along the higher dimensions. If TFORM is 3-D, then A must be
%   a 3-D image volume.
%
%   B = IMWARP(A,D) transforms the input image A according to the
%   displacement field defined by D. B is the output image. D is an MxNx2
%   numeric matrix when the input image A is 2-D. D is an MxNxPx3 matrix
%   when the input image A is 3-D. Plane at a time behavior is also
%   supported when A is MxNxP and the input displacement field is MxNx2, in
%   which case D is applied to A one plane at a time. The first plane of
%   the displacement field, D(:,:,1) describes the X component of additive
%   displacement that is added to column,row locations in D to produce
%   remapped locations in A. Similarly, D(:,:,2) describes the Y component
%   of additive displacement values and in the 3-D case, D(:,:,3) describes
%   the Z component of additive displacement. The unit of displacement
%   values in D is pixels. D defines the grid size and location of the
%   output image. It is assumed that D is referenced to the default
%   intrinsic coordinate system.
%
%   [B, RB] = IMWARP(A,RA,TFORM) transforms a spatially referenced
%   image specified by the image data A and the associated spatial
%   referencing object RA. When TFORM is a 2-D geometric transformation,
%   RA must be a 2-D spatial referencing object. When TFORM is a 3-D
%   geometric transformation, RA must be a 3-D spatial referencing
%   object. The output is a spatially referenced image specified by the
%   image data B and the associated spatial referencing object RB.
%
%   B = IMWARP(...,INTERP) specifies the form of interpolation to
%   use.  INTERP can be one of the strings 'nearest', 'linear', or
%   'cubic'. The default value for INTERP is 'linear'.
%
%   [B,RB] = IMWARP(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   specifies parameters that control various aspects of the geometric
%   transformation. Parameter names can be abbreviated, and case does not
%   matter.
%
%   Parameters include:
%
%   'OutputView'        An imref2d or imref3d object. The ImageSize,
%                       XWorldLimits, and YWorldLimits properties of the
%                       specified spatial referencing object define the
%                       size of the output image and the location of the
%                       output image in the world coordinate system. The
%                       use of 'OutputView' is not available when applying
%                       displacement fields.
%
%   'FillValues'        An array containing one or several fill values.
%                       Fill values are used for output pixels when the
%                       corresponding inverse transformed location in the
%                       input image is completely outside the input image
%                       boundaries.
%
%                       If A is 2-D then 'FillValues' must be a
%                       scalar. If A is 3-D and the geometric
%                       transformation is 3-D, then 'FillValues' must be a
%                       scalar. If A is N-D and the geometric
%                       transformation is 2-D, then 'FillValues' may be
%                       either scalar or an array whose size matches
%                       dimensions 3 to N of A. For example, if A is a
%                       uint8 RGB image that is 200-by-200-by-3, then
%                       'FillValues' can be a scalar or a 3-by-1 array. In
%                       this RGB image example, possibilities for
%                       'FillValues' include:
%
%                           0                 - fill with black
%                           [0;0;0]           - also fill with black
%                           255               - fill with white
%                           [255;255;255]     - also fill with white
%                           [0;0;255]         - fill with blue
%                           [255;255;0]       - fill with yellow
%
%                       If A is 4-D with size 200-by-200-by-3-by-10, then
%                       'FillValues' can be a scalar or a 3-by-10 array.
%
%   'SmoothEdges'       A logical value controlling the edge smoothing
%                       behavior. When true, the input image is padded with
%                       FillValues to create a smoother edge in the output
%                       image. Setting SmoothEdges to false prevents this
%                       padding. Not padding the input results in a sharper
%                       edge in the output image, this can be useful to
%                       minimize seam distortions when registering two
%                       images side by side. 
%                       The default value is false.
%
%   Notes
%   -----
%   - The function IMWARP changed in version 9.3 of the Image Processing
%     Toolbox (MATLAB R2015b). Previous versions always smoothed the edges
%     of the output image. To obtain the same edge behavior as the previous
%     versions, set SmoothEdges to true.
%
%   - When you do not specify the output-space location for B using
%     'OutputView', IMWARP estimates them automatically using the
%     outputLimits method of tform.
%
%   - The automatic estimate of 'OutputView' using the outputLimits
%     method of tform is not guaranteed in all cases to completely contain
%     all the pixels of the transformed input image.
%
%   - IMWARP assumes spatial-coordinate conventions for the
%     transformation TFORM.  Specifically, the first dimension of the
%     transformation is the horizontal or x-coordinate, and the second
%     dimension is the vertical or y-coordinate.  Note that this is the
%     reverse of MATLAB's array subscripting convention.
%
%   Class Support
%   -------------
%   A can be of any nonsparse numeric class. A can also be logical.  The
%   class of B is the same as the class of A. TFORM is a geometric
%   transformation object. RA and RB are spatial referencing objects of
%   class imref2d or imref3d. D is a nonsparse numeric class.
%
%   Example 1
%   ---------
%   Apply a horizontal shear to an intensity image.
%
%       I = imread('cameraman.tif');
%       tform = affine2d([1 0 0; .5 1 0; 0 0 1]);
%       J = imwarp(I,tform);
%       figure, imshow(I), figure, imshow(J)
%
%   Example 2
%   ---------
%   Apply a rotation transformation to a 3-D MRI dataset.
%
%       s = load('mri');
%       mriVolume = squeeze(s.D);
%       sizeIn = size(mriVolume);
%       hFigOriginal = figure;
%       hAxOriginal  = axes;
%       slice(double(mriVolume),sizeIn(2)/2,sizeIn(1)/2,sizeIn(3)/2);
%       grid on, shading interp, colormap gray
%
%       % Form rotation transformation about Y axis
%       theta = pi/8;
%       t = [cos(theta)  0      -sin(theta)   0
%           0             1              0     0
%           sin(theta)    0       cos(theta)   0
%           0             0              0     1]
%
%       tform = affine3d(t);
%       mriVolumeRotated = imwarp(mriVolume,tform);
%
%       % Visualize 3 slice planes through center of transformed volume
%       sizeOut = size(mriVolumeRotated);
%       hFigRotated = figure;
%       hAxRotated  = axes;
%       slice(double(mriVolumeRotated),sizeOut(2)/2,sizeOut(1)/2,sizeOut(3)/2);
%       grid on, shading interp, colormap gray
%       % Link views of both axes together
%       linkprop([hAxOriginal,hAxRotated],'View');
%       % Set view to see affect of rotation
%       set(hAxRotated,'View',[-3.5 20.0]);
%
%   See also AFFINE2D, AFFINE3D, PROJECTIVE2D, IMREF2D, IMREF3D, IMREGTFORM

%   Copyright 2012-2017 The MathWorks, Inc.


narginchk(2,inf);
    
isDisplacementFieldSyntax = isnumeric(varargin{2});
if isDisplacementFieldSyntax
    % Handle displacement field syntaxes as a completely separate case.
    parsedInputs = parseInputsDisplacementFieldSyntax(varargin{:});
    method = parsedInputs.InterpolationMethod;
    fillValues = parsedInputs.FillValues;
    D = parsedInputs.DisplacementField;
    outputImage = images.geotrans.internal.applyDisplacementField(parsedInputs.InputImage,...
        D,method,fillValues, parsedInputs.SmoothEdges);
    
    sizeD = size(D);
    if ndims(D) == 3
        outputRef = imref2d(sizeD(1:2));
    else
        outputRef = imref3d(sizeD(1:3));
    end
    
    return;
end
    
[R_A, varargin] = preparseSpatialReferencingObjects(varargin{:});

parsedInputs = parseInputs(varargin{:});

method = parsedInputs.InterpolationMethod;
fillValues = parsedInputs.FillValues;
SmoothEdges = parsedInputs.SmoothEdges;
tform = parsedInputs.GeometricTransform;

% Check agreement of input image with dimensionality of tform
checkImageAgreementWithTform(parsedInputs.InputImage,tform);

inputSpatialReferencingNotSpecified = isempty(R_A);
if inputSpatialReferencingNotSpecified
    if isa(R_A,'imref3d')
        R_A = imref3d(size(parsedInputs.InputImage));
    else
        R_A = imref2d(size(parsedInputs.InputImage));
    end
else
    % Check agreement of input spatial referencing object with input image.
    checkSpatialRefAgreementWithInputImage(parsedInputs.InputImage,R_A);
end


% check agreement of fillValues with dimensionality of problem
checkFillValues(fillValues,parsedInputs.InputImage,tform);

% If the 'OutputView' was not specified, we have to determine the world
% limits and the image size of the output from the input spatial
% referencing information and the geometric transform.
if isempty(parsedInputs.OutputView)
    outputRef = calculateOutputSpatialReferencing(R_A,tform);
else
    outputRef = parsedInputs.OutputView;
    checkOutputViewAgreementWithTform(outputRef,tform);
end

outputImage = remapPointsAndResample(parsedInputs.InputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);

outputImage = cast(outputImage,'like',parsedInputs.InputImage);

function outputImage = remapPointsAndResample(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)

if tform.Dimensionality ==2
    
    useIPP = images.internal.useIPPLibrary() && isa(tform,'affine2d') && ~isProblemSizeTooBig(inputImage);
    
    if useIPP
        outputImage = ippWarpAffine(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    elseif isa(tform,'affine2d') || isa(tform,'projective2d')
        outputImage = remapAndResampleInvertible2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    else
        outputImage = remapAndResampleGeneric2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    end
        
else
    %3d transformation
    if isa(tform,'affine3d')
        outputImage = remapAndResampleInvertible3d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    else
        outputImage = remapAndResampleGeneric3d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    end     
end

function checkOutputViewAgreementWithTform(Rout,tform)

if (tform.Dimensionality == 3) && ~isa(Rout,'imref3d') || ((tform.Dimensionality==2) && isa(Rout,'imref3d'))
    error(message('images:imwarp:outputViewTformDimsMismatch','''OutputView'''));
end

function checkSpatialRefAgreementWithInputImage(A,RA)

if ~sizesMatch(RA,A)
    error(message('images:imwarp:spatialRefDimsDisagreeWithInputImage','ImageSize','RA','A'));
end

function checkImageAgreementWithTform(A,tform)

if (tform.Dimensionality == 3)
    if ~isequal(ndims(A),3)
        error(message('images:imwarp:tformDoesNotAgreeWithSizeOfA','A'));
    end
end

function checkFillValues(fillValues,inputImage,tform)

planeAtATimeProblem = ((tform.Dimensionality==2)  && ~ismatrix(inputImage));

scalarFillValuesRequired = ~planeAtATimeProblem;
if scalarFillValuesRequired && ~isscalar(fillValues)
    error(message('images:imwarp:scalarFillValueRequired','''FillValues'''));
end


if planeAtATimeProblem && ~isscalar(fillValues)
    sizeImage = size(inputImage);
    
    % MxNxP input image is treated as a special case. We allow [1xP] or
    % [Px1] fillValues vector in this case.
    validFillValues = isequal(sizeImage(3:end),size(fillValues)) ||...
        (isequal(ndims(inputImage),3) && isvector(fillValues)...
        && isequal(length(fillValues),sizeImage(3)));
    
    if ~validFillValues
        error(message('images:imwarp:fillValueDimMismatch','''FillValues''','''FillValues''','A'));
    end
end

function R_out = calculateOutputSpatialReferencing(R_A,tform)
% Applies geometric transform to input spatially referenced grid to figure
% out the resolution and world limits after application of the forward
% transformation.
R_out = images.spatialref.internal.applyGeometricTransformToSpatialRef(R_A,tform);

function parsedOutputs = parseInputsDisplacementFieldSyntax(varargin)

parser = inputParser();
parser.addRequired('InputImage',@validateInputImage);
parser.addRequired('DisplacementField',@validateDField);
parser.addOptional('InterpolationMethod','linear',@validateInterpMethod);
parser.addParameter('FillValues',0,@validateFillValues);
parser.addParameter('SmoothEdges',false,@validateSmoothEdges);

varargin = remapPartialParamNamesImwarp(varargin{:});

parser.parse(varargin{:});

parsedOutputs = parser.Results;

displacementFieldDataMismatch = ndims(parsedOutputs.DisplacementField) == 4 &&...
    ismatrix(parsedOutputs.InputImage);
if displacementFieldDataMismatch
    error(message('images:imwarp:displacementField3dData2d'));
end 
   
method = postProcessMethodString(parsedOutputs.InterpolationMethod);

parsedOutputs.InterpolationMethod = method;

function parsedOutputs = parseInputs(varargin)

parser = inputParser();
parser.addRequired('InputImage',@validateInputImage);
parser.addRequired('GeometricTransform',@validateTform);
parser.addOptional('InterpolationMethod','linear',@validateInterpMethod);
parser.addParameter('FillValues',0,@validateFillValues);
parser.addParameter('SmoothEdges',false,@validateSmoothEdges);
parser.addParameter('OutputView',[],@(ref) isa(ref,'imref2d'));

varargin = remapPartialParamNamesImwarp(varargin{:});

parser.parse(varargin{:});

parsedOutputs = parser.Results;

method = postProcessMethodString(parsedOutputs.InterpolationMethod);

parsedOutputs.InterpolationMethod = method;

function TF = validateInterpMethod(method)

validatestring(method,...
    {'nearest','linear','cubic','bilinear','bicubic'}, ...
    'imwarp', 'InterpolationMethod');

TF = true;

function TF = validateInputImage(img)

allowedTypes = {'logical','uint8', 'uint16', 'uint32', 'int8','int16','int32','single','double'};
validateattributes(img,allowedTypes,...
    {'nonempty','nonsparse','finite','nonnan'},'imwarp','A',1);

TF = true;

function TF = validateFillValues(fillVal)

validateattributes(fillVal,{'numeric'},...
    {'nonempty','nonsparse'},'imwarp','FillValues');

TF = true;

function TF = validateSmoothEdges(SmoothEdges)
validateattributes(SmoothEdges,{'logical'},...
    {'nonempty','scalar'},'imwarp','SmoothEdges');

TF = true;


function TF = validateTform(t)

validateattributes(t,{'images.geotrans.internal.GeometricTransformation'},{'scalar','nonempty'},'imwarp','tform');

TF = true;

function methodOut = postProcessMethodString(methodIn)

methodIn = validatestring(methodIn,...
    {'nearest','linear','cubic','bilinear','bicubic'});
% We commonly use bilinear and bicubic in IPT, so both names should work
% for 2-D and 3-D input. This is consistent with interp2 and interp3 in
% MATLAB.

keys   = {'nearest','linear','cubic','bilinear','bicubic'};
values = {'nearest', 'linear','cubic','linear','cubic'}; 
methodMap = containers.Map(keys,values);
methodOut = methodMap(methodIn);

function TF = validateDField(D)

allowedTypes = {'logical','uint8', 'uint16', 'uint32', 'int8','int16','int32','single','double'};
validateattributes(D, allowedTypes, {'nonempty','nonsparse','finite'},'imwarp','D');

sizeD = size(D);
valid2DCase = (ndims(D) == 3) && (sizeD(3) == 2);
valid3DCase = (ndims(D) == 4) && (sizeD(4) == 3);
if ~(valid2DCase || valid3DCase)
    error(message('images:imwarp:invalidDSize'));
end

TF = true;

function varargin_out = remapPartialParamNamesImwarp(varargin)

varargin_out = varargin;
if (nargin > 2)
    % Parse input, replacing partial name matches with the canonical form.
    varargin_out(3:end) = images.internal.remapPartialParamNames({'OutputView','FillValues','SmoothEdges'}, ...
        varargin{3:end});
end

function [R_A,varargin] = preparseSpatialReferencingObjects(varargin)

if (nargin > 1) && isa(varargin{2},'imref2d')
    validateattributes(varargin{2},{'imref2d'},{'scalar','nonempty'},'imwarp','RA');
    R_A = varargin{2};
    varargin(2) = [];
else
    % We don't want to actually assign the default spatial referencing
    % object until the rest of the input arguments have been validated.
    % Assign empty spatial referencing arguments as a flag that we need to
    % assign the identity spatial referencing object after input
    % parsing/validation has finished.
    tform = varargin{2};
    validateTform(tform);
    if (tform.Dimensionality == 2)
        R_A = imref2d.empty();
    else
        R_A = imref3d.empty();
    end
    
end

function [paddedImage,Rpadded] = padImage(A,RA,fillVal)

pad = 2;

if isscalar(fillVal)
    paddedImage = padarray(A,[pad pad],fillVal);
else
    sizeInputImage = size(A);
    sizeOutputImage = sizeInputImage;
    sizeOutputImage(1:2) = sizeOutputImage(1:2) + [2*pad 2*pad];
    if islogical(A)
        paddedImage = false(sizeOutputImage);
    else
        paddedImage = zeros(sizeOutputImage,'like',A);
    end
    [~,~,numPlanes] = size(A);
    for i = 1:numPlanes
        paddedImage(:,:,i) = padarray(A(:,:,i),[pad pad],fillVal(i));
    end
    
end

Rpadded = imref2d(size(paddedImage), RA.PixelExtentInWorldX*[-pad pad]+RA.XWorldLimits,...
    RA.PixelExtentInWorldY*[-pad pad]+RA.YWorldLimits);


function outputImage = remapAndResampleInvertible3d(inputImage,Rin,tform,Rout,method,fillValues, SmoothEdges)

% Define affine transformation that maps from intrinsic system of
% output image to world system of output image.
Sx = Rout.PixelExtentInWorldX;
Sy = Rout.PixelExtentInWorldY;
Sz = Rout.PixelExtentInWorldZ;
Tx = Rout.XWorldLimits(1)-Rout.PixelExtentInWorldX*(Rout.XIntrinsicLimits(1));
Ty = Rout.YWorldLimits(1)-Rout.PixelExtentInWorldY*(Rout.YIntrinsicLimits(1));
Tz = Rout.ZWorldLimits(1)-Rout.PixelExtentInWorldZ*(Rout.ZIntrinsicLimits(1));
tIntrinsictoWorldOutput = [Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; Tx Ty Tz 1];

% Define affine transformation that maps from world system of
% input image to intrinsic system of input image.
Sx = 1/Rin.PixelExtentInWorldX;
Sy = 1/Rin.PixelExtentInWorldY;
Sz = 1/Rin.PixelExtentInWorldZ;
Tx = (Rin.XIntrinsicLimits(1))-1/Rin.PixelExtentInWorldX*Rin.XWorldLimits(1);
Ty = (Rin.YIntrinsicLimits(1))-1/Rin.PixelExtentInWorldY*Rin.YWorldLimits(1);
Tz = (Rin.ZIntrinsicLimits(1))-1/Rin.PixelExtentInWorldZ*Rin.ZWorldLimits(1);
tWorldToIntrinsicInput = [Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; Tx Ty Tz 1];

% Form transformation to go from output intrinsic to input intrinsic
tComp = tIntrinsictoWorldOutput / tform.T * tWorldToIntrinsicInput;
% Find the transform that takes from input intrinsic to output intrinsic
tComp(:,4)=[0 0 0 1]; % avoid round off issues due to inversion above


if ~SmoothEdges && strcmp(method,'linear') ...
        && (isa(inputImage,'uint8') || isa(inputImage,'int16') || isa(inputImage,'uint16')|| isfloat(inputImage))
    % Fast common case
    tformComposite = affine3d(tComp);    
    fillValues = cast(fillValues, 'like', inputImage);
    outputImage = warp3dmex(inputImage, tformComposite.T,  Rout.ImageSize, fillValues);
else
    tformComposite = invert(affine3d(tComp));
    % Form plaid grid of intrinsic points in output image.
    [dstXIntrinsic,dstYIntrinsic,dstZIntrinsic] = meshgrid(1:Rout.ImageSize(2),...
        1:Rout.ImageSize(1),...
        1:Rout.ImageSize(3));
    [srcXIntrinsic,srcYIntrinsic, srcZIntrinsic] = ...
        tformComposite.transformPointsInverse(dstXIntrinsic,dstYIntrinsic, dstZIntrinsic);
    clear dstXIntrinsic dstYIntrinsic dstZIntrinsic;
    outputImage = images.internal.interp3d(inputImage,srcXIntrinsic,srcYIntrinsic,srcZIntrinsic,method,fillValues, SmoothEdges);
end

function outputImage = remapAndResampleInvertible2d(inputImage,Rin,tform,Rout,method,fillValues, SmoothEdges)
[srcXIntrinsic,srcYIntrinsic] = images.geotrans.internal.getSourceMappingInvertible2d(Rin,tform,Rout);
% Mimics syntax of interp2. Has different edge behavior that uses 'fill'
outputImage = images.internal.interp2d(inputImage,srcXIntrinsic,srcYIntrinsic,method,fillValues, SmoothEdges);

function outputImage = remapAndResampleGeneric3d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)

% Form plaid grid of intrinsic points in output image.
[dstXIntrinsic,dstYIntrinsic,dstZIntrinsic] = meshgrid(1:outputRef.ImageSize(2),...
    1:outputRef.ImageSize(1),...
    1:outputRef.ImageSize(3));

% Find location of pixel centers of destination image in world coordinates
% as the starting point for reverse mapping.
[dstXWorld, dstYWorld, dstZWorld] = outputRef.intrinsicToWorld(dstXIntrinsic,dstYIntrinsic,dstZIntrinsic);
clear dstXIntrinsic dstYIntrinsic dstZIntrinsic

% Reverse map pixel centers from destination image to source image via
% inverse transformation.
[srcXWorld,srcYWorld,srcZWorld] = tform.transformPointsInverse(dstXWorld,dstYWorld,dstZWorld);
clear dstXWorld dstYWorld dstZWorld

% Find srcX, srcY, srcZ in intrinsic coordinates to use when
% interpolating.
[srcXIntrinsic,srcYIntrinsic,srcZIntrinsic] = R_A.worldToIntrinsic(srcXWorld,srcYWorld,srcZWorld);
clear srcXWorld srcYWorld srcZWorld

% Mimics syntax of interp3. Has different edge behavior that uses
% 'fill'
outputImage = images.internal.interp3d(inputImage,srcXIntrinsic,srcYIntrinsic,srcZIntrinsic,method,fillValues, SmoothEdges);

function outputImage = remapAndResampleGeneric2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)

% Form plaid grid of intrinsic points in output image.
[dstXIntrinsic,dstYIntrinsic] = meshgrid(1:outputRef.ImageSize(2),1:outputRef.ImageSize(1));

% Find location of pixel centers of destination image in world coordinates
% as the starting point for reverse mapping.
[dstXWorld, dstYWorld] = outputRef.intrinsicToWorld(dstXIntrinsic,dstYIntrinsic);
clear dstXIntrinsic dstYIntrinsic

% Reverse map pixel centers from destination image to source image via
% inverse transformation.
[srcXWorld,srcYWorld] = tform.transformPointsInverse(dstXWorld,dstYWorld);
clear dstXWorld dstYWorld

% Find srcX srcY in intrinsic coordinates to use when interpolating.
% remapmex only knows how to work in intrinsic coordinates, interp2
% supports intrinsic or world.
[srcXIntrinsic,srcYIntrinsic] = R_A.worldToIntrinsic(srcXWorld,srcYWorld);
clear srcXWorld srcYWorld

% Mimics syntax of interp2. Has different edge behavior that uses 'fill'
outputImage = images.internal.interp2d(inputImage,srcXIntrinsic,srcYIntrinsic,method,fillValues, SmoothEdges);

function outputImage = ippWarpAffine(inputImage,Rin,tform,Rout,interp,fillVal, SmoothEdges)

if (~ismatrix(inputImage) && isscalar(fillVal))
    % If we are doing plane at at time behavior, make sure fillValues
    % always propogates through code as a matrix of size determine by
    % dimensions 3:end of inputImage.
    sizeInputImage = size(inputImage);
    if (ndims(inputImage)==3)
        % This must be handled as a special case because repmat(X,N)
        % replicates a scalar X as a NxN matrix. We want a Nx1 vector.
        sizeVec = [sizeInputImage(3) 1];
    else
        sizeVec = sizeInputImage(3:end);
    end
    fillVal = repmat(fillVal,sizeVec);
end

% To achieve desired edge behavior, pad input image with fill values so
% that fill values will be interpolated with source image values at the
% edges. Account for this effect by also including the added extents in the
% spatial referencing object associated with inputImage, since we've added to the
% world extent of inputImage.
if(SmoothEdges)
    [inputImage,Rin] = padImage(inputImage,Rin,fillVal);
end

% The intrinsic coordinate system of IPP is 0 based. 0,0 is the location of
% the center of the first pixel in IPP. We must translate by 1 in each
% dimension to account for this.
tIntelIntrinsicToMATLABIntrinsic = [1 0 0; 0 1 0; 1 1 1];

% Define affine transformation that maps from intrinsic system of
% output image to world system of output image.
Sx = Rout.PixelExtentInWorldX;
Sy = Rout.PixelExtentInWorldY;
Tx = Rout.XWorldLimits(1)-Rout.PixelExtentInWorldX*(Rout.XIntrinsicLimits(1));
Ty = Rout.YWorldLimits(1)-Rout.PixelExtentInWorldY*(Rout.YIntrinsicLimits(1));
tIntrinsictoWorldOutput = [Sx 0 0; 0 Sy 0; Tx Ty 1];

% Define affine transformation that maps from world system of
% input image to intrinsic system of input image.
Sx = 1/Rin.PixelExtentInWorldX;
Sy = 1/Rin.PixelExtentInWorldY;
Tx = (Rin.XIntrinsicLimits(1))-1/Rin.PixelExtentInWorldX*Rin.XWorldLimits(1);
Ty = (Rin.YIntrinsicLimits(1))-1/Rin.PixelExtentInWorldY*Rin.YWorldLimits(1);
tWorldToIntrinsicInput = [Sx 0 0; 0 Sy 0; Tx Ty 1];

% Transform from intrinsic system of MATLAB to intrinsic system of Intel.
tMATLABIntrinsicToIntelIntrinsic = [1 0 0; 0 1 0; -1 -1 1];

% Form composite transformation that defines the forward transformation
% from intrinsic points in the input image in the Intel intrinsic system to
% intrinsic points in the output image in the Intel intrinsic system. This
% composite transform accounts for the spatial referencing of the input and
% output images, and differences between the MATLAB and Intel intrinsic
% systems.
tComp = tIntelIntrinsicToMATLABIntrinsic*tIntrinsictoWorldOutput / tform.T * tWorldToIntrinsicInput*tMATLABIntrinsicToIntelIntrinsic;
tformComposite = invert(affine2d(tComp(1:3,1:2)));

% IPP expects 2x3 affine matrix.
T = tformComposite.T(1:3,1:2);

% Convert types to match IPP support
origClass = class(inputImage);
if(islogical(inputImage))
    inputImage = uint8(inputImage);
elseif(isa(inputImage,'int8') || isa(inputImage,'int16'))
    inputImage = single(inputImage);
elseif(isa(inputImage,'uint32') || isa(inputImage,'int32'))
    inputImage = double(inputImage);
end

% Handle complex inputs by simply calling into IPP twice with the real and
% imaginary parts.

fillVal = double(fillVal);
if isreal(inputImage)
    outputImage = ippgeotrans(inputImage,double(T),Rout.ImageSize,interp,fillVal);
else
    outputImage = complex(ippgeotrans(real(inputImage),double(T),Rout.ImageSize,interp,real(fillVal)),...
        ippgeotrans(imag(inputImage),double(T),Rout.ImageSize,interp,imag(fillVal)));
end

outputImage = cast(outputImage,origClass);

function TF = isProblemSizeTooBig(inputImage)
% IPP cannot handle double-precision inputs that are too big. Switch to
% using MATLAB's interp2 when the image is double-precision and is too big.

imageIsDoublePrecision = isa(inputImage,'double');

padSize = 3;
numel2DInputImage = (size(inputImage,1) + 2*padSize) * (size(inputImage,2) + 2*padSize);

% The size threshold is double(intmax('int32'))/8. The double-precision 
% IPP routine can only handle images that have fewer than this many pixels.
% This is hypothesized to be because they use an int to hold a pointer 
% offset for the input image. This overflows when the offset becomes large 
% enough that ptrOffset*sizeof(double) exceeds intmax.
sizeThreshold = 2.6844e+08;
TF = imageIsDoublePrecision && (numel2DInputImage>=sizeThreshold);