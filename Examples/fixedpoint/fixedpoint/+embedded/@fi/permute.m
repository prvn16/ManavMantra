function B = permute(A,P)
%PERMUTE Permute array dimensions
%   Refer to the MATLAB PERMUTE reference page for more information.
%
%   See also PERMUTE

%   Thomas A. Bryan, 19 January 2004
%   Copyright 1999-2014 The MathWorks, Inc.

% If trivial permutation, then B=A
if numel(A)==1 || isequal(P,1:ndims(A))
  B = copy(A);
  return
end

% Nontrivial permutation of 2D array is the transpose.
if ismatrix(A) && isequal([2 1],P)
  B = A.';
  return
end

% Nontrivial permutation when either the array A is N-dimensional, or the
% permutation P is N-dimensional.
% Use builtin PERMUTE on the intarray.
[I,numchunks] = intarray(A);
if numchunks==1
  I = permute(I,double(P));
else
  I = reshape(I,[numchunks size(A)]);
  I = permute(I,double([1,P+1]));
  % Append a trailing singleton dimension because the reshape and
  % permutation may have squeezed a trailing singleton dimension. The
  % following reshape will do the right thing with respect to this added
  % trailing singleton dimension. Adding an extra singleton dimension even
  % when not needed does no harm.
  siz = [size(I), 1];
  I = reshape(I,[(siz(1)*siz(2)) siz(3:end)]);
end
B = copy(A);
B.intarray = I;

% LocalWords:  intarray numchunks siz
