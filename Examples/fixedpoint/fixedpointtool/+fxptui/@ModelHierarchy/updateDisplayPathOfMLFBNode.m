function updateDisplayPathOfMLFBNode(this, node)
% UPDATEDISPLAYPATHOFMLFBNODE Updates the display path of the MATLAB function node after the variant
% creation

% Copyright 2017 The MathWorks, Inc.

% DisplayPath is how we trip the display names of results in the
% spreadsheet. An incorrect display path means, the name of the results
% will not be trimmed correctly based on the node selected.

displayPath = {node.DisplayPath};
idx = regexp(node.DisplayPath, ['/' node.Name '$']);
if ~isempty(idx)
    stableSubPath = node.DisplayPath(idx:end);
    newPath = [node.Object.BlockIdentifier.getObject.getFullName, stableSubPath];
    node.DisplayPath = [displayPath, {newPath}];
end
childNodes = node.getChildren;
for i = 1:numel(childNodes)
    this.updateDisplayPathOfMLFBNode(childNodes(i));
end