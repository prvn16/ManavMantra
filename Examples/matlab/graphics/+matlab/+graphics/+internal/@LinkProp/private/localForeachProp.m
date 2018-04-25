% Local functions called from processRemoveHandle()
%
function localForeachProp(hLink,hlist,callback)

%   Copyright 2014-2015 The MathWorks, Inc.

propnames = get( hLink, 'PropertyNames' );
valid = get( hLink, 'ValidProperties' );
for n = 1:length( propnames )
    prop = propnames{ n };
    ind = find( valid( :, n ) );
    if length( ind )>1
        callback( hlist, prop, ind, n );
    end
end

end
