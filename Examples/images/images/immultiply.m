function Z = immultiply(X,Y)
%IMMULTIPLY Multiply two images or multiply image by constant.
%   Z = IMMULTIPLY(X,Y) multiplies each element in the array X by the
%   corresponding element in the array Y and returns the product in the
%   corresponding element of the output array Z.
%   
%   If X and Y are real numeric arrays with the same size and class, then
%   Z has the same size and class as X.  If X is a numeric array and Y is
%   a scalar double, then Z has the same size and class as X.
%
%   If X is logical and Y is numeric, then Z has the same size and class
%   as Y.  If X is numeric and Y is logical, then Z has the same size and
%   class as X.
%
%   IMMULTIPLY computes each element of Z individually in
%   double-precision floating point.  If X is an integer array, then
%   elements of Z exceeding the range of the integer type are truncated,
%   and fractional values are rounded.
%
%   If X and Y are numeric arrays of the same size and class, you can use the
%   expression X.*Y instead of IMMULTIPLY.
%
%   Example
%   -------
%   Multiply two uint8 images with the result stored in a uint16 image:
%
%       I = imread('moon.tif');
%       I16 = uint16(I);
%       J = immultiply(I16,I16);
%       figure, imshow(I), figure, imshow(J)
%
%   Scale an image by a constant factor:
%
%       I = imread('moon.tif');
%       J = immultiply(I,0.5);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.

%   Copyright 1993-2015 The MathWorks, Inc.

validateattributes(X, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'X', 1);
validateattributes(Y, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'Y', 1);

if islogical(X) || islogical(Y)
    Z = doLogicalMultiplication(X,Y);

elseif numel(Y) == 1 && isa(Y, 'double')
    Z = X .* Y;

else
    checkForSameSizeAndClass(X, Y, mfilename);
    if isempty(Y) 
        Z = zeros(size(Y), class(Y));
    else
        Z = X .* Y;
    end
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = doLogicalMultiplication(X,Y)

if ~isequal(size(X), size(Y))
    error(message('images:immultiply:mismatchedSize'));
end

if islogical(X) && islogical(Y)
    Z = X & Y;
    
elseif islogical(X) && isnumeric(Y)
    Z = Y;
    Z(~X) = 0;
    
else
    %numeric X, logical Y
    Z = X;
    Z(~Y) = 0;
end
    
