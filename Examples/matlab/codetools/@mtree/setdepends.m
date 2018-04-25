function o = setdepends( o )
%SETDEPENDS  o = SETDEPENDS( obj )  Nodes obj depends on or set by

% Copyright 2006-2014 The MathWorks, Inc.

    o = o|sets( o );
    o = o|depends( o );
end
