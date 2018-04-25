function T = convmtx2(H,M,N)
%CONVMTX2 2-D convolution matrix.
%   T=CONVMTX2(H,M,N) or T=CONVMTX2(H,[M N]) returns the
%   convolution matrix for the matrix H.  If X is an M-by-N
%   matrix, then reshape(T*X(:), size(H)+[M N]-1) is the same
%   as conv2(X,H).  
%
%   Class Support
%   -------------
%   The inputs are all of class double.  The output matrix T is
%   of class sparse.  The number of nonzero elements in T is no
%   larger than numel(H)*M*N.
%
%   Example
%   -------
%       H = ones(3,3)/9; % averaging filter 3-by-3
%       M = 5;
%       X = magic(M);
%       T = convmtx2(H,M,M);
%       Y1 = reshape(T*X(:), size(H)+[5 5]-1)
%       Y2 = conv2(X,H)
%       isequal(Y1,Y2) % They are the same.
%
%   See also CONVMTX, CONV2.

%   Copyright 1993-2015 The MathWorks, Inc.

[P, Q] = size(H);

if (nargin == 2)
  if (numel(M) ~= 2) || (min(size(M)) ~= 1)
    error(message('images:convmtx2:invalidInput'))
  else
    N = M(2);
    M = M(1);
  end
end

inputNames = {'H' 'M' 'N'};
for p=1:1:3
    validateattributes(H,{'double'},{},mfilename,inputNames{p},p);
end

blockHeight = M + P - 1;
blockWidth = M;
blockNonZeros = P * M;

totalNonZeros = Q * N * blockNonZeros;

THeight = (N+Q-1)*blockHeight;
TWidth = N*blockWidth;

Tvals = zeros(totalNonZeros,1);
Trows = zeros(totalNonZeros,1);
Tcols = zeros(totalNonZeros,1);

c = diag(1:M) * ones(M, P);
r = bsxfun(@plus, c, 0:(P-1));
r = r(:);
c = c(:);
 
r = r(:, ones(1, N));
c = c(:, ones(1, N));

colOffsets = ((1:N) - 1)*M;
colOffsets = colOffsets(ones(M*P,1), :);
colOffsets = colOffsets + c;
colOffsets = colOffsets(:);

rowOffsets = ((1:N) - 1) * blockHeight;
rowOffsets = rowOffsets(ones(M*P,1), :);
rowOffsets = rowOffsets + r;
rowOffsets = rowOffsets(:);
  
for k = 1:Q                                 % Loop over each column of H.
  val = H(:,k).';
  val = repmat(val,M,1);
  val = val(:);

  
  first = (k-1)*N*blockNonZeros + 1;
  last = first + N*blockNonZeros - 1;
  Trows(first:last) = rowOffsets;
  Tcols(first:last) = colOffsets;
  Tvals(first:last) = repmat(val, N, 1);
  
  rowOffsets = rowOffsets + blockHeight;
end

T = sparse(Trows, Tcols, Tvals, THeight, TWidth);

  
