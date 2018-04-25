function a = kinds( o )
%KINDS  a = KINDS( obj )   Return a cell array of Kind names

% Copyright 2006-2014 The MathWorks, Inc.

    a = o.KK( o.T( o.IX, 1 ));
end
