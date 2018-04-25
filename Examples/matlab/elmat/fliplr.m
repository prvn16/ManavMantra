function x = fliplr(x)
%FLIPLR Flip array in left/right direction.
%   Y = FLIPLR(X) returns X with the order of elements flipped left to right
%   along the second dimension. For example,
%   
%   X = 1 2 3     becomes  3 2 1
%       4 5 6              6 5 4
%
%   See also FLIPUD, ROT90, FLIP.

%   Copyright 1984-2013 The MathWorks, Inc.

x = flip(x,2);
