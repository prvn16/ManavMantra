function b = ismember( o, a )
%ISMEMBER  b = ISMEMBER( obj, o ) true if node in obj is in o

% Copyright 2006-2014 The MathWorks, Inc.

    b = a.IX( o.IX );
end
