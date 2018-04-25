% Local functions called from processRemoveHandle()
%
function localSync(hlist,prop,ind,n,hLink)

%   Copyright 2014-2015 The MathWorks, Inc.

values = get( hLink, 'SharedValues' );
val = get( hlist( ind( 1 ) ), prop );
% filter out values which are equal to new value
list1 = hlist( ind );
doSet = true( 1, length( list1 ) );
doSet( 1 ) = false;
for k = 2:length( list1 )
    if isequal( { val }, { get( list1( k ), prop ) } )
        doSet( k ) = false;
    end
end
list1 = list1( doSet );
set( list1, prop, val );
set( hlist( ind ), prop, val );
values{ n } = val;
set( hLink, 'SharedValues', values );

end
