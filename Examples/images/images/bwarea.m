function a = bwarea(b)
%BWAREA Area of objects in binary image.
%   TOTAL = BWAREA(BW) estimates the area of the objects in
%   binary image BW. TOTAL is a scalar whose value corresponds
%   roughly to the total number of "on" pixels in the image, but
%   may not be exactly the same because different patterns of
%   pixels are weighted differently.
%
%   Class Support
%   -------------
%   BW can be numeric or logical. In case of the numeric input,
%   any non-zero pixels are considered to be "on". 
%   TOTAL is of class double.
%
%   Example
%   -------
%       BW = imread('circles.png');
%       figure, imshow(BW)
%       bwarea(BW)
%
%   See also BWPERIM, BWEULER.

%   Copyright 1992-2012 The MathWorks, Inc.

% Reference: William Pratt, Digital Image Processing, John Wiley
% and Sons, 1991, pp. 630-634.

validateattributes(b,{'numeric','logical'},{'nonsparse'},mfilename,'BW',1);

if ~islogical(b)
  b = b~=0;
end

lut = [0     2     2     4     2     4     6     7     2     6     4     7 ...
       4     7     7     8];

% Need to zero-pad the input.
bb = false(size(b)+2);
bb(2:end-1,2:end-1) = b;

weights = bwlookup(bb,lut);
a = sum(weights(:),[],'double')/8;





