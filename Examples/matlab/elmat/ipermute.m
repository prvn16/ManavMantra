function a = ipermute(b,order)
%IPERMUTE Inverse permute array dimensions.
%   A = IPERMUTE(B,ORDER) is the inverse of permute. IPERMUTE
%   rearranges the dimensions of B so that PERMUTE(A,ORDER) will
%   produce B.  The array produced has the same values of A but the
%   order of the subscripts needed to access any particular element
%   are rearranged as specified by ORDER.  For an N-D array A, 
%   numel(ORDER)>=ndims(A). All the elements of ORDER must be unique.
%
%   PERMUTE and IPERMUTE are a generalization of transpose (.') 
%   for N-D arrays.
%
%   Example
%      a = rand(1,2,3,4);
%      b = permute(a,[3 2 1 4]);
%      c = ipermute(b,[3 2 1 4]); % a and c are equal
%
%   See also PERMUTE,SIZE.

%   Copyright 1984-2009 The MathWorks, Inc. 

inverseorder(order) = 1:numel(order);   % Inverse permutation order
a = permute(b,inverseorder);
