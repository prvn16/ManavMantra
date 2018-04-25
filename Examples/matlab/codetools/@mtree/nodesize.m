function n = nodesize( o )
%NODESIZE  n = NODESIZE(obj)  Returns the sizes of nodes in obj
%   n will be an empty array if obj is null

% Copyright 2006-2014 The MathWorks, Inc.

     n  = o.T(o.IX,6);
end
