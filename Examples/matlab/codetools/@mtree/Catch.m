function o = Catch(o)
%Catch  o = Catch(obj)   the Catch blocks for TRY nodes in obj

% Copyright 2006-2014 The MathWorks, Inc.

    % fast for single nodes...
    lix = o.Linkno.Catch;
    J = o.T( o.IX, 3 );
    KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
    J = J(KKK);
    J = o.T( J, 3 );  % apply 'Right' again
    J = J(J~=0);
    o.IX(o.IX) = false;   % reset
    o.IX(J)= true;
    o.m = length(J);
end
