% Local functions called from processRemoveHandle()
%
function propnames = normalizePropertyNames(hlist,propnames)

%   Copyright 2014-2015 The MathWorks, Inc.

N = length( propnames );
M = length( hlist );
props = cell( 1, N );
for m = 1:M
    for n = 1:N
        props{ n } = insensitivefindprop( hlist( m ), propnames{ n } );
    end
end
for n = 1:N
    if ~isempty( props{ n } )
        propnames{ n } = props{ n }.Name;
    end
end

end
