function Z = imlincomb(varargin)
%IMLINCOMB Linear combination of images.
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An) computes K1*A1 + K2*A2 + ... +
%   Kn*An.  A1, A2, ..., An are gpuArray's with the same class and size,
%   and K1, K2, ..., Kn are real double scalars.  Z has the same size and
%   class as A1 unless A1 is logical, in which case Z is double. 
%
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An,K) computes K1*A1 + K2*A2 +
%   ... + Kn*An + K.
%
%   Z = IMLINCOMB(..., OUTPUT_CLASS) lets you specify the class of Z.
%   OUTPUT_CLASS is a string or character vector containing the name of a
%   numeric class.
%
%   Use IMLINCOMB to perform a series of arithmetic operations on a pair
%   of images, rather than nesting calls to individual arithmetic
%   functions, such as IMADD and IMMULTIPLY.  When you nest calls to the
%   arithmetic functions, and the input arrays have integer class, then
%   each function truncates and rounds the result before passing it to
%   the next function, thus losing accuracy in the final result.
%   IMLINCOMB performs all the arithmetic operations at once before
%   truncating and rounding the final result.
%
%   Each element of the output, Z, is computed individually in
%   double-precision floating point.  When Z is an integer array, elements
%   of Z that exceed the range of the integer type are truncated, and
%   fractional values are rounded. At least one of the images A1, A2, ... 
%   An needs to be a gpuArray for computation to be performed on the GPU. 
%   The scalars can also be gpuArray's.
%
%   Note:
%   -----
%   IMLINCOMB is a convenience function, enabling functions/scripts which
%   call it to accept gpuArray objects.  If your images are already on the
%   GPU, consider using ARRAYFUN to cast the pixels to a larger datatype,
%   compute the linear combination of the series of images directly, and
%   cast the data to the output type.  This will likely be more efficient
%   than using IMLINCOMB, which is a general purpose function.
%
%   For example, to perform the linear combination specified below on 3
%   uint8 images,
%
%   Z = 0.299*R + 0.587*G + 0.114*B
%
%   use the following:
%
%   fHandle = @(r,g,b) uint8( 0.299*double(r) + 0.587*double(g) +...
%   0.114*double(b) );
%
%   Z = arrayfun( fHandle, R,G,B );
%
%
%   Example 1
%   ---------
%   Scale an image by a factor of two.
%
%       I = gpuArray(imread('cameraman.tif'));
%       J = imlincomb(2,I);
%       figure, imshow(J)
%
%   Example 2
%   ---------
%   Form a difference image with the zero value shifted to 128.
%
%       I = gpuArray(imread('cameraman.tif'));
%       J = imfilter(I, fspecial('gaussian'));
%       K = imlincomb(1,I,-1,J,128); % K(r,c) = I(r,c) - J(r,c) + 128
%       figure, imshow(K)
%
%   Example 3
%   ---------
%   Add two images with a specified output class.
%
%       I = gpuArray(imread('rice.png'));
%       J = gpuArray(imread('cameraman.tif'));
%       K = imlincomb(1,I,1,J,'uint16');
%       figure, imshow(K,[])
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMMULTIPLY, IMSUBTRACT,
%            GPUARRAY.

%   Copyright 2012-2016 The MathWorks, Inc.

[ims, scalars, outputClass] = ParseInputs(varargin{:});

num_images = numel(ims);

if any(cellfun('isclass',ims,'gpuArray'))
    if num_images == 2
        % two image arrayfun.
        Z = imlincomb_twoImage(ims, scalars, outputClass);
    elseif num_images == 3
        % three image arrayfun.
        Z = imlincomb_threeImage(ims, scalars, outputClass);
    else
        % lazy evaluation.
        Z = imlincomb_lazyEval(ims, scalars, outputClass);
    end
else
    % if no images are gpuArrays, do work on the CPU.
    Z = images.internal.imlincombc(ims,scalars,outputClass);
end

%--------------------------------------------------------------------------
function out = imlincomb_twoImage(images, scalars, outputClass)
if numel(scalars)==2
    out = cast( arrayfun(@lincombTwoImage,...
        images{1},images{2},...
        scalars(1),scalars(2),0), outputClass );
else
    out = cast( arrayfun(@lincombTwoImage,...
        images{1},images{2},...
        scalars(1),scalars(2),scalars(3)), outputClass );
end

%--------------------------------------------------------------------------
function out = imlincomb_threeImage(images, scalars, outputClass)
if numel(scalars)==3
    out = cast( arrayfun(@lincombThreeImage,...
        images{1},images{2},images{3},...
        scalars(1),scalars(2),scalars(3),0), outputClass );
else
    out = cast( arrayfun(@lincombThreeImage,...
        images{1},images{2},images{3},...
        scalars(1),scalars(2),scalars(3),scalars(4)), outputClass );
end

%--------------------------------------------------------------------------
function out = imlincomb_lazyEval(images, scalars, outputClass)
% rely on lazy evaluation to chain this loop.
out = scalars(1).*double(images{1});
for n = 2 : numel(images)
    out = out + scalars(n).*double(images{n});
end
if numel(images)==numel(scalars)
    out = cast(out,outputClass);
else
    out = cast(out + scalars(end),outputClass);
end

%--------------------------------------------------------------------------
function [ims, scalars, output_class] = ParseInputs(varargin)
narginchk(2, Inf);

% get and check input type.
if strcmp(class(varargin{2}),'gpuArray') %#ok<*STISA>
    input_class = classUnderlying(varargin{2});
else
    input_class = class(varargin{2});
end

% determine output type.
if ischar(varargin{end}) || isstring(varargin{end})
    validateattributes(varargin{end}, ...
        {'char','string'},{'scalartext'}, ...
        mfilename,'OUTPUT_CLASS',numel(varargin))
    valid_strings = {'uint8' 'uint16' 'uint32' 'int8' ...
        'int16' 'int32' 'single' 'double'};
    output_class = validatestring(varargin{end}, ...
        valid_strings, mfilename, ...
        'OUTPUT_CLASS', numel(varargin));
    varargin(end) = [];
else
    if islogical(varargin{2})
        output_class = 'double';
    else
        output_class = input_class;
    end
end

% check images.
ims = varargin(2:2:end);

% check and gather scalars.
for p = 1:2:length(varargin)
    varargin{p} = gather(varargin{p});
    validateattributes(varargin{p}, {'double'}, {'real' 'nonsparse' 'scalar'}, ...
        mfilename, sprintf('K%d', (p+1)/2), p);
end
scalars = [varargin{1:2:end}];

% check image size and class.
for n = 2 : numel(ims)
    if ~isequal( size(ims{n}),size(ims{1}) )
        error(message('images:imlincomb:mismatchedSize'));
    end
    if  strcmp(class(ims{n}),'gpuArray') && ~strcmp(classUnderlying(ims{n}),input_class)...
            ||( ~strcmp(class(ims{n}),'gpuArray') && ~(strcmp(class(ims{n}),input_class)) )
        error(message('images:imlincomb:mismatchedType'));
    end
end