function Z = imdivide(X,Y)
%IMDIVIDE Divide two images or divide image by constant.
%   Z = IMDIVIDE(X,Y) divides each element in the array X by the
%   corresponding element in array Y and returns the result in the
%   corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same size and class, or
%   Y can be a scalar double.  Z has the same size and class as X and Y
%   unless X is logical, in which case Z is double.
%
%   If X is an integer array, elements in the output that exceed the
%   range of integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are numeric arrays of the same size and class, you can use the
%   expression X./Y instead of IMDIVIDE.
%
%   Example
%   -------
%   Estimate and divide out the background of the rice image:
%
%       I = imread('rice.png');
%       background = imopen(I,strel('disk',15));
%       Ip = imdivide(I,background);
%       figure, imshow(Ip,[])
%
%   Divide an image by a constant factor:
%
%       I = imread('rice.png');
%       J = imdivide(I,2);
%       figure, imshow(I)
%       figure, imshow(J)
%
%   See also IMADD, IMCOMPLEMENT, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 

%   Copyright 1993-2015 The MathWorks, Inc.

if numel(Y) == 1 && isa(Y,'double')
    Z = X ./ Y;
elseif islogical(X) && islogical(Y)
    validateattributes(X,{'logical'},{'real'},mfilename,'X',1);
    validateattributes(Y,{'logical'},{'real'},mfilename,'Y',2);
    Z = double(X) ./ double(Y);
else
  validateattributes(X, {'numeric'}, {'real'}, mfilename, 'X', 1);
  validateattributes(Y, {'numeric'}, {'real'}, mfilename, 'Y', 2);
  checkForSameSizeAndClass(X, Y, mfilename);
  
  if isempty(Y)
      Z = zeros(size(Y), class(Y));
  else
      Z = X ./ Y;
  end
end


 
