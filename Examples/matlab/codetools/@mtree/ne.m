function b = ne( o, oo )
%NE  Mtree ~= operator

% Copyright 2006-2014 The MathWorks, Inc.

    b = ~sametree(o,oo) || o.m~=oo.m || o.n ~= oo.n || ...
            any( o.IX~=oo.IX );
end
