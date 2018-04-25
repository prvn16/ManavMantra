function b = allmember( o, a )
%ALLMEMBER  b = ALLMEMBER( obj, S ) are all nodes in obj also in o

% Copyright 2006-2014 The MathWorks, Inc.

    b = all( ismember( o, a ) );
end
