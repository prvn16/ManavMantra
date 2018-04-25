function dlgStruct = getRunSelectionDialogSchema(this, name)
% GETRUNSELECTIONDIALOGSCHEMA Get the widgets for run selection

% Copyright 2013 MathWorks, Inc

    dlgStruct = [];
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
    
    if strcmpi(name,'propose')
        
        [entries, value] = getRunsForProposal(this);
        run_selection.Type = 'radiobutton';
        run_selection.Tag = 'run_propose_selection';
        run_selection.Entries = entries;
        run_selection.Name = fxptui.message('msgProposeRunSelection');
        run_selection.Enabled = isenabled;
        run_selection.Value = value;
        run_selection.RowSpan = [r r];
        run_selection.ColSpan = [1 2]; 
        run_selection.MatlabMethod = 'setRunSelectionForProposal';
        run_selection.MatlabArgs = {'%source','%dialog','%tag'};
        
        pnl_selection.Type = 'panel';
        pnl_selection.LayoutGrid  = [1 2];
        pnl_selection.RowSpan = [r r];r=r+1;
        pnl_selection.ColStretch = [0 1];
        pnl_selection.Items = {run_selection};
        
        dlgStruct.DialogTitle = fxptui.message('titleProposeRunSelection');
        dlgStruct.DialogTag = 'Run_Selection_Proposal_Dialog';
        dlgStruct.LayoutGrid  = [r-1 2];
        dlgStruct.ColStretch = [0 1];
        dlgStruct.Sticky = true;
        dlgStruct.CloseCallback = 'fxptui.cb_scalepropose';
        dlgStruct.CloseArgs = {'%dialog','%closeaction'};
        dlgStruct.StandaloneButtonSet = {'OK'};
        dlgStruct.Items = {pnl_selection};
    else
        [entries, value] = getRunsWithProposals(this);
        run_selection.Type = 'radiobutton';
        run_selection.Tag = 'run_apply_selection';
        run_selection.Entries = entries;
        run_selection.Name = fxptui.message('msgApplyRunSelection');
        run_selection.Enabled = isenabled;
        run_selection.Value = value;
        run_selection.RowSpan = [r r];
        run_selection.ColSpan = [1 2]; 
        run_selection.MatlabMethod = 'setRunSelectionForApply';
        run_selection.MatlabArgs = {'%source','%dialog','%tag'};
        
        pnl_selection.Type = 'panel';
        pnl_selection.LayoutGrid  = [1 2];
        pnl_selection.RowSpan = [r r];r=r+1;
        pnl_selection.ColStretch = [0 1];
        pnl_selection.Items = {run_selection};
        
        dlgStruct.DialogTitle = fxptui.message('titleApplyRunSelection');
        dlgStruct.DialogTag = 'Run_Selection_Apply_Dialog';
        dlgStruct.LayoutGrid  = [r-1 2];
        dlgStruct.ColStretch = [0 1];
        dlgStruct.Sticky = true;
        dlgStruct.CloseCallback = 'fxptui.cb_scaleapply';
        dlgStruct.CloseArgs = {'%dialog','%closeaction'};
        dlgStruct.StandaloneButtonSet = {'OK'};
        dlgStruct.Items = {pnl_selection};
    end
end
