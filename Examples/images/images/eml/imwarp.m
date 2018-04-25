function [outputImage,outputRef] = imwarp(varargin) %#codegen
%IMWARP Apply geometric transformation to image.

%   Copyright 2013-2017 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(2,10);
coder.internal.prefer_const(varargin);

% process required arguments
inputImage = varargin{1};
validateInputImage(inputImage);

% Codegen's upper bounds analysis requires an explicit check for empty 
% input even though validateInputImage() errors out on empty image. This is
% required becuase down below, we are going to use size(inputImage) as a 
% divisor. The image size must be constrained to be >=1 otherwise sizes of 
% the temporary images will be deduced as arbitrary large.
if size(inputImage,1) < 1 ||  size(inputImage,2) < 1
    outputImage = inputImage;
    outputRef = imref2d();
    return
end

inputSpatialReferencingSpecified = false;

if isa(varargin{2},'imref2d')
    validateattributes(varargin{2},{'imref2d'},{'scalar','nonempty'},'imwarp','RA');
    R_A = varargin{2};
    inputSpatialReferencingSpecified = true;
    if nargin > 2
        tform = varargin{3};
        validateTform(tform);
        if nargin > 3  && ~(strncmpi(varargin{4},'O',1) ||...
                strncmpi(varargin{4},'F',1) ||...
                strncmpi(varargin{4},'S',1)) %allow partial string matching
            eml_invariant(eml_is_const(varargin{4}),...
                eml_message('images:imwarp:coderInterpStringNotConst'),...
                'IfNotConst','Fail');
            interpolationMethod = validateInterpMethod(varargin{4});
            paramValStartIdx = coder.internal.const(5);
        else
            interpolationMethod = 'linear';
            eml_invariant(eml_is_const(interpolationMethod),...
                eml_message('images:imwarp:coderInterpStringNotConst'),...
                'IfNotConst','Fail');
            paramValStartIdx = coder.internal.const(4);
        end
    else
        % Error out with Not enough input arguments.
        narginchk(3,3);
    end
else
    tform = varargin{2};
    validateTform(tform);
    
    R_A = imref2d(size(inputImage));
    
    if nargin > 2 && ~(strncmpi(varargin{3},'O',1) ||...
                strncmpi(varargin{3},'F',1) ||...
                strncmpi(varargin{3},'S',1)) %allow partial string matching
        eml_invariant(eml_is_const(varargin{3}),...
            eml_message('images:imwarp:coderInterpStringNotConst'),...
            'IfNotConst','Fail');
        interpolationMethod = validateInterpMethod(varargin{3});
        paramValStartIdx = coder.internal.const(4);
    else
        interpolationMethod = 'linear';
        eml_invariant(eml_is_const(interpolationMethod),...
            eml_message('images:imwarp:coderInterpStringNotConst'),...
            'IfNotConst','Fail');
        paramValStartIdx = coder.internal.const(3);
    end
    
end

%Assign 'method' to one of the 3 supported strings as interp2d only accepts
%'bilinear', 'bicubic' or 'nearest'.
if strcmp(interpolationMethod,'linear') || ...
        strcmp(interpolationMethod,'bilinear')
    method = 'linear';
elseif strcmp(interpolationMethod,'cubic') || ...
        strcmp(interpolationMethod,'bicubic')
    method = 'cubic';
elseif strcmp(interpolationMethod,'nearest')
    method = 'nearest';
end

eml_invariant(eml_is_const(method),...
    eml_message('images:imwarp:coderInterpStringNotConst'),...
    'IfNotConst','Fail');

[fillValues,outputView, SmoothEdges] = parseOptionalInputs(varargin{paramValStartIdx:end});

validateFillValues(fillValues);
coder.internal.errorIf((~isa(outputView,'imref2d') && ...
    ~isempty(outputView)),...
    'images:imwarp:coderOutputViewMustBeSpatialRef');

% If DMA is turned off, and outputView is not specified, error out.
coder.internal.errorIf((strcmp(eml_option('UseMalloc'), 'Off') && ...
    isempty(outputView)),...
    'images:imwarp:coderOutputViewMustBeSpecifiedWithNoDMA');


