function L = lineno( o )
%LINENO  L = lineno( obj )   Line numbers of the nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    L = linelookup( o, o.T( o.IX, 5 ) );  % vector of positions
end
