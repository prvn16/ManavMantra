function [ok, errmsg] = setProperties(~,hdlg)
% SETPROPERTIES Set the poperties on the model from the dialog

% Copyright 2013-2016 The MathWorks, Inc.

    ok = true;
    errmsg = '';

    me = fxptui.getexplorer;
    if isempty(me); return; end
    rootModel = me.getFPTRoot.getDAObject.getFullName;
    appData = me.getappdata;

    try
        val = hdlg.getWidgetValue('cbo_arch');
        if val
            set_param(rootModel,'MinMaxOverflowArchiveMode','Merge');
        else
            set_param(rootModel,'MinMaxOverflowArchiveMode','Overwrite');
        end
    catch e %#ok
    end

    try
        val = hdlg.getWidgetValue('run_name_edit');
        set_param(rootModel,'FPTRunName',val);
    catch e %#ok
    end

    try
        val = ~hdlg.getWidgetValue('scale_selection');
        % hdlg.getWidgetValue('scale_selection') returns 1 for FL and 0 for WL selection
        % The value is negated to set appData.AutoscalerProposalSettings.isWLSelectionPolicy
        
        if ~isempty(val)
            appData.AutoscalerProposalSettings.isWLSelectionPolicy = logical(val);
            hdlg.refresh;
        end
    catch e %#ok
    end

    try
        val = hdlg.getWidgetValue('derive_option');
        me.DeriveChoice = val;
        switch val
            case 0
                me.SystemForDerive = me.getSUDUINode;
            case 1
                me.SystemForDerive = me.getTopNode;
        end
    catch
    end

    me.getFPTRoot.fireHierarchyChanged;
end

% [EOF]

% LocalWords:  cbo btn instrumentationsimmodewarning appliesto FPT
