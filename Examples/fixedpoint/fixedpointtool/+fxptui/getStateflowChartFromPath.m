function sfObj = getStateflowChartFromPath(sysPath)
% GETSTATEFLOWCHARTFROMPATH returns the stateflow object referenced by
% that system path

% Copyriht 2015, The MathWorks, Inc.

sfObj = [];

try
    sfObj = get_param(sysPath, 'Object');    
    ch = fxptds.getSFChartObject(sfObj);
    if ~fxptds.isStateflowChartObject(ch)
        sfObj = [];
    end  
catch
    % unable to resolve the path to a chart or its wrapping subsystem.
    % Return []
end

