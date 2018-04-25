function P = position( o )
%POSITION  P = POSITION( obj )   String indices of nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    P = o.T( o.IX, 5 );
end
