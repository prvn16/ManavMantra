function y = castToBuiltinSuperclass(x)
% castToBuiltinSuperclass  Internal utility function to cast objects of 
% a subclass of a builtin type to their builtin superclass.

%   Copyright 1984-2014 The MathWorks, Inc.
    
if isobject(x)
    if isa(x, 'double')
        y = double(x);
    elseif isa(x, 'single')
        y = single(x);
    elseif isa(x, 'uint8')
        y = uint8(x);
    elseif isa(x, 'int8')
        y = int8(x);
    elseif isa(x, 'uint16')
        y = uint16(x);
    elseif isa(x, 'int16')
        y = int16(x);
    elseif isa(x, 'uint32')
        y = uint32(x);
    elseif isa(x, 'int32')
        y = int32(x);
    elseif isa(x, 'uint64')
        y = uint64(x);
    elseif isa(x, 'int64')
        y = int64(x);
    elseif isa(x, 'logical')
        y = logical(x);
    else
        error(message('MATLAB:castToBuiltinSuperclass:UnsupportedType'));
    end
else
    y = x;
end