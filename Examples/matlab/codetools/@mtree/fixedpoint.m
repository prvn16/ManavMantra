function o = fixedpoint( o, fh )
%FIXEDPOINT  obj = FIXEDPOINT( obj, fh )  Grow obj applying fh
%   FIXEDPOINT applies the function fh to the set obj, and adds
%   the result to obj.  It continues this until the set no longer
%   grows.

% Copyright 2006-2014 The MathWorks, Inc.

    nn = count(o);
    while true
        o = o | fh(o);
        mm = count(o);
        if mm==nn
            return;
        end
        nn = mm;
    end
end
