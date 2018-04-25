function outputImage_ = interp2d(inputImage__,Xin,Yin,method,fillValuesIn, varargin)%#codegen
% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.
%
% Vq = INTERP2D(V,XINTRINSIC,YINTRINSIC,METHOD,FILLVAL, SmoothEdges) computes 2-D
% interpolation on the input grid V at locations in the intrinsic
% coordinate system XINTRINSIC, YINTRINSIC.

% Copyright 2013-2018 The MathWorks, Inc.

narginchk(5,6);
if(nargin==5)
    % If not specified, default to NOT smoothing edges
    SmoothEdges = false;
else
    SmoothEdges = varargin{1};
end

%#ok<*EMCA>
coder.inline('always');
coder.internal.prefer_const(inputImage__,Xin,Yin,method,fillValuesIn);

coder.extrinsic('images.internal.coder.useSharedLibrary');
coder.extrinsic('eml_try_catch');
coder.extrinsic('gpucoder.internal.getPrecisionClassType');
coder.extrinsic('gpufeature');

validateattributes(inputImage__,{'logical','numeric'},{'nonsparse'},mfilename,'inputImage');

validateattributes(Xin,{'single','double'},{'nonnan','nonsparse','real','2d'},mfilename,'X');

validateattributes(Yin,{'single','double'},{'nonnan','nonsparse','real','2d'},mfilename,'Y');

validateattributes(fillValuesIn,{'logical','numeric'},{'nonsparse'},mfilename,'fillValue');

validatestring(method,{'nearest','bilinear','bicubic','linear','cubic'},mfilename);

eml_invariant(eml_is_const(method),...
    eml_message('images:interp2d:interpStringNotConst'),...
    'IfNotConst','Fail');

coder.internal.errorIf(~isequal(size(Xin),size(Yin)),...
    'images:interp2d:inconsistentXYSize');

inputClass = class(inputImage__);

useSharedLibrary = coder.const(images.internal.coder.useSharedLibrary());
useSharedLibrary = useSharedLibrary && ...
    coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(~images.internal.coder.useSingleThread()) && ...
    coder.const(~(coder.isRowMajor && numel(size(inputImage__))>2));

% iptgetpref preference (obtained at compile time)
myfun      = 'iptgetpref';
[errid, errmsg, ippPrefFlag] = eml_try_catch(myfun, 'UseIPPL');
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
ippPrefFlag = coder.internal.const(ippPrefFlag);
eml_lib_assert(isempty(errmsg), errid, errmsg);
useRemap = ~isProblemSizeTooBig(inputImage__);
useIpp = ippPrefFlag && useRemap;


if(islogical(inputImage__))
    inputImage_ = uint8(inputImage__);
else
    inputImage_ = inputImage__;
end

% IPP requires that X,Y,and fillVal are of same type. We enforce this for
% both codepaths for consistency of results.

switch class(inputImage_)
    case 'double'
        inputImage = inputImage_;
        X_ = double(Xin);
        Y_ = double(Yin);
    case 'single'
        inputImage = inputImage_;
        X_ = single(Xin);
        Y_ = single(Yin);
    case 'uint8'
        % Added isGpuEnabled check here for uint8 case.
        % uint8 input indices are typecasted to 'single' which gives
        % better performance on GPU over typecasting to 'double'
        if(coder.gpu.internal.isGpuEnabled)
            % Using gpufeature to get value of set precision. 
            % If 'enableDoublePrecision' is set to 'on', then 'double'
            % precision is used. Default is 'single' precision.
            precisionSetValue = gpufeature('enableDoublePrecision');
            qryPointsClass = coder.const(@gpucoder.internal.getPrecisionClassType, coder.const(precisionSetValue));
            % The input image typecasting should be followed like 'else' part
            % of this case. The typecasted input image class is used in the 
            % later stage to typecast the fillValues. Previously, there was no input 
            % image typecasting. So, the input image class remains as uint8.
            % If the fillValues value is > than 255, while typecasting
            % they are truncated to 255 and produced numerical mismatches 
            % between GPU and Simulation. Refer Geck g1706643.
            inputImage = double(inputImage_);
            
            X_ = cast(Xin, qryPointsClass);
            Y_ = cast(Yin, qryPointsClass);
        elseif(useIpp)
            inputImage = inputImage_;
            X_ = single(Xin);
            Y_ = single(Yin);
        else
            inputImage = double(inputImage_);
            X_ = double(Xin);
            Y_ = double(Yin);
        end
    otherwise
        inputImage = double(inputImage_);
        X_ = double(Xin);
        Y_ = double(Yin);
end

fillValues = cast(fillValuesIn, 'like', inputImage);

if ((numel(size(inputImage)) ~= 2) && isscalar(fillValues))
    % If we are doing plane at at time behavior, make sure fillValues
    % always propogates through code as a matrix of size determine by
    % dimensions 3:end of inputImage.
    sizeInputImage = size(inputImage);
    if (numel(size(inputImage)) == 3)
        % This must be handled as a special case because repmat(X,N)
        % replicates a scalar X as a NxN matrix. We want a Nx1 vector.
        sizeVec = [sizeInputImage(3) 1];
    else
        sizeVec = sizeInputImage(3:end);
    end
    fill = repmat(fillValues,sizeVec);
    
