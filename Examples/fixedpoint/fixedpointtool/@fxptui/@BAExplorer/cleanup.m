function cleanup(this)
%CLEANUP Cleans up the Batch Action Editor.

%   Copyright 2011 The MathWorks, Inc.

treeRoot = this.getRoot;
if ~isempty(treeRoot)
    unpopulate(treeRoot);
    this.MEListeners = [];
    delete(this);
end

% [EOF]
