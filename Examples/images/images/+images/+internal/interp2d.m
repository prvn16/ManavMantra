function outputImage = interp2d(inputImage,X,Y,method,fillValues, varargin)%#codegen
% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.
%
% Vq = INTERP2D(V,XINTRINSIC,YINTRINSIC,METHOD,FILLVAL, SmoothEdges)
% computes 2-D interpolation on the input grid V at locations in the
% intrinsic coordinate system XINTRINSIC, YINTRINSIC. The value of the
% output grid Vq(I,J) is determined by performing 2-D interpolation at
% locations specified by the corresponding grid locations in
% XINTRINSIC(I,J), YINTRINSIC(I,J). XINTRINSIC and YINTRINSIC are plaid
% matrices of the form constructed by MESHGRID. When V has more than two
% dimensions, the output Vq is determined by interpolating V a slice at a
% time beginning at the 3rd dimension.
%
% See also INTERP2, MAKERESAMPLER, MESHGRID

% Copyright 2012-2016 The MathWorks, Inc.

% Algorithm Notes
%
% This function is intentionally very similar to the MATLAB INTERP2
% function. The differences between INTERP2 and images.internal.interp2d
% are:
%
% 1) Edge behavior. This function uses the 'fill' pad method described in
% the help for makeresampler. When the interpolation kernel partially
% extends beyond the grid, the output value is determined by blending fill
% values and input grid values.
% This behavior is on by default, unless SmoothEdges is specified and set
% to false.
%
% 2) Plane at a time behavior. When the input grid has more than 2 
% dimensions, this function treats the input grid as a stack of 2-D interpolation
% problems beginning at the 3rd dimension.
%
% 3) Degenerate 2-D grid behavior. Unlike interp2, this function handles
% input grids that are 1-by-N or N-by-1.

%#ok<*EMCA>

narginchk(5,6);
if(nargin==5)    
    % If not specified, default to NOT smoothing edges
    SmoothEdges = false;
else
    SmoothEdges = varargin{1};
end


inputClass = class(inputImage);

if ~coder.target('MATLAB')
    coder.inline('always');
    coder.internal.prefer_const(inputImage,X,Y,method,fillValues);
    outputImage = images.internal.coder.interp2d(inputImage,X,Y,method,fillValues, SmoothEdges);
    return;
end

validateattributes(inputImage,{'logical', 'numeric'},{'nonsparse'},mfilename,'inputImage');

validateattributes(X,{'single','double'},{'nonnan','nonsparse','real','2d'},mfilename,'X');

validateattributes(Y,{'single','double'},{'nonnan','nonsparse','real','2d'},mfilename,'Y');

validateattributes(fillValues,{'logical','numeric'},{'nonsparse'},mfilename,'fillValue');

method = validatestring(method,{'nearest','bilinear','bicubic','linear','cubic'},mfilename);

if ~isequal(size(X),size(Y))
    error(message('images:interp2d:inconsistentXYSize'));
end

if(islogical(inputImage))
    inputImage = uint8(inputImage);
end

% IPP requires that X,Y,and fillVal are of same type. We enforce this for
% both codepaths for consistency of results.
useIpp = images.internal.useIPPLibrary() && ~isProblemSizeTooBig(inputImage);
switch class(inputImage)
    case 'double'
        X = double(X);
        Y = double(Y);
    case 'single'
        X = single(X);
        Y = single(Y);
    case 'uint8'
        if(useIpp)
            X = single(X);
            Y = single(Y);
        else
            inputImage = double(inputImage);
            X = double(X);
            Y = double(Y);
        end
    otherwise
        inputImage = double(inputImage);
        X = double(X);
        Y = double(Y);
end
    
fillValues = cast(fillValues,'like', inputImage);

if (~ismatrix(inputImage) && isscalar(fillValues))
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
    fillValues = repmat(fillValues,sizeVec);
end

if useIpp
    
    if(SmoothEdges)
        [inputImage,X,Y] = padImage(inputImage,X,Y,fillValues);
    end

    % We have to account for 1 vs. 0 difference in intrinsic
    % coordinate system between remapmex and MATLAB
    X = X-1;
    Y = Y-1;
    
    if isreal(inputImage)    
        outputImage = images.internal.remapmex(inputImage,X,Y,method,fillValues);
    else
        outputImage = complex(images.internal.remapmex(real(inputImage),X,Y,method,real(fillValues)),...
                              images.internal.remapmex(imag(inputImage),X,Y,method,imag(fillValues)));
    end
            
    
else
        
    % Required since we allow uint8 inputs to interp2d and interp2 in
    % MATLAB does not support integer datatype inputs.
    if ~isfloat(inputImage)
        inputImage = single(inputImage);
    end
    
    % Preallocate outputImage so that we can call interp2 a plane at a time if
    % the number of dimensions in the input image is greater than 2.
    if ~ismatrix(inputImage)
        [~,~,P] = size(inputImage);
        sizeInputVec = size(inputImage);
        outputImage = zeros([size(X) sizeInputVec(3:end)],'like',inputImage);
    else
        P = 1;
        outputImage = zeros(size(X),'like',inputImage);
    end
    
    if(SmoothEdges)
        [inputImage,X,Y] = padImage(inputImage,X,Y,fillValues);
    end
    
    for plane = 1:P
        outputImage(:,:,plane) = interp2(inputImage(:,:,plane),X,Y,method,fillValues(plane));
    end
    

end

outputImage = cast(outputImage,inputClass);



function [paddedImage,X,Y] = padImage(inputImage,X,Y,fillValues)
% We achieve the 'fill' pad behavior from makeresampler by prepadding our
% image with the fillValues and translating our X,Y locations to the
% corresponding locations in the padded image. We pad two elements in each
% dimension to account for the limiting case of bicubic interpolation,
% which has a interpolation kernel half-width of 2.

pad = 3;
X = X+pad;
Y = Y+pad;

sizeInputImage = size(inputImage);
sizeOutputImage = sizeInputImage;
sizeOutputImage(1:2) = sizeOutputImage(1:2) + [2*pad 2*pad];

if isscalar(fillValues)
    paddedImage = repmat(fillValues,sizeOutputImage);
    if(ismatrix(inputImage))
        paddedImage(4:end-3,4:end-3,:) = inputImage;
    else
        for pInd = 1:prod(sizeOutputImage(3:end))
            paddedImage(4:end-3,4:end-3,pInd) = inputImage(:,:,pInd);
        end
    end

else
    if islogical(inputImage)
        paddedImage = false(sizeOutputImage);
    else
        paddedImage = zeros(sizeOutputImage,'like',inputImage);
    end
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
    
