function c = dctmtx(n)
%DCTMTX Discrete cosine transform matrix.
%   D = DCTMTX(N) returns the N-by-N DCT transform matrix.  D*A
%   is the DCT of the columns of A and D'*A is the inverse DCT of
%   the columns of A (when A is N-by-N).
%
%   If A is square, the two-dimensional DCT of A can be computed
%   as D*A*D'. This computation is sometimes faster than using
%   DCT2, especially if you are computing large number of small
%   DCT's, because D needs to be determined only once.
%
%   Class Support
%   -------------
%   N is an integer scalar of class double. D is returned 
%   as a matrix of class double.
%   
%   Example
%   -------
%       A = im2double(imread('rice.png'));
%       D = dctmtx(size(A,1));
%       dct = D*A*D';
%       figure, imshow(dct)
%
%   See also DCT2.

%   Copyright 1993-2015 The MathWorks, Inc.

%   References:
%   Jain, Fundamentals of Digital Image Processing, p. 150.

%   I/O Spec
%      N - input must be double
%      D - output DCT transform matrix is double

validateattributes(n,{'double'},{'integer' 'scalar'},mfilename,'n',1);

[cc,rr] = meshgrid(0:n-1);

c = sqrt(2 / n) * cos(pi * (2*cc + 1) .* rr / (2 * n));
c(1,:) = c(1,:) / sqrt(2);
