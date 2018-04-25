function Z = imadd(X,Y,outputClass)
%IMADD Add two images or add constant to image.
%   Z = IMADD(X,Y) adds each element in array X to the corresponding      
%   element in array Y and returns the sum in the corresponding element
%   of the output array Z.  X and Y are real, nonsparse, numeric arrays
%   or logical arrays with the same size and class, or Y is a scalar
%   double.  Z has the same size and class as X unless X is logical, in
%   which case Z is double.
%
%   If Z is an integer array, then elements in the output that exceed the
%   range of the integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are numeric arrays of the same size and class, you can use the
%   expression X+Y instead of IMADD.
%
%   Example 1
%   ---------
%   Add two images together:
%
%       I = imread('rice.png');
%       J = imread('cameraman.tif');
%       K = imadd(I,J);
%       figure, imshow(K)
%
%   Example 2
%   ---------
%   Add a constant to an image:
%
%       I = imread('rice.png');
%       Iplus50 = imadd(I,50);
%       figure, imshow(I), figure, imshow(Iplus50)
%
%   See also IMABSDIFF, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY, 
%            IMSUBTRACT.

%   Copyright 1993-2015 The MathWorks, Inc.

if nargin > 2
    outputClass = convertStringsToChars(outputClass);
end

inputClass = class(X);
if nargin == 2
    if isa(X,'logical')
        outputClass = 'double';
    else
        outputClass = inputClass;
    end
end

scalarDoubleY = isa(Y,'double') && numel(Y) == 1;

sameInputOutputClass = strcmp(inputClass, outputClass);
if sameInputOutputClass
    xAndYSameSizeAndClass = isequal(size(X),size(Y)) && ...
        strcmp(inputClass, class(Y));

    if scalarDoubleY || xAndYSameSizeAndClass
        validateattributes(X, {'numeric','logical'}, {'real', 'nonsparse'}, ...
            mfilename, 'X', 1);
        if scalarDoubleY
            validateattributes(Y, {'double'}, {'real', 'nonsparse'}, ...
                mfilename, 'Y', 2);
        else
            validateattributes(Y, {'numeric','logical'}, {'real', 'nonsparse'}, ...
                mfilename, 'Y', 2);
        end
        Z = X + Y;
    else
        error(message('images:imadd:invalidInput'))
    end

elseif scalarDoubleY
    Z = imlincomb(1.0, X, Y, outputClass);

else
    Z = imlincomb(1.0, X, 1.0, Y, outputClass);
end
