function o = stmts( o )
%STMTS  o = STMTS( obj )  Returns the statement nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    J = find( o.IX );
    o.IX(J) = o.Stmt( o.T(J,1) );
    o.m = sum( o.IX );
end
