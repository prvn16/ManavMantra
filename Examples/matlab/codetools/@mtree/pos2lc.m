function [l,c] = pos2lc( o, pos )
%POS2LC  [L,C] = POS2LC( obj, pos )   convert position to line/char

% Copyright 2006-2014 The MathWorks, Inc.

    l = reshape( linelookup( o, pos ), size(pos) );
    c = pos - reshape( o.lnos( l ), size(pos) );
end
