function hObj = getObjectFromCopyStructure(s)
% This function is undocumented and will be changed in a future release.

% Copyright 2009-2013 The MathWorks, Inc.

% Returns a structure containing data to be used by scribe cut/copy/paste.

% For each structure, deserialize it appropriately:
for i=numel(s):-1:1
    hObj(i) = getArrayFromByteStream(s(i).ObjData);
    
    if ~isempty(s(i).UIContextMenuData)
        % Make sure to include the context menu (ColorBar & Legend will
        % setup their own context menu, and don't need it included here)
        if ~ishghandle(hObj(i), 'colorbar') && ...
                ~ishghandle(hObj(i), 'legend')
            set(hObj(i), 'UIContextMenu', ...
                getArrayFromByteStream(s(i).UIContextMenuData));
        end
    end
end