%BITGET Get bit values at specified bit positions
%
% SYNTAX
%   C = BITGET(A, BIT)
%
% DESCRIPTION
%   BITGET gets the bit values at specified bit positions in input A.
%   Input A must be a FI fixed-point data type. BIT may be any FI type
%   or any builtin numeric type. BIT must contain only numbers between
%   1 and the word length of A, inclusive. The bit positions specified
%   in BIT do not need to be sequential.
%
%   If A has a signed numerictype, then the bit representation of the stored
%   integer is in two's complement representation. BITGET does not support
%   complex inputs. BITGET supports variable indexing. This means that BIT
%   may be a variable or constant numeric values.
%
%   The input arguments A and BIT can be scalars or non-scalars (vectors, matrices,
%   or N-D arrays). A and BIT must be the same size unless one is a scalar.
%   If BIT and A are both scalar, BITGET returns the value of the bit at position
%   BIT in A in an unsigned 1-bit FI fixed-point data type. If A is a non-scalar
%   and BIT is a scalar, it returns a non-scalar array of unsigned 1-bit
%   fixed-point bit values at position BIT for each object in array A. If A is a
%   scalar and BIT is a non-scalar, it returns a non-scalar array of unsigned
%   1-bit fixed-point values of the bits in A at each of the positions specified
%   in BIT.
%
%   Example:
%     a = fi(-4:4,1,16,0)
%     c = bitget(a,1)
%     % returns bit 1, the least-significant bit of each number:
%     %  0     1     0     1     0     1     0     1     0
%     % Note the even (0), odd (1) least-significant bits.
%
%   See also EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT
%            EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITOR, 
%            EMBEDDED.FI/BITSET, EMBEDDED.FI/BITXOR.

%   Copyright 1999-2013 The MathWorks, Inc.
