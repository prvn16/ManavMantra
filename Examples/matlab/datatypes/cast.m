%CAST  Cast a variable to a different data type or class.
%   B = CAST(A,NEWCLASS) casts A to class NEWCLASS. A must be convertible to
%   class NEWCLASS.
%
%   B = CAST(A,'like',Y) converts A to the same data type and sparsity as the 
%   variable Y. If A and Y are both real, then B is also real. B is complex
%   otherwise.
%
%   Example:
%      a = int8(5);
%      b = cast(a,'uint8');
%
%   See also CLASS.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.
