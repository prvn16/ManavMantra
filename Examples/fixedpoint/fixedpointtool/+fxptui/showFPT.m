function showFPT
% SHOWFPT Show FPT UI

% Copyright 2014-2016 The MathWorks, Inc.

me = fxptui.getexplorer;
fpt = fxptui.FixedPointTool.getExistingInstance;
if ~isempty(fpt)
    fpt.show;
elseif ~isempty(me)
    % hide is required on mac. to show FPT in view, it is required to
    % perform hide before show on mac machines.
    me.hide;
    me.show;
end
