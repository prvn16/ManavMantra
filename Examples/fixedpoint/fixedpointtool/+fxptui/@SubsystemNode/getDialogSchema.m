function dlgstruct = getDialogSchema(this, name)
% GETDIALOGSCHEMA Gets the widgets that appear on the dialog for this node

% Copyright 2013-2015 The MathWorks, Inc.

%return empty if h is invalid
dlgstruct.DialogTitle = '';
dlgstruct.Items = {};
me = fxptui.getexplorer;

if strcmpi(name, 'propose_run_selection_dialog')
    dlgstruct = getRunSelectionDialogSchema(this,'propose');
elseif strcmpi(name, 'apply_run_selection_dialog')
    dlgstruct = getRunSelectionDialogSchema(this,'apply');
else
    if(~this.isValid); return; end;
    
    r=1;
    
    grp_sud_spec = this.getSUDPanel;
    grp_sud_spec.RowSpan = [r r];r=r+1;
    grp_sud_spec.ColSpan = [1 1];
    
    %get FPA launch panel
    grp_launch_fpa = getFPAPanel(this);
    grp_launch_fpa.RowSpan = [r r];r=r+1;
    grp_launch_fpa.ColSpan = [1 1];
    if ~isempty(me) && ~me.isSystemUnderConversionDefined
        grp_launch_fpa.Enabled = false;
    end
    
    grp_batch_action = getShortcutEditorPanel(this);
    grp_batch_action.RowSpan = [r r];r=r+1;
    grp_batch_action.ColSpan = [1 1];
    if ~isempty(me) && ~me.isSystemUnderConversionDefined
        grp_batch_action.Enabled = false;
    end
    
    %get simulation settings panel
    grp_sim = getSimPanel(this);
    grp_sim.RowSpan = [r r];r=r+1;
    grp_sim.ColSpan = [1 1];
    if ~isempty(me) && ~me.isSystemUnderConversionDefined
        grp_sim.Enabled = false;
    end
    
    %get autoscale settings panel
    grp_scl = getProposeDTPanel(this);
    grp_scl.RowSpan = [r r];r=r+1;
    grp_scl.ColSpan = [1 1];
    if ~isempty(me) && ~me.isSystemUnderConversionDefined
        grp_scl.Enabled = false;
    end
    
    grp_res = getResultPanel(this);
    
    %create spacer panel
    spacer2.Type = 'panel';
    spacer2.RowSpan = [r r];r=r+1;
    spacer2.ColSpan = [1 1];
    spacer2.LayoutGrid = [1 1];
    
    %invisible widget to listen to block property changes
    if ~isempty(this.DAObject)
        blkprops.Source = this.DAObject;
        blkprops.ListenToProperties = { ...
            'MinMaxOverflowLogging', ...
            'DataTypeOverride', ...
            'DataTypeOverrideAppliesTo', ...
            'MinMaxOverflowArchiveMode',...
            'FPTRunName'};
    end
    blkprops.Visible = false;
    blkprops.Type = 'edit';
    blkprops.RowSpan = [r r];r = r+1;
    blkprops.ColSpan = [1 1];
    
    %% tab panels
    %create main dialog
    dlgstruct.DialogTitle = '';
    dlgstruct.DialogTag = 'Fixed_Point_Tool_Dialog';
    dlgstruct.HelpMethod = 'doc';
    dlgstruct.HelpArgs =  {'fxptdlg'};
    dlgstruct.PreApplyCallback = 'setProperties';
    dlgstruct.PreApplyArgs = {this,'%dialog'};
    dlgstruct.PreApplyArgsDT = {'handle','handle'};
    
    tab1.Name = fxptui.message('workflowTabTitle');
    tab1.Tag = 'FPTWorkflowTab';
    tab1.LayoutGrid  = [r-1 1];
    tab1.RowStretch = [zeros(1,r-2) 1];

    tab1.Items = {grp_sud_spec, grp_launch_fpa, grp_batch_action, grp_sim, grp_scl, spacer2, blkprops};

    %get results panel
    tab2.Items = {grp_res};
    tab2.Name = fxptui.message('resultreportResultDetails');
    tab2.Tag = 'FPTResultDetailsTab';
    tab2.WidgetId = 'ResultDetailsWidgetTab';

    %%%%%%%%%%%%%%%%%%%%%%
    % bodycoord items
    %%%%%%%%%%%%%%%%%%%%%%
    tab_cont.Name = '';
    tab_cont.Tag = 'FPTTabContainer';
    tab_cont.Type = 'tab';
    tab_cont.Tabs = {tab1, tab2};
    tab_cont.TabChangedCallback = 'fxptui.cb_tabChangedCallback';

    dlgstruct.LayoutGrid  = [1 1];
    dlgstruct.Items = {tab_cont};
    
end
end
