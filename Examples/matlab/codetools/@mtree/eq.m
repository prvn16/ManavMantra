function b = eq( o, oo )
%EQ  Mtree == operator

% Copyright 2006-2014 The MathWorks, Inc.

    b = sametree(o,oo) && o.n == oo.n && o.m==oo.m && ...
            all( o.IX==oo.IX );
end
