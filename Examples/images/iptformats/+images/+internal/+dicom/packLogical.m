function data_out = packLogical(data_in, bits)

% Copyright 2002-2017 The MathWorks, Inc.

% Transpose the data to row-major format.
data_in = data_in';
data_in = data_in(:);

% The easiest way to pack the data is to perform matrix
% multiplication after reshaping the data to match the
% bit positions in the output data.  (Pad if necessary.)
padded_output_length = ceil(numel(data_in) / bits);
if ((numel(data_in) / bits) ~= padded_output_length)

    data_in(padded_output_length * bits) = 0;
  
end

% MATLAB doesn't support matrix multiplication of integral types,
% so use double.  (Reshape the input data to be n-by-bits and
% multiply by the bits-by-1 mask to make an n-by-1 packed array.)
data_in = reshape(double(data_in), bits, [])';

mask = zeros(bits, 1);
for idx = 1:bits
    mask(idx) = 2^(idx - 1);
end

% Pack the bits via matrix multiplication.
data_out = data_in * mask;

% Convert double data back to the correct type.
switch (bits)
case 8
    data_out = uint8(data_out);
case 16
    data_out = uint16(data_out);
otherwise
    error(message('images:dicom_add_attr:badPackBits'))
end

end