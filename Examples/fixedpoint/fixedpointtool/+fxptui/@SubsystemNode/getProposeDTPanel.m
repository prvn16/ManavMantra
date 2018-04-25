function grp_scl = getProposeDTPanel(this)
% GETPROPOSEDTPANEL Get the widgets for the data type proposal panel.

% Copyright 2013-2016 The MathWorks, Inc.

me = fxptui.getexplorer;
isenabled = false;
inHotRestartMode = false;

if ~isempty(me)
    inHotRestartMode = isequal(get_param(me.getFPTRoot.getHighestLevelParent,'InteractiveSimInterfaceExecutionStatus'),2);
    action = me.getaction('SCALE_PROPOSEDT');
    if inHotRestartMode
        action.Enabled = 'off';
    end
    if ~isempty(action)
        isenabled = isequal('on', action.Enabled);
    end
end


isApplyEnabled = false;
if ~isempty(me)
    action = me.getaction('SCALE_APPLYDT');
    if inHotRestartMode
        action.Enabled = 'off';
    end
    if ~isempty(action)
        isApplyEnabled = isequal('on', action.Enabled);
    end
end


grp_scl = getSimplifiedProposalPanel(this, isenabled, isApplyEnabled);

end

%---------------------------------------------------------------------
% [EOF]

% LocalWords:  PROPOSEDT APPLYDT SCALEPROPOSEWL scl SCALEAPPLYWL Autoscaling
