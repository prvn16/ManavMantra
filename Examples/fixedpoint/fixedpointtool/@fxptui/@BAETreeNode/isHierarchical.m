function b = isHierarchical(this)
%ISHIERARCHICAL True if the object is Hierarchical
%   OUT = ISHIERARCHICAL(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

b = false;
if isempty(this.TreeNode); return; end
b = this.TreeNode.isHierarchical;

% [EOF]
