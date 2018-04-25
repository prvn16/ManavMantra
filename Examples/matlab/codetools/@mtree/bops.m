function o = bops( o )
%BOPS  o = BOPS( obj )  Returns the binary operator nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    o.IX(o.IX) = o.Bop( o.T(o.IX,1) );
    o.m = sum( o.IX );
end
