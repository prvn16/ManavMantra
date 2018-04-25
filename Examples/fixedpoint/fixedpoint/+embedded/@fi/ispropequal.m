function t = ispropequal(A,B)
%ISPROPEQUAL True if all properties are equal
%   ISPROPEQUAL(A,B) returns 1 if all of the properties and values of A
%   and B are equal.
%
%   See also EMBEDDED.FI/ISEQUAL

%   Copyright 1999-2015 The MathWorks, Inc.

narginchk(2,2);
if isfi(A) && isfi(B) && isfimathlocal(A) && isfimathlocal(B)
    t = isfi(A) && isfi(B) && ...
        ispropequal(numerictype(A),numerictype(B)) && ...
        isequal(fimath(A),fimath(B)) && isequal(A.intarray, B.intarray);
else
    t = isfi(A) && isfi(B) && ispropequal(numerictype(A),numerictype(B)) && ...
        isequal(A.intarray, B.intarray);
end
