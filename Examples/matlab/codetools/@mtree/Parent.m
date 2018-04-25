function o = Parent(o)
%Parent  o = Parent(obj)  returns the parents of nodes in Mtree obj

% Copyright 2006-2014 The MathWorks, Inc.

    % fast for single nodes...
    lix = o.Linkno.Parent;
    J = o.T( o.IX, 9 );
    KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
    J = J(KKK);
    o.IX(o.IX) = false;   % reset
    o.IX(J)= true;
    % the standard drill gets o.m wrong, since two nodes in o
    % may have the same parent (e.g., J may have duplicate entries)
    o.m = nnz(o.IX);
end
