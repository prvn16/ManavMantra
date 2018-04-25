function o = or( o, o2 )
%OR  o = o1 | o2      | operation on trees

% Copyright 2006-2014 The MathWorks, Inc.

    o.IX = o.IX | o2.IX;
    o.m = sum( o.IX );
end
