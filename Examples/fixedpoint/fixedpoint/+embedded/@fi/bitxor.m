%BITXOR  Bitwise exclusive OR of two fi objects
%   C = BITXOR(A, B) returns bitwise exclusive OR of fi objects A and B in
%   fi object C.    
%
%   The numerictype of A and B must be identical. If both inputs have an 
%   attached fimath object, the fimath objects must be identical. If the 
%   numerictype is 'signed', then the bit representation of the stored integer 
%   is in two's complement representation.
%   A and B must have the same dimensions unless one is a scalar.
%   BITXOR only supports fi objects with fixed-point data types.
%
%   See also EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITGET, 
%            EMBEDDED.FI/BITOR, EMBEDDED.FI/BITSET

%   Copyright 1999-2012 The MathWorks, Inc.
