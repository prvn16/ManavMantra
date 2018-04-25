function scopingIds = getScopingIds(this, treeId)
% Get the scoping Ids corresponding to a tree ID

% Copyright 2017 The MathWorks, Inc.

scopingIds = [];
if this.ResultScopingMap.isKey(treeId)
    scopingIds = unique(this.ResultScopingMap(treeId));
end