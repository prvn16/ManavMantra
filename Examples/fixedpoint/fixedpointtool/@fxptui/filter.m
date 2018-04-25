function filtered_children = filter(children)
%FILTER removes unwanted children

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.

filtered_children = [];

if(isempty(children))
  return;
end

%filter out unwanted nodes
%TODO this should be user specified
children = find(children,'-depth', 0, ...
  '-not','-isa','DAStudio.WorkspaceNode',...
  '-not','-isa','Simulink.ConfigSet',...
  '-not','-isa','Simulink.code',...
  '-not','-isa','Simulink.ModelAdvisor',...
  '-not','-isa','Simulink.Annotation',...
  '-not','-isa','DAStudio.Shortcut', ...
  '-not','-isa','Simulink.Target'); %#ok<GTARG>

for i = 1:numel(children)
  subsys = children(i);
  if(isvalid(subsys))
    filtered_children = [filtered_children subsys]; %#ok<AGROW>
  end
end
%--------------------------------------------------------------------------
function b = isvalid(subsys)
b = subsys.isHierarchical;
if(~b); return; end
%return true if subsys is a known valid type
if(isa(subsys, 'Stateflow.Object') || isa(subsys, 'Simulink.ModelReference'))
  return;
end
%return false if this subsystem contains only annotations
if(isa(subsys.getChildren, 'Simulink.Annotation'))
  b = false;
  return;
end
%return false if this subsystem is a demo launcher ('More Info') or an old
%fxptdlg launcher ('FixPt UI')
try
  if(~isempty(strfind(subsys.OpenFcn, 'demo')) || ...
      ~isempty(strfind(subsys.OpenFcn, 'fxptdlg')) || ...
      ~isempty(strfind(subsys.OpenFcn, 'simcad')) || ...
      ~isempty(strfind(subsys.OpenFcn, 'helpbrowser')))
    b = false;
  end
catch fpt_exception %#ok<NASGU>
  b = false;
end

% [EOF]