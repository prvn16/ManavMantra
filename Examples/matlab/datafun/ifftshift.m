function x = ifftshift(x,dim)
%IFFTSHIFT Inverse FFT shift.
%   For vectors, IFFTSHIFT(X) swaps the left and right halves of
%   X.  For matrices, IFFTSHIFT(X) swaps the first and third
%   quadrants and the second and fourth quadrants.  For N-D
%   arrays, IFFTSHIFT(X) swaps "half-spaces" of X along each
%   dimension.
%
%   IFFTSHIFT(X,DIM) applies the IFFTSHIFT operation along the 
%   dimension DIM.
%
%   IFFTSHIFT undoes the effects of FFTSHIFT.
%
%   Class support for input X: 
%      float: double, single
%
%   See also FFTSHIFT, FFT, FFT2, FFTN, CIRCSHIFT.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin > 1
    if (~isscalar(dim)) || floor(dim) ~= dim || dim < 1
        error(message('MATLAB:ifftshift:DimNotPosInt'))
    end
    x = circshift(x,ceil(size(x,dim)/2),dim);
else
    x = circshift(x,ceil(size(x)/2));
end

