function oo = rawset( o )
% RAWSET  oo = rawset(o)  the real nodes that set o (no JOINS)

% Copyright 2006-2014 The MathWorks, Inc.

    J = o.T( o.IX, 10 );  % setting nodes
    J = J(J~=0 & (J<=o.n));
    oo = makeAttrib( o, J );
end
