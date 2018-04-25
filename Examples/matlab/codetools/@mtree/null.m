function oo = null( o )
%NULL  nobj = NULL( obj ) returns the empty Mtree object

% Copyright 2006-2014 The MathWorks, Inc.

    oo = o;
    oo.IX = false(1,o.n);
    oo.m = 0;
end
