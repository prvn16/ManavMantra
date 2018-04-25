function Z = imlincomb(varargin)
%IMLINCOMB Linear combination of images.
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An) computes K1*A1 + K2*A2 + ... +
%   Kn*An.  A1, A2, ..., An are real, non-sparse, numeric arrays with the
%   same class and size, and K1, K2, ..., Kn are real double scalars.  Z
%   has the same size and class as A1 unless A1 is logical, in which case
%   Z is double.
%
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An,K) computes K1*A1 + K2*A2 +
%   ... + Kn*An + K.
%
%   Z = IMLINCOMB(..., OUTPUT_CLASS) lets you specify the class of Z.
%   OUTPUT_CLASS is a string or character vector containing the name of a
%   numeric class.
%
%   Each element of the output, Z, is computed individually in
%   double-precision floating point.  When Z is an integer array, elements
%   of Z that exceed the range of the integer type are truncated, and
%   fractional values are rounded.
%
%   Example 1
%   ---------
%   Scale an image by a factor of two.
%
%       I = imread('cameraman.tif');
%       J = imlincomb(2,I);
%       figure, imshow(J)
%
%   Example 2
%   ---------
%   Form a difference image with the zero value shifted to 128.
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imlincomb(1,I,-1,J,128); % K(r,c) = I(r,c) - J(r,c) + 128
%       figure, imshow(K)
%
%   Example 3
%   ---------
%   Add two images with a specified output class.
%
%       I = imread('rice.png');
%       J = imread('cameraman.tif');
%       K = imlincomb(1,I,1,J,'uint16');
%       figure, imshow(K,[])
%
%   See also IMCOMPLEMENT.

%   Copyright 1993-2016 The MathWorks, Inc.

% I/O spec
% ========
% A1, ...       Real, numeric, full arrays
%               Logical arrays also allowed, and are converted to uint8.
%
% K1, ...       Real, double scalars
%
% OUTPUT_CLASS  Case-insensitive nonambiguous abbreviation of one of
%               these strings: uint8, uint16, uint32, int8, int16, int32,
%               single, double

[ims, scalars, outputClass] = ParseInputs(varargin{:});

sameInputOutputClass = strcmp(class(ims{1}), outputClass);
if sameInputOutputClass
    if imagePlusImage(ims,scalars)
        Z = ims{1} + ims{2};
    elseif image1MinusImage2(ims,scalars)
        Z  = ims{1} - ims{2};
    elseif image2MinusImage1(ims,scalars)
        Z = ims{2} - ims{1};
    elseif imagePlusScalar(ims,scalars)
        Z = ims{1} + scalars(2);
    else
        Z = images.internal.imlincombc(ims, scalars, outputClass);
    end
else
    Z = images.internal.imlincombc(ims, scalars, outputClass);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = imagePlusImage(images,scalars)

    valid = numel(images) == 2 && numel(scalars) == 2 && ...
        all(scalars == 1); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = image1MinusImage2(images,scalars)

    valid = numel(images) == 2 && numel(scalars) == 2 && ...
        scalars(1) == 1 && scalars(2) == -1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = image2MinusImage1(images,scalars)

    valid = numel(images) == 2 && numel(scalars) == 2 && ...
        scalars(1) == -1 && scalars(2) == 1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = imagePlusScalar(images,scalars)

    valid = numel(images) == 1 && numel(scalars) == 2 && ...
        scalars(1) == 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [images, scalars, output_class] = ParseInputs(varargin)

narginchk(2, Inf);

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
        output_class = class(varargin{2});
    end
end

%check images
images = varargin(2:2:end);
if ~iscell(images) || isempty(images)
    displayInternalError('images');
end

% assign and check scalars
for p = 1:2:length(varargin)
    validateattributes(varargin{p}, {'double'}, {'real' 'nonsparse' 'scalar'}, ...
        mfilename, sprintf('K%d', (p+1)/2), p);
end
scalars = [varargin{1:2:end}];

%make sure it is a vector
if ( ~ismatrix(scalars) || (all(size(scalars)~=1) && any(size(scalars)~=0)) )
    displayInternalError('scalars');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayInternalError(string)

error(message('images:imlincomb:internalError', upper( string )))
