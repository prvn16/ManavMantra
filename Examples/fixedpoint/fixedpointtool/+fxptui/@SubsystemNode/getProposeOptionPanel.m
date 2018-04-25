function proposeOptionPanel = getProposeOptionPanel(this)
% GETPROPOSEOPTIONPANEL Gets the widgets for the proposal options

% Copyright 2013-2016 The MathWorks, Inc.

    r = 1;
    me = fxptui.getexplorer;
    appdata = [];
    
    isenabled = false;
    if ~isempty(me)
        action = me.getaction('SCALE_PROPOSEDT');
        if ~isempty(action)
            isenabled = isequal('on', action.Enabled);
        end
        appdata = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getDAObject.getFullName);
        
    end
    
    % Autoscale selection
    asc_selection.Type = 'radiobutton';
    asc_selection.Tag = 'scale_selection';
    asc_selection.Values = [0 1];
    asc_selection.Entries = {fxptui.message('labelSCALEFL'),...
                        fxptui.message('labelSCALEWL')};
    asc_selection.Name = '';
    asc_selection.Enabled = isenabled;
    if(~isempty(appdata))
        asc_selection.Value = uint8(appdata.AutoscalerProposalSettings.isWLSelectionPolicy);
    else
        asc_selection.Value = uint8(0);
    end
    asc_selection.RowSpan = [r r];
    asc_selection.ColSpan = [1 3]; 
    
    pnl_selection.Type = 'panel';
    pnl_selection.LayoutGrid  = [1 3];
    pnl_selection.RowSpan = [r r];r=r+1;
    pnl_selection.ColStretch = [0 0 1];
    pnl_selection.Items = {asc_selection};
    
    [list, value] = getInputParameterDataType(this, appdata);   
    edit_default.Type = 'combobox';
    edit_default.Tag = 'edit_default';
    edit_default.Name = fxptui.message('labelDefaultDTForFlt'); 
    edit_default.NameLocation = 2;
    edit_default.Entries = list; 
    edit_default.MatlabMethod = 'fxptui.SubsystemNode.setDefaultDT';
    edit_default.MatlabArgs = {'%dialog','%tag','%source'};
    edit_default.Value = value;
    edit_default.Editable  = true; 
    edit_default.Mode = 1;
    edit_default.RowSpan = [r r];r=r+1;
    edit_default.ColSpan = [1 2];
    edit_default.Enabled = isenabled;
    
    edit_pnl.Type = 'panel';
    edit_pnl.Items = {edit_default};
    edit_pnl.LayoutGrid = [1 2];
    edit_pnl.RowSpan = [r r];r=r+1;
    edit_pnl.ColSpan = [1 2];
    edit_pnl.ColStretch = [0 1];
    
    range_pnl = getRangePanel(this, me, isenabled, appdata);
    range_pnl.RowSpan = [r r];r=r+1;
    range_pnl.ColSpan = [1 3];
    
    sf_margin_pnl = getSafetyMarginPanel(this, me, isenabled, appdata);
    sf_margin_pnl.RowSpan = [r r];
    sf_margin_pnl.ColSpan = [1 3];
    
    
    asc_pnl.Type = 'panel';
    asc_pnl.Items = {};
    if ~isempty(me)
        asc_pnl.Items = {pnl_selection, edit_pnl, range_pnl};
    end
    asc_pnl.Items = [asc_pnl.Items, {sf_margin_pnl}];
    asc_pnl.LayoutGrid = [4 3];
    asc_pnl.RowStretch = [0 0 0 1];
    asc_pnl.ColStretch = [0 0 1];
    
    proposeOptionPanel.Type = 'panel';
    if ~isempty(me)
        proposeOptionPanel.Items = {asc_pnl};
    else
        proposeOptionPanel.Items = {};
    end
    proposeOptionPanel.LayoutGrid = [1 1];
end
%--------------------------------------------------------------------------
function range_pnl = getRangePanel(~, me, isenabled, appdata)
    
    r = 1;
    Items = {};
    if ~isempty(me)
        asc_cbo.Type = 'text';
        asc_cbo.Name = fxptui.message('labelProposeUsing');
        asc_cbo.Buddy = 'autoscale_mode_derived';
        asc_cbo.RowSpan = [r r];r=r+1;
        asc_cbo.ColSpan = [1 2];
        asc_cbo.Enabled = isenabled;
        
        asc_cbo_drv.Type = 'checkbox';
        asc_cbo_drv.Tag = 'autoscale_drv_range';
        asc_cbo_drv.Name = fxptui.message('labelDerivedMinMax');
