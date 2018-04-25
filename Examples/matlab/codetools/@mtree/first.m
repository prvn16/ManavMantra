function oo = first( o )
%FIRST  o = FIRST( obj )   The first node in an Mtree List

% Copyright 2006-2014 The MathWorks, Inc.

    o1 = X(P(o));
    o2 = P( o & o1 );  % previous nodes
    oo = o - o1;  % nodes already at head of List
    while ~isnull( o2 )
        o1 = X(P(o2));
        o3 = P( o2 & o1 );
        oo = oo | (o2 - o1);
        o2 = o3;
    end
end
