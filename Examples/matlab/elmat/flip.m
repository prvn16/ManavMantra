%FLIP Flip the order of elements
%   Y = FLIP(X) returns a vector Y with the same dimensions as X, but with the 
%   order of elements flipped. If X is a matrix, each column is flipped 
%   vertically. For N-D arrays, FLIP(X) operates on the first
%   nonsingleton dimension.
%
%   FLIP(X,DIM) works along the dimension DIM.
% 
%   For example, FLIP(X) where
%   
%       X = 1 4  produces  3 6
%           2 5            2 5
%           3 6            1 4
%
%
%   Class support for input X:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      char, logical
%
%   See also FLIPLR, FLIPUD, ROT90, PERMUTE.

%   Copyright 1984-2013 The MathWorks, Inc.
