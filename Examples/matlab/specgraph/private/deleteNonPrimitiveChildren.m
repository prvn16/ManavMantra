function deleteNonPrimitiveChildren(hObj, hToKeep)
% Delete any children of the object that are composite objects.

%   Copyright 2010-2011 The MathWorks, Inc.

if nargin<2
    hToKeep = [];
end

% Currently, any child with a "Type" property is a composite object, except
% those that have been marked "internal".  This exception stops us from
% deleting primitive text objects.
hChil = findobjinternal(hObj,'-property','Type', 'Internal', false);
hChil = hChil(hChil ~= hObj);
hChil = setdiff(hChil, hToKeep);

% Look for context menus that will be left without any users.
uic = get(hChil, {'UIContextMenu'});
set(hChil, 'UIContextMenu', []);

isValid = cellfun(@(m) ~isempty(m) && ishghandle(m), uic);
uic = uic(isValid);
uic = [uic{:}];
uic = unique(uic);
for n=1:numel(uic)
    % Search the context menu's parent and all children for other users
    uicUsers = findall(get(uic(n), 'Parent'), 'UIContextMenu', uic(n));
    if isempty(uicUsers)
        delete(uic(n));
    end
end

delete(hChil);
