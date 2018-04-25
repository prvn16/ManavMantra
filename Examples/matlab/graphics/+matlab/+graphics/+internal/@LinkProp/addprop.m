function addprop(hLink,prop)
%   Copyright 2014 The MathWorks, Inc.

%ADDPROP Add property for linking
if ~ischar( prop )
    error( message( 'MATLAB:linkprop:StringRequired' ) );
end
propnames = get( hLink, 'PropertyNames' );
if ~isempty( propnames ) && iscellstr( propnames )
    % Only update if not already in list
    if ~any( strcmp( propnames, prop ) )
        % Add new property
        set( hLink, 'PropertyNames', [ propnames, { prop } ] );
    end
else
    set( hLink, 'PropertyNames', { prop } );
end
% Update listeners, call to pseudo-private method
feval( get( hLink, 'UpdateFcn' ), hLink );
end
