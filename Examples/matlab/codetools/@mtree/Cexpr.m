function o = Cexpr(o)
%Cexpr  o = Cexpr(obj)   class expression for CLASSDEFS in obj
%   The class expression contains the class name and superclass
%   names as well

% Copyright 2006-2014 The MathWorks, Inc.

    % fast for single nodes...
    lix = o.Linkno.Cexpr;
    J = o.T( o.IX, 2 );
    KKK = o.Linkok( lix, o.T( o.IX, 1 ) ) & (J~=0)';
    J = J(KKK);
    J = o.T( J, 3 );  % apply 'Right' again
    J = J(J~=0);
    o.IX(o.IX) = false;   % reset
    o.IX(J)= true;
    o.m = length(J);
end
