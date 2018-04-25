function ooo = dominates( oo, o )
%DOMINATES  oo = DOMINATES( obj, o )   Return nodes that dominate
%   Returns nodes in obj that can reach some node in o by a path
%   that does not involve Parent

% Copyright 2006-2014 The MathWorks, Inc.

    ooo = null(oo);
    while ~isnull( o )
        ooo = ooo | (o & oo);
        o = Parent(o);
    end
end