% Check agreement of input image with dimensionality of tform
checkImageAgreementWithTform(inputImage,tform);


checkSpatialRefAgreementWithInputImage(inputImage,R_A);

% check agreement of fillValues with dimensionality of problem
checkFillValues(fillValues,inputImage,tform);

% If the 'OutputView' was not specified, we have to determine the world
% limits and the image size of the output from the input spatial
% referencing information and the geometric transform.
if isempty(outputView)
    outputRef = calculateOutputSpatialReferencing(R_A,tform);
else
    outputRef = outputView;
    checkOutputViewAgreementWithTform(outputRef,tform);
end

if isnumeric(tform)
    % Note: tform here is actually a displacement field. It was cleaner to
    % just let the "tform" fall through validation for the displacement
    % field case and conditionally handle displacement fields based on
    % whether or not the second input argument is numeric.
    coder.internal.errorIf(~isempty(outputView) || inputSpatialReferencingSpecified,...
        'images:imwarp:spatialRefNotAllowedWithDField');
    
    outputImage = images.geotrans.internal.applyDisplacementField(inputImage,tform,method,fillValues, SmoothEdges);
else
    outputImage = remapPointsAndResample(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
end

outputImage = cast(outputImage,'like',inputImage);

function outputImage = remapPointsAndResample(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)

coder.inline('always');
coder.internal.prefer_const(R_A,tform,outputRef,method,fillValues);

coder.extrinsic('eml_try_catch');
coder.extrinsic('images.internal.coder.useSharedLibrary');
useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary());
useSharedLibrary = useSharedLibrary && ...
    coder.const(images.internal.coder.isCodegenForHost()) && ...
        coder.const(~images.internal.coder.useSingleThread()) && ...
        coder.const(~(coder.isRowMajor && numel(size(inputImage))>2));

