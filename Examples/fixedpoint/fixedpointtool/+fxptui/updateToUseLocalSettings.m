function updateToUseLocalSettings(system, settingParameter)
% UPDATETOUSELOCALSETTINGS Remove the DTO or MMO settings on the entire model hierarchy

% Copyright 2015-2017 The MathWorks, Inc.


sysObj = get_param(system,'Object');

if sysObj.isLinked
   % linked model construct returns early "from-here-down"
   return;  
end

% update subsystem parameter values
try
    % this code can be called when model is in compile mode
    % use try-catch to avoid this one case
     if ~strcmpi(get_param(system,settingParameter),'UseLocalSettings')
         set_param(system,settingParameter,'UseLocalSetting');
     end
catch
    % do nothing. Just return from here
    return;
end


children = sysObj.getHierarchicalChildren;
ch = find(children,'-depth',0,'-isa','Stateflow.Chart',...
    '-or','-isa', 'Stateflow.LinkChart',...
    '-or','-isa', 'Stateflow.EMChart',...
     '-or','-isa', 'Stateflow.TruthTableChart',...
     '-or','-isa', 'Stateflow.ReactiveTestingTableChart',...
     '-or','-isa', 'Stateflow.StateTransitionTableChart',...
     '-or','-isa', 'Simulink.SubSystem'); %#ok<GTARG>
 for i = 1:numel(ch)
     child = ch(i);
     if fxptds.isStateflowChartObject(child)
         % Get the wrapping subsystem object
         child = ch(i).up;
     end
     if isequal(child, sysObj) || child.isLinked
         % With stateflow chart hierarchies, you can end up where the
         % wrapping substsystem object returns the chart again causing an
         % infinite recursion.
         continue;
     end
     
     % MMO setting should be set for child. 
     % Otherwise, it is real error
     if ~strcmpi(get_param(child.getFullName,settingParameter),'UseLocalSettings')
         set_param(child.getFullName,settingParameter, 'UseLocalSetting');
     end
     fxptui.updateToUseLocalSettings(child.getFullName, settingParameter);
 end
