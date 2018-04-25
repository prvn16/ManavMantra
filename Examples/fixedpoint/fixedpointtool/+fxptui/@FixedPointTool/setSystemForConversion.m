function blkObj = setSystemForConversion(this, sysPath, objectClass)
%SETSYSTEMFORCONVERSION Sets the SUD

% Copyright 2015-2016 The MathWorks, Inc.

    if ~strncmpi(objectClass,'Stateflow',9)
        blkObj = get_param(sysPath, 'Object');
    else
        blkObj = fxptui.getStateflowChartFromPath(sysPath);
        % The above can return more than one object with the same path, for
        % example, a wrapping Simulink.Subsystem and a stateflo object.
        % We'll use the first object to make the selection.
        if ~isempty(blkObj)
            blkObj = blkObj(1);
        end
    end
    this.GoalSpecifier.setSystemForConversion(blkObj);
end
