function o = Full( o )
%FULLSUBTREE  o = FULLSUBTREE( obj )  Return all the nodes reached
%   from nodes in obj using paths that do not include Parent

% Copyright 2006-2014 The MathWorks, Inc.

    I = find( o.IX );
    xx = false(1,o.n);
    for i=I
        xx(i:o.T(i,15)) = true;
    end
    o.m = nnz(xx);
    o.IX = xx;
end
