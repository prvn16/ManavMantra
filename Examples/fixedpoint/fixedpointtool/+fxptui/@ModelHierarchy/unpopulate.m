function unpopulate(this, node)
% UNPOPULATE Remove parent-child connections and delete nodes.

% Copyright 2017 The MathWorks, Inc.

for i = 1:numel(node)
    parentNode = node(i);
    children = parentNode.getChildren;
    parentNode.disconnect;
    this.unpopulate(children);
    delete(parentNode);

end