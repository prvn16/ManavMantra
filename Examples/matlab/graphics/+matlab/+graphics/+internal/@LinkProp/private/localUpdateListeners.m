% Local functions called from processRemoveHandle()
%
function localUpdateListeners(hLink,synchronizeprops)

%   Copyright 2014-2015 The MathWorks, Inc.

if nargin==1
    synchronizeprops = true;
end
% dereference old listeners
localDeleteListeners( get( hLink, 'Listeners' ) );
set( hLink, 'Listeners', {  } )
set( hLink, 'HasPostUpdateListeners', 'off' );
% Get properties and handles
propnames = get( hLink, 'PropertyNames' );
N = length( propnames );
set( hLink, 'SharedValues', cell( 1, N ) );
hlist = get( hLink, 'Targets' );
M = length( hlist );
listeners = {  };
deleteListeners = cell( 1, M );
valid = false( M, N );
props = cell( 1, N );
% Cycle through list of objects
% Create listeners for each input object
for m = 1:M
    if isobject( hlist( m ) )
        eventListenerConstructor = @event.listener;
        propListenerConstructor = @event.proplistener;
        propEvent = 'PostSet';
    else
        eventListenerConstructor = @handle.listener;
        propListenerConstructor = @handle.listener;
        propEvent = 'PropertyPostSet';
    end
    if (~isobject( hlist( m ) ) && ishandle( hlist( m ) )) || (isobject( hlist( m ) ) && isvalid( hlist( m ) ))
        % Listen to deletion
        deleteListeners{ m } = eventListenerConstructor( hlist( m ), 'ObjectBeingDestroyed', @hLink.processRemoveHandle );
        % Get list of property objects for listening
        setobservable = true;
        for n = 1:N
            props{ n } = findprop( hlist( m ), propnames{ n } );
            if isempty( props{ n } )
                warning( message( 'MATLAB:linkprop:InvalidProperty' ) );
            else
                valid( m, n ) = true;
                if strcmp( propEvent, 'PostSet' ) && ~props{ n }.SetObservable
                    setobservable = false;
                end
            end
        end  % for
        if any( valid( m, : ) ) && setobservable
            % Create one handle listener per object
            listeners{ end + 1 } = propListenerConstructor( hlist( m ), [ props{ : } ], propEvent, @hLink.processUpdate );  %#ok<AGROW>
            localSetEnableState( listeners{ end }, 'off' );
        end
        if strcmp( propEvent, 'PostSet' ) && strcmp( hLink.LinkAutoChanges, 'on' )
            mclass = metaclass( hlist( m ) );
            eventNames = { mclass.EventList.Name };
            if any( strcmp( 'MarkedClean', eventNames ) )
                hUpdate = eventListenerConstructor( hlist( m ), 'MarkedClean', @hLink.processMarkedClean );
                listeners{ end + 1 } = hUpdate;  %#ok<AGROW>
            elseif any( strcmp( 'Reset', eventNames ) )
                hReset = eventListenerConstructor( hlist( m ), 'Reset', @hLink.processReset );
                listeners{ end + 1 } = hReset;  %#ok<AGROW>
            end
        end
    end  % if
end  % for
set( hLink, 'ValidProperties', valid );
% If we have delete listeners
deleteListeners = [ deleteListeners{ : } ];
set( hLink, 'TargetDeletionListeners', deleteListeners );
% Bail out early if we have no listeners
if ~any( any( valid ) )
    return
end
set( hLink, 'Listeners', listeners );
localSetAllEnableState( listeners, 'off' );
if synchronizeprops
    localForeachProp( hLink, hlist, @(hlist,prop,ind,n) localSync( hlist, prop, ind, n, hLink ) )
end
localSetAllEnableState( listeners, get( hLink, 'Enabled' ) );

end
