function o = not( o )
%MOT  o = ~o        ~ operation on trees

% Copyright 2006-2014 The MathWorks, Inc.

    o.IX = ~o.IX;
    o.m = sum( o.IX );
end
