function a = idct2(arg1,mrows,ncols)
%IDCT2 2-D inverse discrete cosine transform.
%   B = IDCT2(A) returns the two-dimensional inverse discrete
%   cosine transform of A.
%
%   B = IDCT2(A,[M N]) or B = IDCT2(A,M,N) pads A with zeros (or
%   truncates A) to create a matrix of size M-by-N before
%   transforming. 
%
%   For any A, IDCT2(DCT2(A)) equals A to within roundoff error.
%
%   The discrete cosine transform is often used for image
%   compression applications.
%
%   Class Support
%   -------------
%   The input matrix A can be of class double or of any
%   numeric class. The output matrix B is of class double.
%
%   Example
%   -------
%       RGB = imread('autumn.tif');
%       I = rgb2gray(RGB);
%       J = dct2(I);
%       imshow(log(abs(J)),[]), colormap(gca,jet), colorbar
%
%   The commands below set values less than magnitude 10 in the
%   DCT matrix to zero, then reconstruct the image using the
%   inverse DCT function IDCT2.
%
%       J(abs(J)<10) = 0;
%       K = idct2(J);
%       figure, imshow(I)
%       figure, imshow(K,[0 255])
%
%   See also DCT2, DCTMTX, FFT2, IFFT2.

%   Copyright 1992-2016 The MathWorks, Inc.

%   References: 
%   1) A. K. Jain, "Fundamentals of Digital Image
%      Processing", pp. 150-153.
%   2) Wallace, "The JPEG Still Picture Compression Standard",
%      Communications of the ACM, April 1991.

[m, n] = size(arg1);
% Basic algorithm.
if (nargin == 1),
  if (m > 1) && (n > 1),
    a = idct(idct(arg1).').';
    return;
  else
    mrows = m;
    ncols = n;
  end
end

% Padding for vector input.

b = arg1;
if nargin==2, 
    ncols = mrows(2); 
    mrows = mrows(1); 
end

mpad = mrows; npad = ncols;
if m == 1 && mpad > m, b(2, 1) = 0; m = 2; end
if n == 1 && npad > n, b(1, 2) = 0; n = 2; end
if m == 1, mpad = npad; npad = 1; end   % For row vector.

% Transform.

a = idct(b, mpad);
if m > 1 && n > 1, a = idct(a.', npad).'; end