if (useSharedLibrary)
    % MATLAB Host Target (PC)
    
    myfun      = 'iptgetpref';
    [errid, errmsg, ippPrefFlag] = eml_const(eml_try_catch(myfun, 'UseIPPL'));
    eml_lib_assert(isempty(errmsg), errid, errmsg);
    
    useIPP = ippPrefFlag && isa(tform,'affine2d') && ~isProblemSizeTooBig(inputImage);
    
    if useIPP
        outputImage = ippWarpAffine(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    else
        outputImage = remapAndResampleGeneric2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    end
else
    % Generate Code for Non-PC targets
    if (coder.gpu.internal.isGpuEnabled)
            % GPU targets
            % GPU Code generation path that removes intermediate variables
            % for query point generation. This generates better GPU code
            % than the regular path, and hence is being written as a
            % separate function.
            if ~eml_is_const(tform)
                coder.internal.compileWarning('gpucoder:common:ImwarpTransformationObjectNotConstant');
            end
            
            if ~coder.internal.isConst(size(inputImage))
                coder.internal.compileWarning('gpucoder:common:ImwarpVariableDimensions');
            end
            outputImage = remapAndResampleGeneric2dGpu(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    else
         % Non-PC Targets (other than GPU)
        outputImage = remapAndResampleGeneric2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges);
    end
end

function outputImage = remapAndResampleGeneric2d(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)

coder.inline('always');
coder.internal.prefer_const(R_A,tform,outputRef,method,fillValues);

eml_invariant(eml_is_const(method),...
    eml_message('images:imwarp:coderInterpStringNotConst'),...
    'IfNotConst','Fail');

% Form plaid grid of intrinsic points in output image.
[dstXIntrinsic,dstYIntrinsic] = meshgrid(1:outputRef.ImageSize(2),1:outputRef.ImageSize(1));

% Find location of pixel centers of destination image in world coordinates
% as the starting point for reverse mapping.
[dstXWorld, dstYWorld] = outputRef.intrinsicToWorld(dstXIntrinsic,dstYIntrinsic);

% Reverse map pixel centers from destination image to source image via
% inverse transformation.
[srcXWorld,srcYWorld] = tform.transformPointsInverse(dstXWorld,dstYWorld);

% Find srcX srcY in intrinsic coordinates to use when interpolating.
% remapmex only knows how to work in intrinsic coordinates, interp2
% supports intrinsic or world.
[srcXIntrinsic,srcYIntrinsic] = R_A.worldToIntrinsic(srcXWorld,srcYWorld);

% Mimics syntax of interp2. Has different edge behavior that uses 'fill'
outputImage = images.internal.interp2d(inputImage,srcXIntrinsic,srcYIntrinsic,method,fillValues, SmoothEdges);

% GPU code generation specific function. Uses portable code generation path
% after the query points generation. 
function outputImage = remapAndResampleGeneric2dGpu(inputImage,R_A,tform,outputRef,method,fillValues, SmoothEdges)
coder.gpu.kernelfun;

coder.inline('always');
coder.internal.prefer_const(R_A,tform,outputRef,method,fillValues);

eml_invariant(eml_is_const(method),...
    eml_message('images:imwarp:coderInterpStringNotConst'),...
    'IfNotConst','Fail');

% Output image size used for preallocating querypoint matrices.
outPutRes = outputRef.ImageSize;

% Form a plaid grid of output world co-ordinates. This portion contains the
% both meshgrid operation and intrinsic to world co-ordinate conversion as a 
% single operation.
dstXWorld = zeros(outPutRes);
dstYWorld = zeros(outPutRes);
for colIdx=1:outPutRes(2)
    for rowIdx=1:outPutRes(1)
        dstXWorld(rowIdx,colIdx) = outputRef.XWorldLimits(1) + (colIdx-0.5).* outputRef.PixelExtentInWorldX;
        dstYWorld(rowIdx,colIdx) = outputRef.YWorldLimits(1) + (rowIdx-0.5).* outputRef.PixelExtentInWorldY;
    end
end

% Inverse transformation matrix, used for reverse mapping pixel centres.
tinv = inv(tform.T);

% Finding query point co-ordinates (in world co-ordinate system) using 
% standard transformation equations. It is valid for both affine and
% projective transformations.

% This is sufficient for affine transformation. The projective 
% transformation needs some normalization.
srcXWorld = tinv(1,1)*dstXWorld + tinv(2,1)*dstYWorld + tinv(3,1);
srcYWorld = tinv(1,2)*dstXWorld + tinv(2,2)*dstYWorld + tinv(3,2);

% Required only for projective transformation.
if isa(tform,'projective2d')
   srczWorld =  tinv(1,3)*dstXWorld + tinv(2,3)*dstYWorld + tinv(3,3);
   srcXWorld = srcXWorld./srczWorld;
   srcYWorld = srcYWorld./srczWorld;
end

% Convert the query points to intrinsic co-ordinate system
srcXIntrinsic = 0.5 + (srcXWorld-R_A.XWorldLimits(1)) / R_A.PixelExtentInWorldX;
srcYIntrinsic = 0.5 + (srcYWorld-R_A.YWorldLimits(1)) / R_A.PixelExtentInWorldY;

% Mimics syntax of interp2. Has different edge behavior that uses 'fill'. %
% Uses standard Matlab 'interp2d' that is used for portable code generation.
outputImage = images.internal.interp2d(inputImage,srcXIntrinsic,srcYIntrinsic,method,fillValues, SmoothEdges);

function checkOutputViewAgreementWithTform(Rout,tform)

coder.inline('always');
coder.internal.prefer_const(Rout,tform);

if isnumeric(tform)
    return
end

coder.internal.errorIf(...
    (tform.Dimensionality == 3) && ~isa(Rout,'imref3d'),...
    'images:imwarp:outputViewTformDimsMismatch','''OutputView''');
coder.internal.errorIf(...
    ((tform.Dimensionality==2) && isa(Rout,'imref3d')),...
    'images:imwarp:outputViewTformDimsMismatch','''OutputView''');

function checkSpatialRefAgreementWithInputImage(A,RA)

coder.inline('always');
coder.internal.prefer_const(A,RA);

coder.internal.errorIf(~sizesMatch(RA,A),...
    'images:imwarp:spatialRefDimsDisagreeWithInputImage','ImageSize','RA','A');

function checkImageAgreementWithTform(A,tform)

coder.inline('always');
coder.internal.prefer_const(A,tform);

if isnumeric(tform)
    return
end
coder.internal.errorIf(...
    (tform.Dimensionality == 3) && ~isequal(ndims(A),3),...
    'images:imwarp:tformDoesNotAgreeWithSizeOfA','A');

function checkFillValues(fillValues,inputImage,tform)

coder.inline('always');
coder.internal.prefer_const(inputImage,tform,fillValues);

if isnumeric(tform)
    % Displacement field
    sizeD = size(tform);
    is2D = numel(sizeD) == 3;
else
    is2D = tform.Dimensionality == 2;
end

planeAtATimeProblem = is2D  && ~ismatrix(inputImage);

scalarFillValuesRequired = ~planeAtATimeProblem;
coder.internal.errorIf(...
    scalarFillValuesRequired && ~isscalar(fillValues),...
    'images:imwarp:scalarFillValueRequired','''FillValues''');

if planeAtATimeProblem && ~isscalar(fillValues)
    sizeImage = size(inputImage);
    
    % MxNxP input image is treated as a special case. We allow [1xP] or
    % [Px1] fillValues vector in this case.
    validFillValues = isequal(sizeImage(3:end),size(fillValues)) ||...
        (isequal(ndims(inputImage),3) && isvector(fillValues)...
        && isequal(length(fillValues),sizeImage(3)));
    
    coder.internal.errorIf(~validFillValues,...
        'images:imwarp:fillValueDimMismatch','''FillValues''','''FillValues''','A');
end

function R_out = calculateOutputSpatialReferencing(R_A,tform)
% Applies geometric transform to input spatially referenced grid to figure
% out the resolution and world limits after application of the forward
% transformation.
coder.inline('always');
coder.internal.prefer_const(R_A,tform);

if isnumeric(tform)
    % Output referencing is determined by number of rows and columns of D
    % in the intrinsic coordinate system.
    D = tform;
    R_out = imref2d([size(D,1) size(D,2)]);
else
    R_out = images.spatialref.internal.applyGeometricTransformToSpatialRef(R_A,tform);
end

function [fillValues,outputView, SmoothEdges] = parseOptionalInputs(varargin)
% Parse optional PV pairs - 'OutputView' and 'FillValues'
coder.inline('always');
coder.internal.prefer_const(varargin);

params = struct( ...
    'FillValues',   uint32(0), ...
    'OutputView',  uint32(0),...
    'SmoothEdges', uint32(0)...
    );

popt = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', true);

optarg               = eml_parse_parameter_inputs(params, popt, ...
    varargin{:});
fillValues           = eml_get_parameter_value(...
    optarg.FillValues,     0, varargin{:});
outputView           = eml_get_parameter_value(...
    optarg.OutputView,    [], varargin{:});
SmoothEdges        = eml_get_parameter_value(...
    optarg.SmoothEdges, 0, varargin{:});

function interpMethod = validateInterpMethod(method)
% Validate interpolation method.
coder.inline('always');
coder.internal.prefer_const(method);

interpMethod = validatestring(method,...
    {'nearest','linear','cubic','bilinear','bicubic'}, ...
    'imwarp', 'InterpolationMethod');

function validateInputImage(img)
% Validate input image.
coder.inline('always');
coder.internal.prefer_const(img);

allowedTypes = {'logical','uint8', 'uint16', 'uint32', 'int8','int16','int32','single','double'};
validateattributes(img,allowedTypes,...
    {'nonempty','nonsparse','finite','nonnan'},'imwarp','A',1);

function validateFillValues(fillVal)
% Validate values of optional parameter 'FillValues'.
coder.inline('always');
coder.internal.prefer_const(fillVal);

validateattributes(fillVal,{'numeric'},...
    {'nonempty','nonsparse'},'imwarp','FillValues');

function validateTform(t)
% Validate tform object
coder.inline('always');
coder.internal.prefer_const(t);

if isnumeric(t)
    allowedTypes = {'logical','uint8', 'uint16', 'uint32', 'int8','int16','int32','single','double'};
    validateattributes(t, allowedTypes, {'nonempty','nonsparse','finite'},'imwarp','D');
    
    sizeD = size(t);
    valid2DCase = (numel(sizeD) == 3) && (sizeD(3) == 2);
    
    coder.internal.errorIf(~valid2DCase,'images:imwarp:invalidDSizeCodegen');
    
else
    validateattributes(t,{'images.geotrans.internal.GeometricTransformation'},{'scalar','nonempty'},'imwarp','tform');
end

function [paddedImage,Rpadded] = padImage(A,RA,fillVal)

coder.inline('always');
coder.internal.prefer_const(RA,fillVal);

pad = 2;

if isscalar(fillVal) && numel(size(A)) == 2
    % fillVal must be scalar and A must be compile-time 2D
    paddedImage = padarray(A,[pad pad],fillVal);
else
    sizeInputImage = size(A);
    sizeOutputImage = sizeInputImage;
    sizeOutputImage(1) = sizeOutputImage(1) + 2*pad;
    sizeOutputImage(2) = sizeOutputImage(2) + 2*pad;
    if islogical(A)
        paddedImage = false(sizeOutputImage);
    else
        paddedImage = zeros(sizeOutputImage,'like', A);
    end
    [~,~,numPlanes] = size(A);
    for i = 1:numPlanes
        paddedImage(:,:,i) = padarray(A(:,:,i),[pad pad],fillVal(i));
    end
    
end

Rpadded = imref2d(size(paddedImage), RA.PixelExtentInWorldX*[-pad pad]+RA.XWorldLimits,...
    RA.PixelExtentInWorldY*[-pad pad]+RA.YWorldLimits);


function outputImage = ippWarpAffine(inputImage_,Rin_,tform,Rout,interp,fillValIn, SmoothEdges)

coder.inline('always');
coder.internal.prefer_const(Rin_,tform,Rout,interp,fillValIn);

if (numel(size(inputImage_)) ~= 2  && isscalar(fillValIn))
    % If we are doing plane at at time behavior, make sure fillValues
    % always propogates through code as a matrix of size determined by
    % dimensions 3:end of inputImage.
    sizeInputImage = size(inputImage_);
    if (numel(size(inputImage_)) == 3)%(ndims(inputImage_)==3)
        % This must be handled as a special case because repmat(X,N)
        % replicates a scalar X as a NxN matrix. We want a Nx1 vector.
        sizeVec = [sizeInputImage(3) 1];
    else
        sizeVec = sizeInputImage(3:end);
    end
    fillVal = repmat(fillValIn,sizeVec);
else
    fillVal = fillValIn;
end

% If required, pad input image with fill values so that fill values will be
% interpolated with source image values at the edges. Account for this
% effect by also including the added extents in the spatial referencing
% object associated with inputImage, since we've added to the world extent
% of inputImage.
if(SmoothEdges~=0)
    [inputImage,Rin] = padImage(inputImage_,Rin_,fillVal);
else
    inputImage= inputImage_;
    Rin = Rin_;
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
if coder.isColumnMajor
    T = tformComposite.T(1:3,1:2);
else
    T_tmp = tformComposite.T(1:3,1:2);
    T = T_tmp.';
end

% Convert types to match IPP support
if(islogical(inputImage))
    inputImageDT = uint8(inputImage);
elseif(isa(inputImage,'int8')||isa(inputImage,'int16'))
    inputImageDT = single(inputImage);
elseif(isa(inputImage,'uint32') || isa(inputImage,'int32'))
    inputImageDT = double(inputImage);
else
    inputImageDT = inputImage;
end

% Handle complex inputs by simply calling into IPP twice with the real and
% imaginary parts.
if isreal(inputImageDT)
    outputImageTemp = images.internal.coder.ippgeotrans(inputImageDT,double(T),Rout.ImageSize,interp,double(fillVal));
else
    outputImageTemp = complex(images.internal.coder.ippgeotrans(real(inputImageDT),double(T),Rout.ImageSize,interp,real(double(fillVal))),...
        images.internal.coder.ippgeotrans(imag(inputImageDT),double(T),Rout.ImageSize,interp,imag(double(fillVal))));
end

% Cast back to the original datatype of the input.
outputImage = cast(outputImageTemp,'like',inputImage);

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