else
    fill = fillValues;
end

if (useSharedLibrary)
    % MATLAB Host Target (PC)
    
    if useIpp
        
        % remapmex only accepts nearest,bilinear and bicubic as method strings in code
        % generation.
        if strcmp(method,'linear')
            methodStr = 'bilinear';
        elseif strcmpi(method,'cubic')
            methodStr = 'bicubic';
        else
            methodStr = method;
        end
        
        if(SmoothEdges)
            [inputImage_padded,X,Y] = padImage(inputImage,X_,Y_,fill);
        else
            inputImage_padded = inputImage;
            X = X_;
            Y = Y_;
        end
        
        % We have to account for 1 vs. 0 difference in intrinsic
        % coordinate system between remapmex and MATLAB
        X = X-1;
        Y = Y-1;
        
        if isreal(inputImage_padded)
            outputImage = images.internal.coder.remapmex(inputImage_padded,X,Y,methodStr,fill);
        else
            outputImage = complex(images.internal.coder.remapmex(real(inputImage_padded),X,Y,methodStr,real(fill)),...
                images.internal.coder.remapmex(imag(inputImage_padded),X,Y,methodStr,imag(fill)));
        end
        
    else
        outputImage = interpolate_interp2(inputImage,X_,Y_,method,fill, SmoothEdges);
    end
    
else
    % Non-PC Target
    outputImage = interpolate_interp2(inputImage,X_,Y_,method,fill, SmoothEdges);
end

outputImage_ = cast(outputImage, inputClass);

function outputImage = interpolate_interp2(inputImageIn,X_,Y_,method,fill, SmoothEdges)

% Required since we allow uint8 inputs to interp2d and interp2 in
% MATLAB does not support integer datatype inputs.
if ~isfloat(inputImageIn)
    inputImage_ = single(inputImageIn);
else
    inputImage_ = inputImageIn;
end

coder.inline('always');
coder.internal.prefer_const(inputImage_,X_,Y_,method,fill, SmoothEdges);

% interp2 only accepts nearest,linear and cubic as method strings in code
% generation.
if strcmp(method,'bilinear')
    methodStr = 'linear';
elseif strcmpi(method,'bicubic')
    methodStr = 'cubic';
else
    methodStr = method;
end

% Preallocate outputImage so that we can call interp2 a plane at a time if
% the number of dimensions in the input image is greater than 2.
if ~ismatrix(inputImage_)
    [~,~,P] = size(inputImage_);
    sizeInputVec = size(inputImage_);
    outputImage = zeros([size(X_) sizeInputVec(3:end)],'like',inputImage_);
else
    P = 1;
    outputImage = zeros(size(X_),'like',inputImage_);
end

if(SmoothEdges)
    [inputImage,X,Y] = padImage(inputImage_,X_,Y_,fill);
else
    inputImage = inputImage_;
    X = X_;
    Y = Y_;
end

% Codegen requires calling interp2 with spatial referencing information for
% the grid pixel center locations.

if ~isa(inputImage,'double')
    XIntrinsic = single(1:size(inputImage,2));
    YIntrinsic = single(1:size(inputImage,1));
else
    XIntrinsic = 1:size(inputImage,2);
    YIntrinsic = 1:size(inputImage,1);
end


for plane = 1:P
    outputImage(:,:,plane) = interp2(...
        XIntrinsic,...
        YIntrinsic,...
        inputImage(:,:,plane),...
        X,Y,methodStr,fill(plane));
end


function [paddedImage,X,Y] = padImage(inputImage,X,Y,fillValues)
% We achieve the 'fill' pad behavior from makeresampler by prepadding our
% image with the fillValues and translating our X,Y locations to the
% corresponding locations in the padded image. We pad two elements in each
% dimension to account for the limiting case of bicubic interpolation,
% which has a interpolation kernel half-width of 2.

coder.inline('always');
coder.internal.prefer_const(inputImage,X,Y,fillValues);

pad = 3;
X = X+pad;
Y = Y+pad;

if isscalar(fillValues) && (numel(size(inputImage)) == 2)
    % fillValues must be scalar and inputImage must be compile-time 2D
    paddedImage = padarray(inputImage,[pad pad],fillValues);
else
    sizeInputImage = size(inputImage);
    sizeOutputImage = sizeInputImage;
    sizeOutputImage(1) = sizeOutputImage(1) + 2*pad;
    sizeOutputImage(2) = sizeOutputImage(2) + 2*pad;
    paddedImage = zeros(sizeOutputImage,'like',inputImage);
    [~,~,numPlanes] = size(inputImage);
    for i = 1:numPlanes
        paddedImage(:,:,i) = padarray(inputImage(:,:,i),[pad pad],fillValues(i));
    end
    
end

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
