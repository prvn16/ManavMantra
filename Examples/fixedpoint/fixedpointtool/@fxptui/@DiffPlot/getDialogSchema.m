function dlgstruct = getDialogSchema(this, name) %#ok
%GETDIALOGSCHEMA Get the dialog information.
%   OUT = GETDIALOGSCHEMA(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.

r = 1;
me = fxptui.getexplorer;

isenabled = false;
if(isempty(me))
    isenabled = false;
else
    action = me.getaction('START');
    if ~isempty(action)
        isenabled = strcmp('on', action.enabled);
    end
end
if ~isempty(me)
    selection = me.getSelectedListNodes;
else
    selection.Name = '';
    selection.Run = '';
end

%************************************************
% Create the widget that describes the selection
%************************************************
diff_signal_txt.Type = 'text';
diff_signal_txt.Tag = 'diff_signal_txt';
switch this.methodSelection
  case {'selectchannel', 'selectchannelforcomparesignals', 'selectchannelforcompareruns'}
    diff_signal_txt.Name = fxptui.message('msgDiffPlotCurrentSelectionMultipleChannel',selection.getUniqueIdentifier.getDisplayName, selection.getRunName);
  case 'comparesignals'
    diff_signal_txt.Name = fxptui.message('msgDiffPlotCurrentSelection',selection.getUniqueIdentifier.getDisplayName, selection.getRunName);
  case 'compareruns'
    diff_signal_txt.Name = fxptui.message('msgCompareRunCurrentSelection', selection.getRunName);
end
diff_signal_txt.RowSpan = [1 1];
diff_signal_txt.ColSpan = [1 1];

pnl_txt.Type = 'panel';
pnl_txt.LayoutGrid  = [1 1];
pnl_txt.RowSpan = [1 1];
pnl_txt.ColSpan = [1 1];
pnl_txt.Items = {diff_signal_txt};

%*******************************************************************
% Create the widget to select the component to plot if the signal
% has more than one component.
%*******************************************************************
if strcmpi(this.methodSelection,'selectchannel') || ...
        strcmpi(this.methodSelection,'selectchannelforcomparesignals') || ...
        strcmpi(this.methodSelection,'selectchannelforcompareruns')
    [entries, value] = getChannelsForDiff(this);
    diff_ch_selection.Type = 'radiobutton';
    diff_ch_selection.Tag = 'diffplot_ch_selection';
    diff_ch_selection.Entries = entries;
    diff_ch_selection.Name = fxptui.message('msgDiffAgainstChannel');
    diff_ch_selection.Enabled = isenabled;
    diff_ch_selection.Value = value;
    diff_ch_selection.RowSpan = [1 1];
    diff_ch_selection.ColSpan = [1 1];
    diff_ch_selection.MatlabMethod = 'setChannelSelection';
    diff_ch_selection.MatlabArgs = {'%source','%dialog','%tag'};
    
    pnl_ch_selection.Type = 'panel';
    pnl_ch_selection.RowSpan = [1 1];
    pnl_ch_selection.ColSpan = [1 1];
    pnl_ch_selection.Items = {diff_ch_selection};
end

%********************************************************************
% Create the widget to select the run if there are more than 2 runs
% captured for the signal
%********************************************************************
[runNames, value] = getRunsForDiff(this);
if numel(runNames) > 1
    diff_selection.Type = 'radiobutton';
    diff_selection.Tag = 'diffplot_selection';
    diff_selection.Entries = runNames;
    diff_selection.Name = fxptui.message('msgDiffAgainstRun');
    diff_selection.Enabled = isenabled;
    diff_selection.Value = value;
    diff_selection.RowSpan = [1 1];
    diff_selection.ColSpan = [1 1];
    diff_selection.MatlabMethod = 'setRunSelection';
    diff_selection.MatlabArgs = {'%source','%dialog','%tag'};

    pnl_run_selection.Type = 'panel';
    pnl_run_selection.Items = {diff_selection};
    pnl_run_selection.RowSpan = [1 1];
    pnl_run_selection.ColSpan = [1 1];
end

%****************************************************************
% Create the final panel with the widgets based on the specified
% mode.
%****************************************************************
pnl_selector.Type = 'panel';
pnl_selector.Items = {pnl_txt}; r=r+1;
if  strcmpi(this.methodSelection,'selectchannelforcomparesignals') || ...
        strcmpi(this.methodSelection,'selectchannelforcompareruns')
    pnl_ch_selection.RowSpan = [r r];
    pnl_selector.Items = [pnl_selector.Items,{pnl_ch_selection}];
    r = r+1;
end
if numel(runNames) > 1
    pnl_run_selection.RowSpan = [r r];
    pnl_selector.Items = [pnl_selector.Items,{pnl_run_selection}];
    r = r+1;
end
pnl_selector.RowSpan = [1 r-1];
pnl_selector.ColSpan = [1 1];

%*************************************************************
% Create the main struct and add the dialog callbacks based
% on the specified mode.
%*************************************************************
switch this.methodSelection
    case {'comparesignals','selectchannelforcomparesignals'}
      dlgstruct.DialogTitle = fxptui.message('titleDiffPlotSelectorSDI');
      dlgstruct.PostApplyMethod = 'plotDiffForSelection';
    case {'compareruns','selectchannelforcompareruns'}
        dlgstruct.DialogTitle = fxptui.message('titleCompareRunsSelectorSDI');
        dlgstruct.PostApplyMethod = 'compareRunsForSelection';
end
dlgstruct.DialogTag = 'FPT_Diff_Plot_Selector_Dialog';
dlgstruct.Items = {pnl_selector};
dlgstruct.LayoutGrid  = [1 1];
dlgstruct.Sticky = true;
dlgstruct.StandaloneButtonSet = {'OK'};


