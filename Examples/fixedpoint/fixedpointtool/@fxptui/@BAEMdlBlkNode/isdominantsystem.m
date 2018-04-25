function b = isdominantsystem(this, prop)
%ISDOMINANTSYSTEM   returns true if the H is dominant.

%   Copyright 2006-2012 The MathWorks, Inc.

b = false;
if isempty(this.TreeNode); return; end

%this is a ModelReference node, disable mmo and dto depending on feature
%keyword value
if ~isNodeSupported(this.TreeNode)
    return;
end

[dSys, dParam] = this.TreeNode.getdominantsystem(prop);

refSysObj = get_param(this.TreeNode.daobject.ModelName, 'Object');
b = isa(this.TreeNode, 'fxptui.blkdgmnode') || isequal(dSys, refSysObj);

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