%         if(~isempty(appdata))
%             asc_cbo_drv.Source = appdata;
%         else
%             % We provide a default Application Data to work around the issue gecked in G496760. This can be removed
%             % once the geck is fixed.
%             asc_cbo_drv.Source = SimulinkFixedPoint.ApplicationData([]);
%         end
        
        asc_cbo_drv.MatlabMethod = 'fxptui.SubsystemNode.setIsUsingDerivedMinMax';
        asc_cbo_drv.MatlabArgs = {'%dialog','%tag','%source'};
        asc_cbo_drv.Value = appdata.AutoscalerProposalSettings.isUsingDerivedMinMax;

%         if(~isempty(appdata))
%             asc_cbo_drv.Value = uint8(appdata.isUsingDerivedMinMax);
%             if(appdata.isUsingDerivedMinMax==1)
%                 asc_cbo_drv.Value=true;
%             else
%                 asc_cbo_drv.Value=false;
%             end
%         else
%             asc_cbo_drv.Value = false;%uint8(0);
%         end

%         asc_cbo_drv.ObjectProperty = 'isUsingDerivedMinMax';
        asc_cbo_drv.Mode = 1;
        asc_cbo_drv.RowSpan = [r r];
        asc_cbo_drv.ColSpan = [1 1];
        asc_cbo_drv.Enabled = isenabled;
        
        asc_cbo_sim.Type = 'checkbox';
        asc_cbo_sim.Tag = 'autoscale_sim_range';
        asc_cbo_sim.Name = fxptui.message('labelSimulationMinMax');

        asc_cbo_sim.MatlabMethod = 'fxptui.SubsystemNode.setIsUsingSimMinMax';
        asc_cbo_sim.MatlabArgs = {'%dialog','%tag','%source'};
        asc_cbo_sim.Value = appdata.AutoscalerProposalSettings.isUsingSimMinMax;
%         if(~isempty(appdata))
%             asc_cbo_sim.Source = appdata;
%         else
%             % We provide a default Application Data to work around the issue gecked in G496760. This can be removed
%             % once the geck is fixed.
%             asc_cbo_sim.Source = SimulinkFixedPoint.ApplicationData([]);
%         end
        %asc_cbo_sim.ObjectProperty = 'isUsingSimMinMax';
        asc_cbo_sim.Mode = 1;
        asc_cbo_sim.RowSpan = [r r];
        asc_cbo_sim.ColSpan = [2 2];
        asc_cbo_sim.Enabled = isenabled;
        
        Items = {asc_cbo, asc_cbo_drv, asc_cbo_sim};
    end
    range_pnl.Type = 'panel';
    range_pnl.Items = Items;
    range_pnl.LayoutGrid = [2 3];
    range_pnl.ColStretch = [0 0 1];
    range_pnl.RowStretch = [0 1];
end
%------------------------------------------------------------------------
function sf_margin_pnl = getSafetyMarginPanel(~, me, isenabled, appdata)
    
    r = 1;
    sfmargin_sim_name = fxptui.message('labelSafetyMarginSimMinMax');
    
    % Safety margin for Sim Min/Max
    edit_sm_sim.Type = 'edit';
    edit_sm_sim.Tag = 'edit_sm_sim';
    if(~isempty(me))
        edit_sm_sim.Source = SimulinkFixedPoint.getApplicationData(me.getFPTRoot.getDAObject.getFullName);
    end
    edit_sm_sim.ObjectProperty = 'SafetyMarginForSimMinMax';
    edit_sm_sim.Name =  sfmargin_sim_name;
    edit_sm_sim.RowSpan = [r r];
    edit_sm_sim.ColSpan = [1 1];
    if ~isempty(appdata) && appdata.AutoscalerProposalSettings.isUsingSimMinMax
        edit_sm_sim.Enabled = isenabled;
    else
        edit_sm_sim.Enabled = false;
    end
    sf_margin_pnl.Type = 'panel';
    sf_margin_pnl.Items = {edit_sm_dsgn, edit_sm_sim};
    sf_margin_pnl.LayoutGrid = [2 3];
    sf_margin_pnl.RowSpan = [r-1 r];
    sf_margin_pnl.RowStretch = [0 1];
    sf_margin_pnl.ColStretch = [0 0 1];
end
