function o = select( o, ix )
%SELECT  o = SELECT( obj, ix )  Index into an Mtree object
%   o contains those nodes in obj whose indices are in ix
%   If ix contains an index for a node that is not in obj, and
%   error is thrown

% Copyright 2006-2014 The MathWorks, Inc.

    if ~all( o.IX(ix) )
        error(message('MATLAB:mtree:select'));
    end
    o.IX = false( 1, o.n );
    o.IX(ix) = true;
    o.m = sum( o.IX );
end
