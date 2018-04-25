function Z = imabsdiff(varargin)
%IMABSDIFF Absolute difference of two images.
%   Z = IMABSDIFF(X,Y) subtracts each element in array Y from the
%   corresponding element in array X and returns the absolute difference in
%   the corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same class and size.  Z
%   has the same class and size as X and Y.  If X and Y are integer
%   arrays, elements in the output that exceed the range of the integer
%   type are truncated.
%
%   If X and Y are double arrays, you can use the expression ABS(X-Y)
%   instead of this function.  If X and Y are logical arrays, you can use
%   the expression XOR(A,B) instead of this function.
%
%   Performance Note
%   ----------------
%   This function may take advantage of hardware optimization for datatypes
%   uint8, int16, and single to run faster.  Hardware optimization requires
%   that arrays X and Y are of the same size and class.
%
%   Example
%   -------
%   Display the absolute difference between a filtered image and the
%   original.
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imabsdiff(I,J);
%       figure, imshow(K,[])
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.  

%   Copyright 1993-2016 The MathWorks, Inc.

narginchk(2,2);

X = varargin{1};
Y = varargin{2};
validateattributes(X, {'numeric','logical'}, {'real'}, mfilename, 'X', 1);
validateattributes(Y, {'numeric','logical'}, {'real'}, mfilename, 'Y', 2);

checkForSameSizeAndClass(X, Y, mfilename);

if isempty(X)
    if islogical(X)
        Z = false(size(X));
    else
        Z = zeros(size(X), class(X));
    end
else
    Z = imabsdiffmex(X,Y);
end


