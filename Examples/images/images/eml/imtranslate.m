function [B,RB] = imtranslate(varargin) %#codegen
%IMTRANSLATE Translate image.

%   Copyright 2015-2017 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(2,inf);

[A,R_A,translation,method,outputView,fillValues,inputSpatialReferencingNotSpecified] = parseInputs(varargin{:});

integrallyValuedTranslation = inputSpatialReferencingNotSpecified && all(mod(translation,1) == 0);

if integrallyValuedTranslation && isreal(A)
    % As a performance optimization, we treat non-spatially referenced,
    % real valued problems with integral translations in all dimensions as
    % a special case.
    [B,RB] = translateIntegerShift2D(A,R_A,translation,method,outputView,fillValues);
else
    [B,RB] = translate2D(A,R_A,translation,method,outputView,fillValues);
end

end

function [out,Rout] = translateIntegerShift2D(A,RA,translation,~,outputView,fillValues)

% This code path is a special case for non-spatially referenced cases in
% which the translation is integrally valued in all dimensions. We can
% avoid the computational cost of interpolation in these cases and form the
% output image with simple indexing.

coder.inline('always');
coder.internal.prefer_const(A,RA,translation,outputView,fillValues);

Rout = computeOutputSpatialRef(RA,translation,outputView);

% Determine size of output image
inputSize = size(A);
if length(inputSize) < 3
    outputSize = Rout.ImageSize;
    numPlanes = 1;
else
    outputSize = [Rout.ImageSize, inputSize(3:end)];
    numPlanes = sum(inputSize(3:end));
end

% Pre-allocate output image to FillValue.
fillValueCastToOutputType = cast(fillValues,'like',A);
if isscalar(fillValues)
    % This pre-allocation has to work with logical values as well as
    % numeric types.
    out = cast(zeros(outputSize),'like',A);
    out(:) = fillValueCastToOutputType;
else
    out = cast(zeros(outputSize),'like',A);
    for i = 1:length(fillValues)
        out(:,:,i) = fillValueCastToOutputType(i);
    end
end

[XWorldBoundingSubscripts,YWorldBoundingSubscripts] = Rout.intrinsicToWorld([1 Rout.ImageSize(2)],...
    [1 Rout.ImageSize(1)]);

UWorld = XWorldBoundingSubscripts - translation(1);
VWorld = YWorldBoundingSubscripts - translation(2);

% Figure out whether bounding rectangle of reverse mapped pixel centers
% includes any in bounds locations in the source image.
intrinsicSourceBoundingRectangleU = [UWorld(1) UWorld(2) UWorld(2) UWorld(1)];
intrinsicSourceBoundingRectangleV = [VWorld(1) VWorld(1) VWorld(2) VWorld(2)];
% Contains is true inside the world limits and the boundary of the world
% limits.
locationsInSourceMapToDestination = any(RA.contains(intrinsicSourceBoundingRectangleU,...
    intrinsicSourceBoundingRectangleV));

% If there are locations in the source image that map into the destination,
% use indexing to form the output image. Otherwise, return all fill values.
if locationsInSourceMapToDestination
    
    % Clip reverse mapped boundaries to boundaries that live entirely
    % within A.
    UWorldClippedToBounds = [max(1,UWorld(1)), min(RA.ImageSize(2),UWorld(2))];
    VWorldClippedToBounds = [max(1,VWorld(1)), min(RA.ImageSize(1),VWorld(2))];
    
    % At this point we know the locations in source that map into valid
    % locations in the destination image. We want to forward map these into
    % corresponding subscripts in our output image.
    NonFillOutputLocX = UWorldClippedToBounds + translation(1);
    NonFillOutputLocY = VWorldClippedToBounds + translation(2);
    [outputR,outputC] = Rout.worldToSubscript(NonFillOutputLocX,NonFillOutputLocY);
    
    % Where the output locations map into valid, in-bounds locations in A,
    % assign the output values by simple indexing. No interpolation is
    % required since the translation is integrally valued.
    for i = 1:numPlanes
        out(outputR(1):outputR(2),outputC(1):outputC(2),i) = A(VWorldClippedToBounds(1):VWorldClippedToBounds(2),...
            UWorldClippedToBounds(1):UWorldClippedToBounds(2),i);
    end
    
end

end

function [out,Rout] = translate2D(A,RA,translation,method,outputView,fillValues)

coder.inline('always');
coder.internal.prefer_const(A,RA,translation,method,outputView,fillValues);

Rout = computeOutputSpatialRef(RA,translation,outputView);

% Compute spatially referenced case as a general 2-D affine transformation.
tform = affine2d([1 0 0; 0 1 0; translation(1:2) 1]);
[out,Rout] = imwarp(A,RA,tform,method,'OutputView',Rout,'fillValues',fillValues,'SmoothEdges',true);

