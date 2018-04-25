function code = invalidCode(codes)
% INVALIDCODE Return an invalid internal code, larger than all valid codes.

%   Copyright 2015 The MathWorks, Inc.

% The value returned is intmax(class(codes)), the largest integer value that can
% be stored in the given internal codes array. See the castCodes method.
if isa(codes,'uint8')
    code = uint8(255);
elseif isa(codes,'uint16')
    code = uint16(65535);
elseif isa(codes,'uint32')
    code = uint32(4294967295);
else % isa(codes,'uint64')
    code = uint64(18446744073709551615);
end
