function EP = endposition( o )
%ENDPOSITION  EP = ENDPOSITION( obj )  The close of nodes in obj
%   NOTE: this gives the position of the matching parenthesis,
%   or bracket or END of the node(s) in obj

% Copyright 2006-2014 The MathWorks, Inc.

    EP = o.T( o.IX, 5 ) + o.T( o.IX, 6 ) - 1;
end
