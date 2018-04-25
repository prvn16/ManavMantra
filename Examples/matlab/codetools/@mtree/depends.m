function oo = depends( o )
%DEPENDS  o = DEPENDS( obj )  Returns nodes that obj depends on

% Copyright 2006-2014 The MathWorks, Inc.

    e = geteq( o );
    % lhs = mtpath( e, 'Left+' );   % expressions assigned to
    oo = mtpath( e, 'Right' );   % contents of RHS
    % oo = oo | dominates( lhs, o );
    % add argument to call
    oo = oo | mtpath( mtfind( o, 'Kind', 'CALL' ), 'Right+' );
    % add operands of operators
    oo = oo | operands( o );
end
