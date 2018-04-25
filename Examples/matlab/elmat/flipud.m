function x = flipud(x)
%FLIPUD Flip array in up/down direction.
%   Y = FLIPUD(X) returns X with the order of elements flipped upside down
%   along the first dimension.  For example,
%   
%   X = 1 4      becomes  3 6
%       2 5               2 5
%       3 6               1 4
%
%   See also FLIPLR, ROT90, FLIP.

%   Copyright 1984-2013 The MathWorks, Inc.

x = flip(x,1);
