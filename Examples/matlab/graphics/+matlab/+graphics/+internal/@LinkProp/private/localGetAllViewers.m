% Local functions called from processRemoveHandle()
%
function viewers = localGetAllViewers(hlist)

%   Copyright 2014-2015 The MathWorks, Inc.

viewers = {  };
for m = 1:length( hlist )
    viewer_axes = ancestor( hlist( m ), 'axes' );
    if ~isempty( viewer_axes )
        viewer = get( viewer_axes, 'Parent' );
        if isempty( viewer )
            % if one of the objects doesn't have a viewer we say none do
            viewers = {  };
            return
        end
        if isempty( viewers ) || ~any( cellfun( @(a) isequal( viewer, a ), viewers ) )
            viewers{ end + 1 } = viewer;  %#ok<AGROW>
        end
    end
end

end
