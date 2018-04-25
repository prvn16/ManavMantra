function b = anymember( o, a )
%ANYMEMBER  b = ANYMEMBER( obj, o ) is any node in obj also in o

% Copyright 2006-2014 The MathWorks, Inc.

    b = any( ismember( o, a ) );
end
