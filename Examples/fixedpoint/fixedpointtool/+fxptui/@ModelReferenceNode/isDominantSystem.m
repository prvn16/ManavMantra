function b = isDominantSystem(this, prop)
% ISDOMINANTSYSTEM Returns true if the system represented by this node is controlling the property
    
% Copyright 2013 MathWorks, Inc.
    

    b = false;
    %this is a ModelReference node, disable mmo and dto depending on feature
    %keyword value
    if ~isNodeSupported(this)
        return;
    end

    [dSys, dParam] = getDominantSystem(this, prop);
    refSysObj = get_param(this.DAObject.ModelName, 'Object');
    b = isa(this, 'fxptui.ModelNode') || isequal(dSys, refSysObj);
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

