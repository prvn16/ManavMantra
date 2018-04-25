function processUpdate(hLink,hProp,hEvent)
%   Copyright 2014 The MathWorks, Inc.

hlist = hLink.Targets;
% Return early if invalid property object
if ~isa( hProp, 'schema.prop' ) && ~isa( hProp, 'meta.property' )
    return
end
% Return early if invalid handle
if all( isobject( hlist ) )
    if ~all( isvalid( hlist ) )
        return
    end
else
    if ~all( ishandle( hlist ) )
        return
    end
end
valid = get( hLink, 'ValidProperties' );
values = get( hLink, 'SharedValues' );
% Temporarily turn off listeners to avoid excessive
% listener firing
hListeners = get( hLink, 'Listeners' );
localSetAllEnableState( hListeners, 'off' );
propname = hProp.Name;
propval = hEvent.AffectedObject.(propname);
% Update all linked objects that have this property
n = find( strcmpi( propname, get( hLink, 'PropertyNames' ) ), 1 );
ind = valid( :, n );
set( hlist( ind ), propname, propval );
values{ n } = propval;
set( hLink, 'SharedValues', values );
% Restore listeners
for k = 1:length( hListeners )
    hListeners{ k }.Enabled = true;
end
%localSetAllEnableState(hListeners,'on');
end
