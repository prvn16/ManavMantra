function b = le( o, oo )
%LE  Mtree <= operator (returns true if first argument is a subset
%    of the second)

% Copyright 2006-2014 The MathWorks, Inc.

    b = sametree(o,oo) && all( ~o.IX | oo.IX );
end
