function t = ispropequal(A,B)
%ISPROPEQUAL True if all properties are equal
%   ISPROPEQUAL(A,B) returns 1 if all of the properties and values of A
%   and B are equal.
%
%   See also EMBEDDED.FI/ISEQUAL

%   Thomas A. Bryan, 15 January 2004
%   Copyright 1999-2015 The MathWorks, Inc.

narginchk(2,2);
t = false;
if isnumerictype(A) && isnumerictype(B)
    t = isequal(struct(A),struct(B));
end
