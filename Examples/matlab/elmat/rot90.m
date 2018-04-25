function B = rot90(A,k)
%ROT90  Rotate array 90 degrees.
%   B = ROT90(A) is the 90 degree counterclockwise rotation of matrix A. If
%   A is an N-D array, ROT90(A) rotates in the plane formed by the first and
%   second dimensions.
%
%   ROT90(A,K) is the K*90 degree rotation of A, K = +-1,+-2,...
%
%   Example,
%       A = [1 2 3      B = rot90(A) = [ 3 6
%            4 5 6 ]                     2 5
%                                        1 4 ]
%
%   See also FLIPUD, FLIPLR, FLIP.

%   Thanks to John de Pillis
%   Copyright 1984-2013 The MathWorks, Inc. 

if nargin == 1
    k = 1;
else
    if ~isscalar(k)
        error(message('MATLAB:rot90:kNonScalar'));
    end
    k = mod(k,4);
end
if k == 1
    B = flip(A,2);
    B = permute(B,[2 1 3:ndims(A)]);
elseif k == 2
    B = flip(flip(A,1),2);
elseif k == 3
    B = permute(A,[2 1 3:ndims(A)]);
    B = flip(B,2);
elseif k == 0
    B = A;
else 
    error(message('MATLAB:rot90:kNonInteger'));
end