end

function Rout = computeOutputSpatialRef(RA,translation,outputView)

coder.inline('always');
coder.internal.prefer_const(RA,translation,outputView);

if strcmp(outputView,'same')
    Rout = RA;
else
    % imtranslate(___,'OutputView','full');
    [XWorldLimitsOut,numColsOutput] = computeFullExtentAndGridSizePerDimension(RA.XWorldLimits,...
        RA.PixelExtentInWorldX,translation(1));
    
    [YWorldLimitsOut,numRowsOutput] = computeFullExtentAndGridSizePerDimension(RA.YWorldLimits,...
        RA.PixelExtentInWorldY,translation(2));
    
    Rout = imref2d([numRowsOutput numColsOutput],XWorldLimitsOut,YWorldLimitsOut);
end

end

function [worldLimitsOut,numPixelsInDimOutput] = computeFullExtentAndGridSizePerDimension(inputWorldLimits,inputWorldPixelExtentInDim,translationInDim)

% The full bounding rectangle is the bounding rectangle that
% includes the original and translated images
worldLimitsTranslated = inputWorldLimits+translationInDim;
minInDim = min(inputWorldLimits(1),worldLimitsTranslated(1));
maxInDim = max(inputWorldLimits(2),worldLimitsTranslated(2));

worldLimitsFullIdeal = [minInDim maxInDim];
idealFullExtent = diff(worldLimitsFullIdeal);

% Compute the number of pixels necessary to capture the entire full
% bounding box at the input image resolution. If the full extent is
% not evenly divisible by the input image resolution, use ceil to
% guarantee that we completely capture the full bounding box at the
% input image resolution.
numPixelsInDimOutput = ceil(idealFullExtent ./ inputWorldPixelExtentInDim);

% Compute the extent in world units of the output image, determined
% by the input image resolution and the number of pixels in the output
% image along each dimension.
outputImageExtentInDim = numPixelsInDimOutput*inputWorldPixelExtentInDim;

% If the ideal full image extent is not evenly divisible by the
% input image resolution, then the ceil will have added additional
% image extent. Compute the additional image extent.
addedImageExtentInDim  = outputImageExtentInDim - idealFullExtent;

% Add the additional image extent in each dimension on one side of
% the output image. Increase the full bounding box on the side that
% the translation vector points toward. This allows for a gradual
% transition as the translated image moves in sub-pixel increments.
if translationInDim >=0
    worldLimitsOut = worldLimitsFullIdeal + [0 addedImageExtentInDim];
else
    worldLimitsOut = worldLimitsFullIdeal + [-addedImageExtentInDim 0];
end

end

function [fillValues,outputView] = parseOptionalInputs(varargin)
% Parse optional PV pairs - 'OutputView' and 'FillValues'

coder.inline('always');
coder.internal.prefer_const(varargin);

params = struct( ...
    'FillValues',   uint32(0), ...
    'OutputView',  uint32(0)...
    );

popt = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', true);

optarg               = eml_parse_parameter_inputs(params, popt, ...
    varargin{:});
fillValues           = eml_get_parameter_value(optarg.FillValues, ...
    0, varargin{:});
outputView           = eml_get_parameter_value(...
    optarg.OutputView, 'same', varargin{:});
end

function [A,R_A,translation,method,outputView,fillValues,inputSpatialReferencingNotSpecified] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin);

narginchk(2,Inf);

A = varargin{1};

supportedImageAttributes = {'nonsparse','finite','nonempty'};
supportedNumericClasses = {'uint8','uint16','uint32','int8','int16',...
    'int32','single','double','logical'};
validateattributes(A,supportedNumericClasses,supportedImageAttributes,mfilename,'A');

coder.internal.errorIf(isa(varargin{2},'imref3d'),...
    'images:imtranslate:codegenInvalidSpatialReferencing');    

if isa(varargin{2},'imref2d')
    % Allow imref3d inputs in order to issue an error message.
    validateattributes(varargin{2},{'imref2d'},{'scalar','nonempty'},mfilename,'RA');
    R_A = varargin{2};
    checkSpatialRefAgreementWithInputImage(A,R_A);
    inputSpatialReferencingNotSpecified = false;
    
    if nargin > 2
        translation_in = varargin{3};
        methodStrStartIdx = coder.internal.const(4);
        if nargin > 3 && ~(strncmpi(varargin{methodStrStartIdx},'O',1) ||...
                strncmpi(varargin{methodStrStartIdx},'F',1)) %allow partial string matching
            coder.internal.errorIf(~coder.internal.isConst(varargin{methodStrStartIdx}),...
                'MATLAB:images:validate:codegenInputNotConst','Interpolation method');
            interpolationMethod = validateInterpMethod(varargin{methodStrStartIdx});
            paramValStartIdx = coder.internal.const(methodStrStartIdx+1);
        else
            interpolationMethod = 'linear';
            coder.internal.errorIf(~coder.internal.isConst(interpolationMethod),...
                'MATLAB:images:validate:codegenInputNotConst','Interpolation method');
            paramValStartIdx = coder.internal.const(methodStrStartIdx);
        end
    else
        % Error out with Not enough input arguments.
        narginchk(3,3);
    end
