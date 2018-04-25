function out = swapbytes(in)
%SWAPBYTES Swap byte ordering, changing endianness.
%    Y = SWAPBYTES(X) reverses the byte ordering of the matrix X,
%    converting little-endian values to big-endian (and vice versa).
%
%    Example:
%
%       X = uint16([0 1 128 65535]);
%       Y = swapbytes(X);
%
%    Y will have the following uint16 values:
%
%       [0    256  32768  65535]
%
%    Examining the output in hex notation shows the byte swapping:
%
%       format hex
%       X, Y
%       format
%    
%    See also TYPECAST.

%   Copyright 1984-2005 The MathWorks, Inc.

narginchk(1,1)

% No need to swap arrays with byte-sized elements.
if ( (isa(in, 'uint8')) || (isa(in, 'int8')) )
    
    out = in;
    return
    
elseif (isempty(in))
  
    out = in;
    return
     
end

% Typecast the input into bytes, reshaping it into a bytes-by-numel_in
% array.
out = reshape(typecast(in(:), 'uint8'), ...
              getBytesPerElement(in(1)), []);

% Flip the array, reshape to a vector, and convert back to the input
% type.
out = flipud(out);
out = typecast(out(:), class(in));

% Reshape the array to match the input type.
out = reshape(out, size(in));



function numbytes = getBytesPerElement(value)

switch (class(value))
case {'uint16', 'int16'}
  numbytes = 2;
  
case {'uint32', 'int32', 'single'}
  numbytes = 4;
  
case {'uint64', 'int64', 'double'}
  numbytes = 8;
  
otherwise
  error(message('MATLAB:swapbytes:InvalidType'));
end
