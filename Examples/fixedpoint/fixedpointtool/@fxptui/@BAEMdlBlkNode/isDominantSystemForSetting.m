function b = isDominantSystemForSetting(this, prop)
% ISDOMINANTSYSTEMFORSETTING Returns true if the system represented by this node is controlling the property
    
% Copyright 2015 MathWorks, Inc.
    

    b = false;
    %this is a ModelReference node, disable mmo and dto depending on feature
    %keyword value
    if ~isNodeSupported(this.TreeNode)
        return;
    end

    [dSys, dParam] = getDominantSystemForSetting(this, prop);
    refSysObj = get_param(this.daobject.ModelName, 'Object');
    b = isa(this, 'fxptui.blkdgmnode') || isequal(dSys, refSysObj);
    if b
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
end