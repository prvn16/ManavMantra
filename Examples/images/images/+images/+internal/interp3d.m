function outputImage = interp3d(inputImage,X,Y,Z,method,fillValue, SmoothEdges)
% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.
%
% Vq = INTERP3D(V,XINTRINSIC,YINTRINSIC,ZINTRINSIC,METHOD,FILLVAL) computes 3-D
% interpolation on the input grid V at locations in the intrinsic
% coordinate system XINTRINSIC,YINTRINSIC,ZINTRINSIC. The value of the
% output grid Vq(I,J,K) is determined by performing 3-D interpolation at
% locations specified by the corresponding grid locations in
% XINTRINSIC(I,J,K), YINTRINSIC(I,J,K), ZINTRINSIC(I,J,K). XINTRINSIC,
% YINTRINSIC, and ZINTRINSIC are plaid matrices of the form constructed by
% MESHGRID.
%
% See also INTERP3, MAKERESAMPLER, MESHGRID

% Copyright 2012-2017 The MathWorks, Inc.

% Algorithm Notes
%
% This function is intentionally very similar to the MATLAB INTERP3
% function. The differences between INTERP3 and images.internal.interp3d
% are:
%
% 1) Edge behavior. This function uses the 'fill' pad method described in
% the help for makeresampler. When the interpolation kernel partially
% extends beyond the grid, the output value is determined by blending fill
% values and input grid values.
% This behavior is on by default, unless SmoothEdges is specified and set
% to false.

if(nargin==6)    
    % If not specified, default to smoothing edges
    SmoothEdges = true;
end

validateattributes(inputImage,{'numeric','logical'},{'nonsparse'},mfilename,'inputImage');

validateattributes(X,{'single','double'},{'nonsparse','real'},mfilename,'X');

validateattributes(Y,{'single','double'},{'nonsparse','real'},mfilename,'Y');

validateattributes(Z,{'single','double'},{'nonsparse','real'},mfilename,'Z');

validateattributes(fillValue,{'numeric','logical'},{'nonsparse'},mfilename,'fillValue');
fillValue = cast(fillValue, 'like', inputImage);

if(SmoothEdges)
    [inputImage,X,Y,Z] = padImage(inputImage,X,Y,Z,fillValue);
end

% For now we only have an optimized codepath for interp3 for the linear
% interpolation case.
if strcmp(method,'linear')
    if isa(inputImage, 'single')
        X = single(X); Y = single(Y); Z = single(Z);
    else
        X = double(X); Y = double(Y); Z = double(Z);
    end
    if isreal(inputImage)
        outputImage = images.internal.interp3dmex(inputImage,X,Y,Z,fillValue);
    else
        outputImage = complex(images.internal.interp3dmex(real(inputImage),X,Y,Z,fillValue),...
            images.internal.interp3dmex(imag(inputImage),X,Y,Z,fillValue));
    end
            
else
    if ~isa(inputImage,'double')
        inputImage = double(inputImage);
    end
    outputImage = interp3(inputImage,X,Y,Z,method,fillValue);
end

    
function [paddedImage,X,Y,Z] = padImage(inputImage,X,Y,Z,fillValue)
% We achieve the 'fill' pad behavior from makeresampler by prepadding our
% image with the fillValue and translating our X,Y locations to the
% corresponding locations in the padded image.

pad = 3;
paddedImage = padarray(inputImage,[pad pad,pad],fillValue);
X = X+pad;
Y = Y+pad;
Z = Z+pad;
    
