% Local functions called from processRemoveHandle()
%
function prop = insensitivefindprop(obj,propname)

%   Copyright 2014-2015 The MathWorks, Inc.

prop = findprop( obj, propname );
if ~isempty( prop )
    return
end
props = properties( obj );
n = length( propname );
exactn = cellfun( @(x) length( x )==n, props );
exactProps = props( exactn );
ind = find( strcmpi( propname, exactProps ) );
if isscalar( ind )
    prop = findprop( obj, exactProps{ ind } );
    return
end
tooshort = cellfun( @(x) length( x )<=n, props );
props( tooshort ) = [  ];
ind = find( strncmpi( propname, props, n ) );
if isscalar( ind )
    prop = findprop( obj, props{ ind } );
end

end
