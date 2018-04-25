function o = setIX( o, I )
%setIX  o = setIX( o, I )    low-level Mtree constructor

% Copyright 2006-2014 The MathWorks, Inc.

    if ~isa( I, 'logical' )
        o.IX = false( 1, o.n );
        o.IX(I) = true;
    else
        o.IX = I;
    end 
    o.m = sum( o.IX );
end
