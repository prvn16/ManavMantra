function oo = asgvars( o )
%ASGVARS  o = ASGVARS( obj )  Assigned variables.
%   Returns all nodes assigned to by EQUALS nodes in obj.  This 
%   includes nodes whose assignment is indexed.  It does not 
%   include FOR indices, function inputs, GLOBALs, or PERSISTENTs.

% Copyright 2006-2014 The MathWorks, Inc.

    x = Left( mtfind( o, 'Kind', 'EQUALS' ) );
    lbs = mtfind( x, 'Kind', 'LB' );
    x = mtfind( ((x-lbs)|List(Arg(lbs))) );
    oo = mtfind( x, 'Kind', 'ID' );
    x = x - oo;
    % must be DOT, DOTLP, SUBSCR, or CELL
    % empty args (~) just disappear from the List
    while ~isnull( x )
        x = mtpath( x, 'Left' );
        ooo = mtfind( x, 'Kind', 'ID' );
        oo = oo | ooo;
        x = x - ooo;
    end
end
