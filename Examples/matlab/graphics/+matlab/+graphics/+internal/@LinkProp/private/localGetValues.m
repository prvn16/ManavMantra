% Local functions called from processRemoveHandle()
%
function localGetValues(updatedObjs,prop,ind,hlist,n,hLink)

%   Copyright 2014-2015 The MathWorks, Inc.

values = get( hLink, 'SharedValues' );
objs = hlist( ind );
matches = cellfun( @(a) any( objs==a ), updatedObjs );
if any( matches )
    matchInd = find( matches );
    for k = 1:length( matchInd )
        obj = updatedObjs{ matchInd( k ) };
        val = get( obj, prop );
        if ~isequal( val, values{ n } )
            break
        end
    end
    values{ n } = val;
end
set( hLink, 'SharedValues', values );

end
