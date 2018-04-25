function B = setPackedFillBits(A, M, value) %#codegen
% Set any fill bits in the last row of the packed array A to the specified
% value.  M is the number of rows in the original unpacked array.

%   Copyright 1993-2013 The MathWorks, Inc.

B = A;

if(isempty(A))
    return;
end

% Given the number of rows in a binary image, find the number of pad
% bits in the last row of the packed form.
num_pad_bits = 32 * ceil(M / 32) - M;
if num_pad_bits == 0
   return;
end

% Make a mask value with 0s in the fill-bit positions and 1s elsewhere.
first_mask_bit = 1;
last_mask_bit  = 32 - num_pad_bits;
bit_locations  = first_mask_bit:last_mask_bit;

% Given a vector of bit_locations, find a scalar uint32 value with those
% bits set to 1.  A bit location of 1 corresponds to the least-significant
% bit.
mask_value = uint32(0);
for k = 1:numel(bit_locations)
   mask_value = bitset(mask_value, bit_locations(k));
end

last_row = B(end,:);

if value
   modified_last_row = bitor(last_row, bitcmp(mask_value));
else
   modified_last_row = bitand(last_row, mask_value);
end

B(end, :) = modified_last_row;
