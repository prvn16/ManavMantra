function o = minus( o, o2 )
%MINUS  o = o1 - o2     set difference operation on trees

% Copyright 2006-2014 The MathWorks, Inc.

    o.IX = o.IX & (~o2.IX);
    o.m = sum( o.IX );
end
