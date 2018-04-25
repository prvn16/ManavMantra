function y = bitandreduce(x,left_idx,right_idx)
% BITANDREDUCE Reduce consecutive slice of bits to one bit by performing bitwise AND operation
%
% SYNTAX
%   C = BITANDREDUCE(A, LEFT_IDX, RIGHT_IDX)
%   C = BITANDREDUCE(A, LEFT_IDX)
%   C = BITANDREDUCE(A)
%
% DESCRIPTION
%   BITANDREDUCE(A, LEFT_IDX, RIGHT_IDX) performs a bitwise-and operation on
%   a consecutive set of bits in A, starting at RIGHT_IDX (close to the LSB)
%   and ending at LEFT_IDX (close to the MSB). It returns a zero or one
%   result value in an unsigned 1-bit FI fixed-point data type.
%
%   The input operand A must be a FI fixed-point type. Signed and unsigned
%   fixed-point types with arbitrary scaling are allowed. Signedness and
%   scaling do not affect the result because the bitwise operation is
%   performed on the twos-complement stored integer.
%   
%   Complex inputs are not supported.
%
%   LEFT_IDX and RIGHT_IDX may be any FI type or any builtin numeric type.
%   LEFT_IDX and RIGHT_IDX must be constants and must satisfy the condition
%          wordlength(A)  >= LEFT_IDX >= RIGHT_IDX >= 1.
%
%   If LEFT_IDX is not specified then LEFT_IDX defaults to wordlength(A).
%   If RIGHT_IDX is not specified then RIGHT_IDX defaults to 1.
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITORREDUCE,  EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(1,3);

if (nargin == 3)
    [left_idx_dbl, right_idx_dbl] = fixed.internal.checkLeftRightBitIndices(mfilename, x, left_idx, right_idx);
elseif (nargin == 2)
    [left_idx_dbl, right_idx_dbl] = fixed.internal.checkLeftRightBitIndices(mfilename, x, left_idx);
else
    [left_idx_dbl, right_idx_dbl] = fixed.internal.checkLeftRightBitIndices(mfilename, x);
end

if isempty(x)
    
    y = embedded.fi(zeros(size(x)),numerictype(0,1,0),fimath(x));
    
else
    
    yslice = bitsliceget(x, left_idx_dbl, right_idx_dbl);
    
    yslice_nt = numerictype(yslice);
    yslice_fm = fimath(yslice);
    
    yall_ones = bitcmp(embedded.fi(0, yslice_nt, yslice_fm));
    
    y_nt = numerictype(0,1,0);
    y_fm = fimath(x);
    
    y = embedded.fi(yslice == yall_ones, y_nt, y_fm);
    
end

y.fimathislocal = isfimathlocal(x);
