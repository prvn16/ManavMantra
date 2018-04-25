function oo = geteq( o )
%GETEQ  o = GETEQ( obj )   Get EQUALS node.
%   Returns the EQUALS node, if any, that assigns to variables or 
%   expressions in obj.

% Copyright 2006-2014 The MathWorks, Inc.

    oo = null( o );
    while ~isnull( o )
        p = mtfind( Parent(o), 'Kind', 'EQUALS' );
        %o1 = mtfind( o, 'Parent.Kind', 'EQUALS' );
        %o1 = o1 & mtpath( o1, 'Parent.Left' );  % o1 are left children
        o1 = o & Left(p);
        oo = oo | Parent( o1 ); % all EQUALS nodes
        o = o - o1;
        o = Parent(o);
        % if we get to EXPR or PRINT or FOR, too far!
        % this should just be for efficiency
        o = o - mtfind( o, 'Kind', { 'EXPR', 'PRINT', 'FOR' } );
    end
end
