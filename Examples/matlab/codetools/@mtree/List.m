function o = List( o )
%LIST  o = List(obj)   Return the nodes that follow (with Next)
%      some node in obj

% Copyright 2006-2014 The MathWorks, Inc.

    % it appears that a loop is the best way to do this...
    IXX = o.IX;
    for i=find(IXX)
        % follow next path
        j = o.T(i,4);
        while( j && ~IXX(j) )
            IXX(j) = true;
            j = o.T(j,4);
        end
    end
    o.IX = IXX;
    o.m = sum(IXX);
end
