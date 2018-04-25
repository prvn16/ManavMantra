function b = isbop( o )
%ISBOP  b = ISBOP( obj )   Boolean array, true if node is binary

% Copyright 2006-2014 The MathWorks, Inc.

    b = o.Bop( o.T(o.IX,1) );
end
