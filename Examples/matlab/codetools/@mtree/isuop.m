function b = isuop( o )
%ISUOP  b = ISUOP( obj )   Boolean array, true if node is unary

% Copyright 2006-2014 The MathWorks, Inc.

    b = o.Uop( o.T(o.IX,1) );
end
