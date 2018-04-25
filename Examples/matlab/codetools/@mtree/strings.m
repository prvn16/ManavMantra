function c = strings( o )
%STRINGS  c = STRINGS( obj ) return the strings for the Mtree obj

% Copyright 2006-2014 The MathWorks, Inc.

    c = cell( 1, o.m );
    SX = o.T( o.IX, 8 );  % string indices
    J = (SX==0);  % elements with no strings
    [c(J)] = {''};
    [c(~J)] = o.C(SX(~J));
end
