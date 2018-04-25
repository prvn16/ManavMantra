function oo = anysetter( o, o2 )
%ANYSETTER  oo = anysetter( obj, o2 )  Deprecated Mtree method

% Copyright 2006-2014 The MathWorks, Inc.

    X = false( 1, o.n );
    for i=indices(o)
        x = select( o, i );
        y = sets(x);
        if ~isnull(o2&y)
            X(i) = true;
            continue;  % this one is in
        end
        % now, check for assignment to x
        % TODO: is the above comment incorrect?
        % is ANYSETTER used?  Or necessary?
        y = setter( x );
        if ~isnull( y&o2 )
            X(i) = true;
            continue;  % this one is in
        end
    end
    oo = o;
    oo = makeAttrib( oo, X );
end
