function addtarget(hLink,h)
%   Copyright 2014 The MathWorks, Inc.

%ADDTARGET Add handle for linking
if isobject( h )
    if ~isvalid( h )
        error( message( 'MATLAB:linkprop:InvalidHandle' ) );
    end
else
    if ~ishandle( h )
        error( message( 'MATLAB:linkprop:InvalidHandle' ) );
    end
end
h = handle( h );
t = get( hLink, 'Targets' );
% only update if not already in list
if ~any( t==h )
    set( hLink, 'Targets', [ t, h ] );
    % Update listeners, call to pseudo-private method
    feval( get( hLink, 'UpdateFcn' ), hLink );
end
end
