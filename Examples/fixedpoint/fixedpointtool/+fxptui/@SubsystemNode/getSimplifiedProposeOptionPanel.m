function proposeOptionPanel = getSimplifiedProposeOptionPanel(this, isenabled)
% GETPROPOSEOPTIONPANEL Gets the widgets for the proposal options

% Copyright 2014-2015 The MathWorks, Inc.

r = 1;
me = fxptui.getexplorer;

if isempty(me)
    % explorer might be empty, return empty default
    proposeOptionPanel.Type = 'panel';
    proposeOptionPanel.Items = {};
    proposeOptionPanel.LayoutGrid = [1 1];
    return;
end

appdata = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getDAObject.getFullName);
% use the proposal setting to interact with the parameters now
proposalSettings = appdata.AutoscalerProposalSettings; 

% Get proposal option panel
propose_pnl = getLocalProposePanel(this, me, isenabled, proposalSettings);
propose_pnl.RowSpan = [r r];
propose_pnl.ColSpan = [1 2];

asc_pnl.Type = 'panel'; 
asc_pnl.Items = {};
asc_pnl.Items = {propose_pnl};
asc_pnl.LayoutGrid = [11 2]; 
asc_pnl.RowStretch = [0 0 0 0 0 0 0 0 0 0 1];
asc_pnl.ColStretch = [0 1];

proposeOptionPanel.Type = 'panel';
proposeOptionPanel.Items = {asc_pnl};
proposeOptionPanel.LayoutGrid = [1 1];
end
%--------------------------------------------------------------------------
function propose_pnl = getLocalProposePanel(~, me, isenabled, proposalSettings)
% Proposal option panel
r=1;

% Leading text: Propose: 
txt_propose.Type = 'text';
txt_propose.Tag = 'txt_propose';

txt_propose.Name =fxptui.message('labelProposePrompt'); 
txt_propose.RowSpan = [r r]; %r= r+1;
txt_propose.ColSpan = [1 1];
txt_propose.Enabled = true;

% checkbox on auto signedness
ckbox_signed.Type = 'checkbox';
ckbox_signed.Tag = 'propose_signedness';
ckbox_signed.Name = fxptui.message('labelProposeSignedness'); 

ckbox_signed.MatlabMethod = 'fxptui.SubsystemNode.setIsAutoSignedness';
ckbox_signed.MatlabArgs = {'%dialog','%tag','%source'};
ckbox_signed.Value = double(proposalSettings.isAutoSignedness);

ckbox_signed.Mode = false;
ckbox_signed.RowSpan = [r r]; % r=r+1;
ckbox_signed.ColSpan = [2 2];
ckbox_signed.Graphical = false; 
ckbox_signed.Alignment =1;
ckbox_signed.Enabled = isenabled;
ckbox_signed.DialogRefresh = true;

% WordLength Selection v.s. FractionLength proposals
asc_wl_selection.Type = 'radiobutton';
asc_wl_selection.Tag = 'scale_selection';
asc_wl_selection.Values = [0 1];
asc_wl_selection.Entries = {fxptui.message('entryWordLength'), ...
                               fxptui.message('entryFractionLength')}; 
asc_wl_selection.Name = '';
asc_wl_selection.Enabled = isenabled;
asc_wl_selection.Graphical = false;
asc_wl_selection.DialogRefresh = true;

if (~isempty(proposalSettings))
    asc_wl_selection.Value = uint8(~proposalSettings.isWLSelectionPolicy);
else
    asc_wl_selection.Value = uint8(1);
end
asc_wl_selection.MatlabMethod = 'fxptui.SubsystemNode.setDefaultContainerForFloatOrInherit';
asc_wl_selection.MatlabArgs = {'%dialog','%tag','%source'};

asc_wl_selection.Mode = false;
asc_wl_selection.RowSpan = [r r]; r=r+1;
asc_wl_selection.ColSpan = [3 4];
asc_wl_selection.OrientHorizontal = true;
asc_wl_selection.Alignment =1;
pnl_propose_fxpt.Type = 'panel';
pnl_propose_fxpt.RowSpan = [r r];
pnl_propose_fxpt.ColSpan = [1 1];
pnl_propose_fxpt.LayoutGrid  = [1 4];
pnl_propose_fxpt.ColStretch = [0 0 0 1];
pnl_propose_fxpt.Items = {txt_propose,ckbox_signed, asc_wl_selection};
% END row for propose WL or FL

