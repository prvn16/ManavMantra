function oo = allsetter( o, o2 )
%ALLSETTER oo = allsetter( obj, o2 )  Deprecated Mtree method

% Copyright 2006-2014 The MathWorks, Inc.

    X = false( 1, o.n );
    for i=indices(o)
        x = select( o, i );
        y = sets(x);
        if count(o2&y) < count(y)
            continue;  % this one is not in
        end
        % now, check for assignment to x
        % TODO: is the above comment incorrect?
        % is ALLSETTER used?  Or necessary?
        y = setter( x );
        if isnull( y&o2 )
            continue;  % this one is not in
        end
        X(i) = true;
    end
    oo = o;
    oo = makeAttrib( oo, X );
end
