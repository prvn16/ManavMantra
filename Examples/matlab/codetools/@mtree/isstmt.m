function b = isstmt( o )
%ISSTMT  b = ISSTMT( obj )   True of node heads a statement

% Copyright 2006-2014 The MathWorks, Inc.

    b = o.Stmt( o.T(o.IX,1) );
end
