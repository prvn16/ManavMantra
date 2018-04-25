function b = isdominantsystem(this, prop)
%ISDOMINANTSYSTEM True if the object is dominantsystem
%   OUT = ISDOMINANTSYSTEM(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.


b = false;
if isempty(this.TreeNode); return; end
%SubSystem, BlockDiagram or Charts are valid
if(~fxptui.isValidTreeNode(this.TreeNode));return;end;
%if this is a ModelReference, LinkedLibrary or a system under a linked library (disable mmo and dto)
if(this.TreeNode.daobject.isModelReference || this.TreeNode.daobject.isLinked || isUnderLinkedLibrary(this.TreeNode))
	return;
end

[dSys, dParam] = getdominantsystem(this, prop);
b = isa(this.TreeNode, 'fxptui.blkdgmnode') || isequal(dSys, this.TreeNode.daobject);

if(b)
	switch prop
		case 'MinMaxOverflowLogging'
			this.MMODominantSystem = [];
			this.MMODominantParam = '';
		case 'DataTypeOverride'
			this.DTODominantSystem = [];
			this.DTODominantParam = '';
		otherwise
	end
else
	switch prop
		case 'MinMaxOverflowLogging'
			this.MMODominantSystem = dSys;
			this.MMODominantParam = dParam;
		case 'DataTypeOverride'
			this.DTODominantSystem = dSys;
			this.DTODominantParam = dParam;
		otherwise
	end
end
% [EOF]
