function isSUDVerified = setSystemForConversion(me, sysPath, objectClass)
% SETSYSTEMFORCONVERSION Sets the system selected for conversion and enables
% signal logging on the inputs & outputs. It also highlights the node in the
% tree.

% Copyright 2014-2015 The MathWorks, Inc.

isSUDVerified = false;
try
    if ~strncmpi(objectClass,'Stateflow',9)
        blkObj = get_param(sysPath, 'Object');
    else
       blkObj = fxptui.getStateflowChartFromPath(sysPath);
    end
    
    if isempty(blkObj)
        return;
    end
    % The above can return more than one object with the same path, for
    % example, a wrapping Simulink.Subsystem and a stateflo object.
    % We'll use the first object to make the selection.
    blkObj = blkObj(1);
    
    % Clear out changes made to the previous SUD
    me.clearSUDSettings;
    rootNode = me.getFPTRoot;
    if isempty(blkObj)
        blkObj = me.getTopNode.getDAObject;
    end
    
    isSUDVerified = true;
    % Set the new SUD
    me.GoalSpecifier.setSystemForConversion(blkObj);

    me.ConversionNode = rootNode.findNodeInCompleteHierarchy(blkObj);
    me.unhighlight;
    fxptui.cb_togglehighlight;
    updateWorkflowActions(me)
    dlg = me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.restoreFromSchema;
    end
catch 
    % ignore error
end

%--------------------------------------------------------
