%BITSET Set bit values at specified bit position
%
% SYNTAX
%   C = BITSET(A, BIT) sets bit position(s) BIT in A to 1 (on).
%   C = BITSET(A, BIT, V) sets bit position(s) BIT in A to V. V must be 0
%   (off) or 1 (on). Any value V other than 0 is automatically set to 1.
%
% DESCRIPTION
%   BITSET sets the bit values at specified bit positions in input A.
%   Input A must be a FI fixed-point data type. If A has a signed numerictype,
%   then the bit representation of the stored integer is in two's complement.
%
%   BIT and V may be any FI type or any builtin numeric type. BIT must contain
%   only numbers between 1 and the word length of A, inclusive. The bit
%   positions specified in BIT do not need to be sequential.
%
%   Inputs A, BIT, and V can be scalars or non-scalars (vectors, matrices,
%   or N-D arrays). Any input can be scalar. All non-scalar inputs must be
%   the same size.
%
%   BITSET does not support inputs with complex data types.
%
%   Example:
%     a = fi(-4:4,1,16,0)
%     c = bitset(a,1,1)
%     % sets bit 1, the least-significant bit of each number and returns:
%     % -3    -3    -1    -1     1     1     3     3     5
%     % Note that it turned them all into odd numbers.
%
%   See also EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITGET, 
%            EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR

%   Copyright 1999-2013 The MathWorks, Inc.
