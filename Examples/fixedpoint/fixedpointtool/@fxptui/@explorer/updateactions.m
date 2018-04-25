function updateactions(h)
%UPDATEACTIONS   Update the UI Actions (callbacks)

%   Copyright 2006-2017 The MathWorks, Inc.


%widgets need to update their enabledness depending on the enabledness of
%certain actions. Firing a property change reloads the dialog.
node = h.getTreeSelection;
if isa(node, 'DAStudio.DAObjectProxy')
    node = node.getMCOSObjectReference;
end

if(isa(node, 'fxptui.ExplorerRoot'))
    h.getaction('VIEW_TSINFIGURE').Enabled = 'off';
    h.getaction('VIEW_HISTINFIGURE').Enabled = 'off';
    h.getaction('VIEW_DIFFINFIGURE').Enabled = 'off';
    h.getaction('VIEW_RUNCOMPARE').Enabled = 'off';
    h.getaction('VIEW_RESULT_ISSUE_HIGHLIGHT').Enabled = 'off';
    h.getaction('HILITE_BLOCK').Enabled = 'off';
    h.getaction('HILITE_CLEAR').Enabled = 'off';
    h.getaction('HILITE_DTGROUP').Enabled = 'off';
    h.getaction('SCALE_PROPOSEDT').Enabled = 'off';
    h.getaction('SCALE_APPLYDT').Enabled = 'off';
    h.getaction('RESULTS_CLEARSELRUN').Enabled = 'off';
    h.getaction('EXPORT_DATASET').Enabled = 'off';
    h.getaction('RESULTS_CLEARALLRUN').Enabled = 'Off';
    h.getaction('START').Enabled = 'off';
    h.getaction('PAUSE').Enabled = 'off';
    h.getaction('STOP').Enabled = 'off';
    h.getaction('DERIVE').Enabled = 'off';
    h.getaction('LAUNCHFPA').Enabled = 'off';
    h.HasVisibleResults = false;
	
	if fxptui.isMATLABFunctionBlockConversionEnabled()
		h.getaction('OPEN_CODE_VIEW').Enabled = 'off';
	end
	
    node.firePropertyChanged;
    return;
end

blkDgms = h.getBlkDgmNodes;

maxNumberOfRuns = 0;
dataLayer = fxptds.DataLayerInterface.getInstance();
for idx = 1:length(blkDgms)
    curBlkDgm = blkDgms(idx); 
    appData = SimulinkFixedPoint.getApplicationData(curBlkDgm.getDAObject.getFullName);
    allRunNames = dataLayer.getAllRunNamesUsingApplicationData(appData);
    maxNumberOfRuns = max([numel(allRunNames), maxNumberOfRuns]);
end
   

% maximum number of runs in all dataset
runs = maxNumberOfRuns;

if (isempty(runs)) || (runs == 0)
    h.getaction('VIEW_TSINFIGURE').Enabled = 'off';
    h.getaction('VIEW_HISTINFIGURE').Enabled = 'off';
    h.getaction('VIEW_DIFFINFIGURE').Enabled = 'off';
    h.getaction('VIEW_RUNCOMPARE').Enabled = 'off';
    h.getaction('VIEW_RESULT_ISSUE_HIGHLIGHT').Enabled = 'off';
    h.getaction('HILITE_BLOCK').Enabled = 'off';
    h.getaction('HILITE_CLEAR').Enabled = 'off';
    h.getaction('HILITE_DTGROUP').Enabled = 'off';
    h.getaction('SCALE_PROPOSEDT').Enabled = 'on';
    h.getaction('SCALE_APPLYDT').Enabled = 'on';
    h.getaction('RESULTS_CLEARSELRUN').Enabled = 'off';
    h.getaction('RESULTS_CLEARALLRUN').Enabled = 'Off';
    h.getaction('EXPORT_DATASET').Enabled = 'off';
    h.getaction('IMPORT_DATASET').Enabled = 'on';
    h.getaction('START').Enabled = 'on';
    h.getaction('PAUSE').Enabled = 'off';
    h.getaction('STOP').Enabled = 'off';
    h.getaction('DERIVE').Enabled = 'on';
    h.getaction('LAUNCHFPA').Enabled = 'on';
    h.HasVisibleResults = false;
elseif (runs == 1)
    h.getaction('VIEW_TSINFIGURE').Enabled = 'on';
    h.getaction('VIEW_HISTINFIGURE').Enabled = 'on';
    h.getaction('VIEW_DIFFINFIGURE').Enabled = 'on';
    h.getaction('VIEW_RUNCOMPARE').Enabled = 'on';
    h.getaction('VIEW_RESULT_ISSUE_HIGHLIGHT').Enabled = 'on';
    h.getaction('HILITE_BLOCK').Enabled = 'on';
    h.getaction('HILITE_CLEAR').Enabled = 'on';
    h.getaction('HILITE_DTGROUP').Enabled = 'on';
    h.getaction('SCALE_PROPOSEDT').Enabled = 'on';
    h.getaction('SCALE_APPLYDT').Enabled = 'on';
    h.getaction('RESULTS_CLEARSELRUN').Enabled = 'on';
    h.getaction('RESULTS_CLEARALLRUN').Enabled = 'on';
    h.getaction('EXPORT_DATASET').Enabled = 'on';
    h.getaction('IMPORT_DATASET').Enabled = 'on';
    h.getaction('START').Enabled = 'on';
    h.getaction('PAUSE').Enabled = 'off';
    h.getaction('STOP').Enabled = 'off';
    h.getaction('DERIVE').Enabled = 'on';
    h.getaction('LAUNCHFPA').Enabled = 'on';
    h.HasVisibleResults = true;
else
    h.getaction('VIEW_TSINFIGURE').Enabled = 'on';
    h.getaction('VIEW_HISTINFIGURE').Enabled = 'on';
    h.getaction('VIEW_DIFFINFIGURE').Enabled = 'on';
    h.getaction('VIEW_RUNCOMPARE').Enabled = 'on';
    h.getaction('VIEW_RESULT_ISSUE_HIGHLIGHT').Enabled = 'on';
    h.getaction('HILITE_BLOCK').Enabled = 'on';
    h.getaction('HILITE_CLEAR').Enabled = 'on';
    h.getaction('RESULTS_CLEARSELRUN').Enabled = 'on';
    h.getaction('RESULTS_CLEARALLRUN').Enabled = 'On';
    h.getaction('EXPORT_DATASET').Enabled = 'on';
    h.getaction('IMPORT_DATASET').Enabled = 'on';
    h.getaction('SCALE_PROPOSEDT').Enabled = 'on';
    h.getaction('SCALE_APPLYDT').Enabled = 'on';
    h.getaction('START').Enabled = 'on';
    h.getaction('PAUSE').Enabled = 'off';
    h.getaction('STOP').Enabled = 'off';
    h.getaction('DERIVE').Enabled = 'on';
    h.getaction('LAUNCHFPA').Enabled = 'on';
    h.HasVisibleResults = true;
end

h.updateWorkflowActions;

if(isa(node, 'fxptui.SubsystemNode'))
    node.firePropertyChanged;
    dlg = h.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end
end

% [EOF]
