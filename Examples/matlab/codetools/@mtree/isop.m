function b = isop( o )
%ISOP  b = ISOP( obj )   Boolean array, true if node is an operator

% Copyright 2006-2014 The MathWorks, Inc.

    b = isbop(o) | isuop(o);
end
