function selectNode(this)
%SELECTNODE Selects the top model node.
%   OUT = SELECTNODE(ARGS) <long description>

%   Copyright 2012 MathWorks, Inc.

this.imme.selectTreeViewNode(this.getTopNode);
this.imme.expandTreeNode(this.getTopNode);

%-------------------------------------------------------------------
% [EOF]
