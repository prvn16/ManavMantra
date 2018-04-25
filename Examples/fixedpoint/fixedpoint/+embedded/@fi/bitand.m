%BITAND Bitwise AND of two fi objects
%   C = BITAND(A, B) returns bitwise AND of fi objects A and B in fi 
%   object C.    
%
%   The numerictype of A and B must be identical. If both inputs have an 
%   attached fimath object, the fimath objects must be identical. If the 
%   numerictype is 'signed', then the bit representation of the stored
%   integer is in two's complement representation.
%   A and B must have the same dimensions unless one is a scalar.
%   BITAND only supports fi objects with fixed-point data types.
%
%   See also EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITGET, EMBEDDED.FI/BITOR, 
%            EMBEDDED.FI/BITSET, EMBEDDED.FI/BITXOR

%   Copyright 1999-2012 The MathWorks, Inc.
