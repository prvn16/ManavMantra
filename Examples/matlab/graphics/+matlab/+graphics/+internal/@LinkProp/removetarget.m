function removetarget(hLink,h)
%   Copyright 2014 The MathWorks, Inc.

%REMOVETARGET Remove handle for linking
if ~isobject( h ) && ~ishandle( h )
    return
end
h = handle( h );
t = get( hLink, 'Targets' );
% only update if in list
ind = find( t==h );
% remove element
if ~isempty( ind )
    t( ind ) = [  ];
    set( hLink, 'Targets', t );
    % Update listeners, call to pseudo-private method
    feval( get( hLink, 'UpdateFcn' ), hLink, false );
end
end
