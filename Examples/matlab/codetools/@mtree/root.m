function oo = root( o )
%ROOT  r = ROOT( obj ) returns the root of the Mtree obj

% Copyright 2006-2014 The MathWorks, Inc.

    oo = o;
    oo.IX = [ true false(1,o.n-1) ];
    oo.m = 1;
end
