function y = bitsliceget(x,left_idx,right_idx)
% BITSLICEGET Get a consecutive set of bits from the stored integer
%  representation of fi
%
% SYNTAX
%   C = BITSLICEGET(A, LEFT_IDX, RIGHT_IDX)
%   C = BITSLICEGET(A, LEFT_IDX)
%   C = BITSLICEGET(A)
%
% DESCRIPTION
%   BITSLICEGET returns the value of the consecutive set of bits in A
%   starting at bit position RIGHT_IDX (close to the LSB) and ending at
%   bit position LEFT_IDX (close to the MSB).
%
%   The input operand A must be a FI fixed-point type. Signed and unsigned
%   fixed-point types with arbitrary scaling are allowed. Signedness and
%   scaling do not affect the result because the bitwise operation is
%   performed on the twos-complement stored integer.
%
%   LEFT_IDX and RIGHT_IDX may be any FI type or any builtin numeric type.
%   LEFT_IDX and RIGHT_IDX must be constants and must satisfy the condition
%          wordlength(A)  >= LEFT_IDX >= RIGHT_IDX >= 1.
%
%   If LEFT_IDX is not specified then LEFT_IDX defaults to wordlength(A).
%   If RIGHT_IDX is not specified then RIGHT_IDX defaults to 1.
%   
%   BITSLICEGET supports non-scalar A inputs. Complex inputs are not supported.
%   The output type is always an unsigned fixed-point FI with a word length N
%   equal to the slice length (LEFT_IDX - RIGHT_IDX + 1), and fraction length 0
%   (i.e., the outputs are integer-valued, pure integer scaled FI types).
%
%   Note that BITSLICEGET behaves exactly like bitget when slicing one bit
%   only (i.e., when LEFT_IDX and RIGHT_IDX have the same numeric value).
%   For that special case, BITSLICEGET supports variable indexing.
%   Otherwise, LEFT_IDX and RIGHT_IDX must be constant scalar values.
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(1,3);

if (nargin == 3)
    [left_idx_dbl, right_idx_dbl, wl_x] = fixed.internal.checkLeftRightBitIndices(mfilename, x, left_idx, right_idx);
elseif (nargin == 2)
    [left_idx_dbl, right_idx_dbl, wl_x] = fixed.internal.checkLeftRightBitIndices(mfilename, x, left_idx);
else
    [left_idx_dbl, right_idx_dbl, wl_x] = fixed.internal.checkLeftRightBitIndices(mfilename, x);
end

% Determine the output numerictype & fimath
% Output numerictype is unsigned, WL = left_idx-right_idx + 1 & FL = 0
nt_y = numerictype(0,left_idx_dbl-right_idx_dbl + 1,0);
fm_y = fimath(x);

if isempty(x)
    y = fi(zeros(size(x)),nt_y,fm_y);
else
    % Now get the bit slice
    x1 = reshape(x,numberofelements(x),1);
    x1_bin = bin(x1);
    
    % index into bits (get lsb from right)
    y_bin = x1_bin(:,wl_x-left_idx_dbl+1:wl_x-right_idx_dbl+1);
    
    % Now create y
    y = fi(0,nt_y,fm_y); y.bin = y_bin;
    y = reshape(y,size(x));
end
y.fimathislocal = isfimathlocal(x);
