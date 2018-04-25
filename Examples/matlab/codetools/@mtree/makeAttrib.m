function oo = makeAttrib( o, I )
%makeAttrib oo = makeAttrib( o, I )  Mtree internal utility fcn

% Copyright 2006-2014 The MathWorks, Inc.

% makes a set of nodes from a logical vector
    oo = o;
    if ~isa( I, 'logical' )
        oo.IX = false( 1, o.n );
        oo.IX(I) = true;
    else
        oo.IX = I;
        %{
        if o.n ~= length(I)
            error( 'MATLAB:mtree:internal1','bad makeAttrib size' );
        end
        %}
    end
    oo.m = sum(oo.IX);
end