else
    translation_in = varargin{2};
    R_A = imref2d(size(A));
    inputSpatialReferencingNotSpecified = true;
    methodStrStartIdx = coder.internal.const(3);
    if nargin > 2 && ~(strncmpi(varargin{methodStrStartIdx},'O',1) ||...
            strncmpi(varargin{methodStrStartIdx},'F',1)) %allow partial string matching
        coder.internal.errorIf(~coder.internal.isConst(varargin{methodStrStartIdx}),...
            'MATLAB:images:validate:codegenInputNotConst','Interpolation method');
        interpolationMethod = validateInterpMethod(varargin{methodStrStartIdx});
        paramValStartIdx = coder.internal.const(methodStrStartIdx+1);
    else
        interpolationMethod = 'linear';
        coder.internal.errorIf(~coder.internal.isConst(interpolationMethod),...
            'MATLAB:images:validate:codegenInputNotConst','Interpolation method');
        paramValStartIdx = coder.internal.const(methodStrStartIdx);
    end
end

validateTranslation(translation_in);
translation = double(translation_in(1,1:2));

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
else % default
    method = 'linear';
end

coder.internal.errorIf(~coder.internal.isConst(method),...
    'MATLAB:images:validate:codegenInputNotConst','Interpolation method');

[fillValues,outputView] = parseOptionalInputs(varargin{paramValStartIdx:end});

validateFillValues(fillValues);
outputView = validateOutputView(outputView);

checkFillValues(fillValues,A,translation);

end

function interpolationMethod = validateInterpMethod(interpMethod)

coder.inline('always');
coder.internal.prefer_const(interpMethod);

interpolationMethod = validatestring(interpMethod,{'nearest','linear','cubic','bilinear','bicubic'},...
    mfilename,'METHOD');

end

function outputView = validateOutputView(boundingBox)

coder.inline('always');
coder.internal.prefer_const(boundingBox);

outputView = validatestring(boundingBox,{'same','full'},...
    mfilename,'OutputView');

end

function validateFillValues(fillVal)

coder.inline('always');
coder.internal.prefer_const(fillVal);

validateattributes(fillVal,{'numeric'},...
    {'nonempty','nonsparse'},'imtranslate','FillValues');

end

function validateTranslation(translation)

coder.inline('always');
coder.internal.prefer_const(translation);

supportedNumericClasses = {'uint8','uint16','uint32','int8','int16',...
    'int32','single','double'};

validateattributes(translation,supportedNumericClasses,{'nonempty','vector','real','nonsparse','finite'},...
    mfilename,'TRANSLATION');

coder.internal.errorIf(~(numel(translation) == 2),...
    'images:imtranslate:codegenInvalidTranslationLength','TRANSLATION');

end

function checkSpatialRefAgreementWithInputImage(A,RA)

coder.inline('always');
coder.internal.prefer_const(A,RA)

coder.internal.errorIf(~sizesMatch(RA,A),...
    'images:imwarp:spatialRefDimsDisagreeWithInputImage','ImageSize','RA','A');

end

function checkFillValues(fillValues,inputImage,translation)

coder.inline('always');
coder.internal.prefer_const(fillValues,inputImage,translation)

planeAtATimeProblem = numel(translation)==2  && ~ismatrix(inputImage);

scalarFillValuesRequired = ~planeAtATimeProblem;
coder.internal.errorIf(scalarFillValuesRequired && ~isscalar(fillValues),...
    'images:imtranslate:scalarFillValueRequired','''FillValues''');

sizeImage = size(inputImage);
% MxNxP input image is treated as a special case. We allow [1xP] or
% [Px1] fillValues vector in this case.
validFillValues = isequal(sizeImage(3:end),size(fillValues)) ||...
    (isequal(ndims(inputImage),3) && isvector(fillValues)...
    && isequal(length(fillValues),sizeImage(3)));

coder.internal.errorIf(planeAtATimeProblem && ~isscalar(fillValues) && ...
    ~validFillValues, 'images:imwarp:fillValueDimMismatch',...
    '''FillValues''','''FillValues''','A');

end
