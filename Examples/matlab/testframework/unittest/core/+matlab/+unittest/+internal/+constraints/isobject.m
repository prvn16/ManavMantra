function bool = isobject(value)

% Copyright 2016 The MathWorks, Inc.

bool = ...
    builtin('isobject',value) || ...
    isJavaObject(value) || ...
    isa(value, 'function_handle') || ...
    isa(value, 'handle.handle');
end

function bool = isJavaObject(value)
bool = usejava('jvm') && isjava(value);
end

