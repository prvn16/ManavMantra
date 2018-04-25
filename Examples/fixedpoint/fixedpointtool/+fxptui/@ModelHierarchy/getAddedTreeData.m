function treeStruct = getAddedTreeData(this)

%   Copyright 2017 The MathWorks, Inc.

treeStruct = [];
for i = 1:numel(this.AddedTree)
    treeStruct = [treeStruct this.AddedTree(i).convertToStruct];
end