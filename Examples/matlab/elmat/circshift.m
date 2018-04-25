%CIRCSHIFT Shift positions of elements circularly.
%   Y = CIRCSHIFT(X,K) where K is an integer scalar circularly shifts 
%   the elements in the array X by K positions. If X is a vector and K is
%   positive, then the values of X are circularly shifted from the beginning 
%   to the end. If K is negative, they are shifted from the end to the 
%   beginning. If X is a matrix, CIRCSHIFT shifts along columns. If X is an
%   N-D array, CIRCSHIFT shifts along the first nonsingleton dimension.
%   
%   Y = CIRCSHIFT(X,K,DIM) circularly shifts along the dimension DIM.
%
%   Y = CIRCSHIFT(X,V) circularly shifts the values in the array X
%   by V elements. V is a vector of integers where the N-th element 
%   specifies the shift amount along the N-th dimension of
%   array X. 
%
%   Examples:
%      A = [ 1 2 3; 4 5 6; 7 8 9];
%      B = circshift(A,1) % circularly shifts first dimension values down by 1.
%      B =     7     8     9
%              1     2     3
%              4     5     6
%      B = circshift(A,[1 -1]) % circularly shifts first dimension values
%                              % down by 1 and second dimension left by 1.
%      B =     8     9     7
%              2     3     1
%              5     6     4
%
%   See also FFTSHIFT, SHIFTDIM, PERMUTE.

%   Copyright 1984-2015 The MathWorks, Inc.
