function str = tostring(a)
%TOSTRING Convert fi object to string
%   S = TOSTRING(A) converts fi object A to a string S such that
%   EVAL(S) would create a fi object with the same properties as A.
%
%   Example:
%     a = fi(pi)
%     s = tostring(a)
%     b = eval(s)
%
%   See also FI, MAT2STR.

%   Copyright 2015 The MathWorks, Inc.

    str = mat2str(a,'class');

end