function c = getClass(arg)
%getClass getClass of tall or non-tall array
%   C = getClass(T) returns in C either the known class or ''.

% Copyright 2016 The MathWorks, Inc.

if istall(arg)
    a = hGetAdaptor(arg);
    c = a.Class;
else
    c = class(arg);
end
end
