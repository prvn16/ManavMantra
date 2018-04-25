function o = Tree( o )
%TREE  o = TREE( obj )  Return all nodes reached from nodes  
%    in obj by paths that do not include Parent or start with Next

% Copyright 2006-2014 The MathWorks, Inc.

    I = find( o.IX );
    xx = false(1,o.n);
    for i=I
        xx(i:o.T(i,14)) = true;
    end
    o.m = nnz(xx);
    o.IX = xx;
end
