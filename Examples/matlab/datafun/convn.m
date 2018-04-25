function C = convn(A,B,shape)
%CONVN  N-dimensional convolution.
%   C = CONVN(A, B) performs the N-dimensional convolution of
%   matrices A and B. If nak = size(A,k) and nbk = size(B,k), then
%   size(C,k) = max([nak+nbk-1,nak,nbk]);
%
%   C = CONVN(A, B, 'shape') controls the size of the answer C:
%     'full'   - (default) returns the full N-D convolution
%     'same'   - returns the central part of the convolution that
%                is the same size as A.
%     'valid'  - returns only the part of the result that can be
%                computed without assuming zero-padded arrays.
%                size(C,k) = max([nak-max(0,nbk-1)],0).
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also CONV, CONV2.

%   Copyright 1984-2012 The MathWorks, Inc. 

if nargin < 3
  shape = 'full';
end

if ~isfloat(A)
    A = double(A);
end
if ~isfloat(B)
    B = double(B);
end

C = convnc(A,B,shape);
