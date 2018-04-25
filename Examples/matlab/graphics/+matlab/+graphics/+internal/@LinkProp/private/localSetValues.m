% Local functions called from processRemoveHandle()
%
function localSetValues(~,prop,ind,hlist,n,hLink)

%   Copyright 2014-2015 The MathWorks, Inc.

values = get( hLink, 'SharedValues' );
hListeners = get( hLink, 'Listeners' );
localSetAllEnableState( hListeners, 'off' );
objs = hlist( ind );
changeVal = values{ n };
changeObjs = [  ];
for k = 1:length( objs )
    obj = objs( k );
    val = get( obj, prop );
    if ~isequal( val, changeVal )
        if isempty( changeObjs )
            changeObjs = obj;
        else
            changeObjs = [ changeObjs, obj ];
        end
    end
end
set( changeObjs, prop, changeVal );
localSetAllEnableState( hListeners, 'on' );

end
