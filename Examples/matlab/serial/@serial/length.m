function out = length(obj)
%LENGTH Length of serial port object array.
%
%   LENGTH(OBJ) returns the length of serial port object array,
%   OBJ. It is equivalent to MAX(SIZE(OBJ)).
%
%   See also SERIAL/SIZE.
%

%   Copyright 1999-2013 The MathWorks, Inc.


% The jobject property of the object indicates the number of
% objects that are concatenated together.

out = builtin('length', obj.jobject);




