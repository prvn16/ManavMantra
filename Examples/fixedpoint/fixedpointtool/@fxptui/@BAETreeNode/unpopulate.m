function unpopulate(this)
%UNPOPULATE <short description>
%   OUT = UNPOPULATE(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

ch = this.Children;
for i = 1:length(ch)
    node = ch{i};
    if ~isempty(node) && isa(node,'fxptui.BAETreeNode')
        unpopulate(node);
        delete(node);
    end
end
delete(this.TreeNode);
this.TreeNode = [];
this.Parent = [];
this.Children = [];
deletelisteners(this);

%--------------------------------------------------------------------------
function deletelisteners(this)
for lIdx = 1:numel(this.BlkListeners)
  delete(this.BlkListeners(lIdx));
end
this.BlkListeners = [];

%--------------------------------------------------------------------------
% [EOF]
