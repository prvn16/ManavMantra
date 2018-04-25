function I = mat2gray(A,limits)
%MAT2GRAY Convert gpuArray to intensity image.
%   I = MAT2GRAY(A,[AMIN AMAX]) converts the gpuArray A to the intensity
%   image I. The returned gpuArray image I contains values in the range 0.0
%   (black) to 1.0 (full intensity or white).  AMIN and AMAX are the values
%   in A that correspond to 0.0 and 1.0 in I.  Values less than AMIN become
%   0.0, and values greater than AMAX become 1.0.
%
%   I = MAT2GRAY(A) sets the values of AMIN and AMAX to the minimum and
%   maximum values in A.
%
%   Class Support
%   -------------
%   The input gpuArray A can be logical or numeric. The output image I is
%   double.
%
%   Example
%   -------
%       I = gpuArray(imread('rice.png'));
%       J = filter2(fspecial('sobel'), I);
%       K = mat2gray(J);
%       figure, imshow(I), figure, imshow(K)
%
%   See also GRAY2IND, IND2GRAY, GPUARRAY/RGB2GRAY, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

if(~isa(A, 'gpuArray'))
    % Has to be two inputs, with limits on the gpu
    limits = gather(limits);
    I = mat2gray(A, limits);
    return;
end

hValidateAttributes(A,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','nonsparse'},mfilename,'A',1);


if nargin == 1
    % obtain limits
    s.type = '()';
    s.subs = {':'};
    Aall   = subsref(A,s);
    limits = double([min(Aall) max(Aall)]);
    limits = gather(limits);
else
    % limits given
    limits = gather(limits);
    validateattributes(limits,{'double'},{'numel',2},mfilename,'LIMITS',2);
end

I = double(A);

if(limits(2)==limits(1))
    % we still need to do the 0-1 bounds check.
    delta  = 1;
    offset = 0;
else
    delta  = 1/( limits(2) - limits(1));
    offset = limits(1)*delta;
end

I = arrayfun(@scalePixels, I);

    %---------------------------------------
    function pixelOut = scalePixels(pixelIn)
        % scale
        pixelOut = pixelIn*delta - offset;
        % bounds check
        pixelOut = min(1, pixelOut);
        pixelOut = max(0, pixelOut);
    end

end