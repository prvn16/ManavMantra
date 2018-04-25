function b = isNodeSupported(h)
%ISNODESUPPORTED returns true if actions can be performed on this class of node. 

%   Copyright 2011 The MathWorks, Inc.

b = true;
try
    get_param(h.daobject.ModelName, 'Object');
catch e %model can be closed already, then no action can be performed
    b = false;
end