% BEGIN Propose for checkbox row
txt_proposefor.Type = 'text';
txt_proposefor.Tag = 'txt_proposefor';
% make the variable persistent to improve performance.
txt_proposefor.Name = fxptui.message('labelProposeForPrompt');
txt_proposefor.RowSpan = [r r]; %r= r+1;
txt_proposefor.ColSpan = [1 1];
txt_proposefor.Enabled = true;


replace_inherit.Type = 'checkbox';
replace_inherit.Tag = 'replace_inherit';
replace_inherit.Name = fxptui.message('labelReplaceInherited'); 

replace_inherit.MatlabMethod = 'fxptui.SubsystemNode.setProposeForInherited';
replace_inherit.MatlabArgs = {'%dialog','%tag','%source'};
replace_inherit.Value = double(proposalSettings.ProposeForInherited);

replace_inherit.Mode = false;
replace_inherit.RowSpan = [r r]; % r=r+1;
replace_inherit.ColSpan = [2 2];
replace_inherit.Graphical = false; 
replace_inherit.Alignment =1;
replace_inherit.Enabled = isenabled; 
replace_inherit.DialogRefresh = true;

replace_fl.Type = 'checkbox';
replace_fl.Tag = 'replace_fl';
replace_fl.Name = fxptui.message('labelReplaceFloatingPoint');

replace_fl.MatlabMethod = 'fxptui.SubsystemNode.setProposeForFloatingPoint';
replace_fl.MatlabArgs = {'%dialog','%tag','%source'};
replace_fl.Value = double(proposalSettings.ProposeForFloatingPoint);

replace_fl.Mode = false;
replace_fl.RowSpan = [r r]; %r= r+1;
replace_fl.ColSpan = [3 3];
replace_fl.Graphical = false; 
replace_fl.Alignment = 1;
replace_fl.Enabled = isenabled;
replace_fl.DialogRefresh = true;

pnl_replace.Type = 'panel';
pnl_replace.RowSpan = [r r];
pnl_replace.ColSpan = [1 3];
pnl_replace.LayoutGrid  = [1 3];
pnl_replace.ColStretch = [0 0 1];
pnl_replace.Items = {txt_proposefor, replace_fl, replace_inherit};
% END Propose for checkbox row

% BEGIN Default type, signedness, WL and FL pane
r=r+1;
isShowDefaultContainer = proposalSettings.ProposeForInherited || proposalSettings.ProposeForFloatingPoint; 

% Default WL
edit_def_wl.Type = 'edit';
edit_def_wl.Tag = 'edit_def_wl';
edit_def_wl.MatlabMethod = 'fxptui.SubsystemNode.setDefaultContainerForFloatOrInherit';
edit_def_wl.MatlabArgs = {'%dialog','%tag','%source'};
edit_def_wl.Value = int2str(proposalSettings.DefaultWordLength);
edit_def_wl.Name =  fxptui.message('labelDefaultWordLength');
edit_def_wl.RowSpan = [r r];
edit_def_wl.ColSpan = [2 3];
edit_def_wl.MaximumSize=[50,30];
edit_def_wl.Alignment = 1;
if isShowDefaultContainer && (~proposalSettings.isWLSelectionPolicy)
    edit_def_wl.Visible = true;
else
    edit_def_wl.Visible = false;
end
edit_def_wl.Enabled = isShowDefaultContainer && isenabled; 
% edit_def_wl.Value = proposalSettings.
edit_def_wl.Graphical = false; 
edit_def_wl.Mode = false;

% Default FL
edit_def_fl.Type = 'edit';
edit_def_fl.Tag = 'edit_def_fl';

edit_def_fl.MatlabMethod = 'fxptui.SubsystemNode.setDefaultContainerForFloatOrInherit';
edit_def_fl.MatlabArgs = {'%dialog','%tag','%source'};
edit_def_fl.Value = int2str(proposalSettings.DefaultFractionLength);
edit_def_fl.Name =  fxptui.message('labelDefaultFractionLength');
edit_def_fl.RowSpan = [r r];
edit_def_fl.ColSpan = [2 3];
edit_def_fl.MaximumSize=[50,30];
edit_def_fl.Alignment = 1;
if isShowDefaultContainer && (proposalSettings.isWLSelectionPolicy)
    edit_def_fl.Visible = true;
else
    edit_def_fl.Visible = false;
end
edit_def_fl.Enabled = isShowDefaultContainer && isenabled; 
edit_def_fl.Graphical = false; 
edit_def_fl.Mode = false;

def_fl_panel.Type = 'panel';
def_fl_panel.RowSpan = [r r];
def_fl_panel.ColSpan = [2 3];
def_fl_panel.LayoutGrid  = [1 2];
def_fl_panel.ColStretch = [0 1];
def_fl_panel.Items = {edit_def_wl, edit_def_fl };
def_fl_panel.Visible = isShowDefaultContainer;

