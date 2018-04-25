function b = permute(a,order)
%PERMUTE Permute dimensions of a categorical array.
%   B = PERMUTE(A,ORDER) rearranges the dimensions of the categorical array A
%   so that they are in the order specified by the vector ORDER.  The array
%   produced has the same values as A but the order of the subscripts needed
%   to access any particular element are rearranged as specified by ORDER. The
%   elements of ORDER must be a rearrangement of the numbers from 1 to N.
%
%   See also IPERMUTE, CIRCSHIFT.

%   Copyright 2006-2013 The MathWorks, Inc. 

b = a;
% Call the built-in to ensure correct dispatching regardless of what's in order
b.codes = builtin('permute',a.codes,order);
