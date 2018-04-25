function o = wholetree( o )
%WHOLETREE  o = WHOLETREE(o) the whole tree from a subset of nodes
% return the full tree (without JOIN nodes)

% Copyright 2006-2014 The MathWorks, Inc.

    nt = size( o.T, 1 );
    if nt==0
        i = 0;
    else
        % empty range in MATLAB sets i to []
        targetNodeKind = o.K.JOIN;
        for i=nt:-1:1
            if o.T(i,1) ~= targetNodeKind
                break;
            end
        end
    end
    o.n = i;
    o.m = o.n;
    o.IX = true( 1, o.n );
end
