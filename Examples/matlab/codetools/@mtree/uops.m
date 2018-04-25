function o = uops( o )
%UOPS  o = UOPS( obj )  Returns the unary operator nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    J = find( o.IX );
    o.IX(J) = o.Uop( o.T(J,1) );
    o.m = sum( o.IX );
end