pnl_propose_others.Type = 'panel';
pnl_propose_others.RowSpan = [r r];
pnl_propose_others.ColSpan = [1 1];
pnl_propose_others.LayoutGrid  = [1 3];
pnl_propose_others.ColStretch = [0 0 1];
pnl_propose_others.Items = {pnl_replace, def_fl_panel };

% END Default type, signedness, WL and FL pane

% BEGIN use range pane and safety margin pane
r=r+2;
% Range Selection
cbo_range.Type = 'combobox';
cbo_range.Name = fxptui.message('labelUseRangePrompt');
cbo_range.Tag = 'cbo_def_range';
cbo_range.Values = [0 1 2];
cbo_range.Entries = {fxptui.message('entryAllRange'), ...
                    fxptui.message('entryDesignSim'), ...
                    fxptui.message('entryDesignDerive')};
cbo_range.Enabled = isenabled;
cbo_range.MatlabMethod = 'fxptui.SubsystemNode.setCollectedRange';
cbo_range.MatlabArgs = {'%dialog','%tag','%source'};
if (~isempty(proposalSettings))
    if (proposalSettings.isUsingSimMinMax && proposalSettings.isUsingDerivedMinMax)
        cbo_range.Value = uint8(0);
    elseif proposalSettings.isUsingSimMinMax
        cbo_range.Value = uint8(1);
    else
        cbo_range.Value = uint8(2);
    end
end
cbo_range.Mode = false;
cbo_range.RowSpan = [r r]; r=r+1;
cbo_range.ColSpan = [1 1];
cbo_range.OrientHorizontal = true;
cbo_range.Alignment = 1;
cbo_range.ShowBorder = false;
cbo_range.Graphical = false; 

% Safety margin for Sim Min/Max
edit_sm_sim.Type = 'edit';
edit_sm_sim.Tag = 'edit_safetymargin_sim';
% link source to proposalSetting field of top model
topAppData = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getDAObject.getFullName);
edit_sm_sim.Source = topAppData.AutoscalerProposalSettings;

edit_sm_sim.ObjectProperty = 'SafetyMarginForSimMinMax';
edit_sm_sim.Name = fxptui.message('labelSafetyMarginSimMinMax');
edit_sm_sim.RowSpan = [r r];
edit_sm_sim.ColSpan = [1 1];
edit_sm_sim.MaximumSize = [50,30];
edit_sm_sim.Alignment = 1;
edit_sm_sim.Enabled = isenabled && proposalSettings.isUsingSimMinMax;
edit_sm_sim.Graphical = false; 
edit_sm_sim.Mode = false;

pnl_range.Type = 'panel';
pnl_range.RowSpan = [r r];
pnl_range.ColSpan = [1 1];
pnl_range.LayoutGrid  = [1 2];
pnl_range.ColStretch = [0 1];
pnl_range.Items = {cbo_range, edit_sm_sim };
% END use range and safety margin pane

persistent codeview_name;
persistent codeview_tooltip;

% Add a hyperlink to launch the Code View if there are function blocks
% present in the SUD.
if fxptui.isMATLABFunctionBlockConversionEnabled() && coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled()    
    if isempty(codeview_name)
        codeview_name = coder.internal.mlfb.gui.message('linkOpenCodeView');
        codeview_tooltip = coder.internal.mlfb.gui.message('tooltipLinkOpenCodeView');
    end
	
    r = r + 1;    
    lnk_codeview.Type = 'hyperlink';
    lnk_codeview.Name = codeview_name;
    lnk_codeview.ToolTip = codeview_tooltip;
    lnk_codeview.Tag = 'link_mlfb_propose_code_view';
    lnk_codeview.MatlabMethod = 'coder.internal.mlfb.gui.fxptToolOpenCodeView';
    lnk_codeview.Alignment = 1;
    lnk_codeview.Visible = true;
    lnk_codeview.Alignment = 1;
    lnk_codeview.Enabled = isenabled;
    lnk_codeview.RowSpan = [r r]; % Last row, don't increment 'r'
    lnk_codeview.ColSpan = [1 2];
    
    Items = {pnl_propose_fxpt, pnl_propose_others, pnl_range, lnk_codeview};
else
    Items = {pnl_propose_fxpt, pnl_propose_others, pnl_range};
end

propose_pnl.Type = 'panel';
propose_pnl.Items = Items;
propose_pnl.LayoutGrid = [r 3];


end

% LocalWords:  proposefor wl cbo safetymargin
