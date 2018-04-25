function o = lhs( o ) % find the LHS of EQUALS nodes
%LHS  o = LHS( obj )   The first assigned value of an EQUALS node
%   This function looks below [ ] if present to find the first
%   value that is assigned to by an EQUALS node.

% Copyright 2006-2014 The MathWorks, Inc.

    oo = Left( mtfind( o, 'Kind', 'EQUALS' ) );
    ooo = mtfind( oo, 'Kind', 'LB' );
    o = (oo-ooo) | List(Arg(ooo));  % apply List to get multiple LHS
end
