function cb_scaleapply(varargin)
%CB_SCALEAPPLY

%   Copyright 2006-2017 The MathWorks, Inc.

if nargin > 0
    closeAction = varargin{2};
    if ~strcmpi(closeAction,'Ok')
        return;
    end
end
me = fxptui.getexplorer;
if ~me.SelectedRunForApply; return; end

bd =  me.getTopNode;
if(~isa(bd, 'fxptui.ModelNode'))
    return;
end

topMdlName = bd.getDAObject.getFullName;
appData = SimulinkFixedPoint.getApplicationData(topMdlName);

treenode = initui(me);
if(isempty(treenode)); return; end


% determine if proceed by checking all submodels included
isProceedScaleApply = checkAllProposals(me, topMdlName);
if ~isProceedScaleApply; restoreui(me, treenode, appData); return; end

topModelScaleSetting = appData.settingToStruct();
applySuccess = true; % Determine whether apply succeeded for the Code View

sudName = treenode.getDAObject.getFullName;
proposalSettings = topModelScaleSetting;

try
	engineContext = SimulinkFixedPoint.DataTypingServices.EngineContext(...
    topMdlName, ...
    sudName, ...
    proposalSettings, ...
    SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);
    engineInterface = SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
    engineInterface.run(engineContext);
catch fpt_exception
    fxptui.showdialog('scaleapplyfailed', fpt_exception.message);
    applySuccess = false;
end

try
    SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(topMdlName, topModelScaleSetting.scaleUsingRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    fxptui.showdialog('scaleapplyfailed', fpt_exception.message);
    applySuccess = false;
end

restoreui(me, treenode, appData);

me.ExternalViewer.typesApplied(applySuccess);

%--------------------------------------------------------------------------
function treenode = initui(me)

success = loadReferencedModels(me);
if ~success; treenode = []; return; end;


    treenode =  me.ConversionNode;
    % If the selected node is an unsupported node for actions in a tree (state,
    % mdlref block), then perform the action on the selected nodes' parent.
    treenode = getSupportedParentTreeNode(treenode);

if isempty(treenode); return; end

me.sleep;
%turn backtrace off while the model is running.
me.userdata.warning.backtrace = warning('backtrace');
warning('off', 'backtrace');
%apply changes before running the simulation
if(~isempty(me.imme.getDialogHandle)&& me.imme.getDialogHandle.hasUnappliedChanges)
    me.imme.getDialogHandle.apply;
end
%disable all actions in the ui
me.setallactions('off');

%update selected system's dialog - we just disabled all actions
%treenode = me.imme.getCurrentTreeNode;
treenode.firePropertyChanged;
%suppress progressbar in BAT
if(~me.istesting)
    me.progressbar = fxptui.createprogressbar(me,fxptui.message('labelSCALEAPPLYDT'));
end
pause(2);

%--------------------------------------------------------------------------
function restoreui(me, treenode,appdata)
% Update the list view based on the filter selection.
me.wake;
me.restoreactionstate;
me.updateactions;
treenode.firePropertyChanged;
state = me.userdata.warning.backtrace.state;
warning(state, 'backtrace');
if(~me.istesting && ~isempty(me.progressbar))
    me.progressbar.dispose;
end
    mdlname = me.getTopNode.getDAObject.getFullName;
    try
        interface = get_param(mdlname, 'ObjectAPI_FP');
        term(interface);
    catch e %#ok
        %consume error. this to make sure that the scaling engine init gets reset
        %if it hasn't terminated correctly
    end
if ~isempty(me.GroupColumn)
    % Refresh any existing grouping
    treenode.fireHierarchyChanged;
end
beep;

%---------------------------------------------------------------------------
function isProceedScaleApply = checkAllProposals(me, topMdlName)

isProceedScaleApply = false;

topAppData = SimulinkFixedPoint.getApplicationData(topMdlName);

runName = topAppData.ScaleUsing;
totalResults = me.getBlkDgmResults(topAppData.ScaleUsing);

if isempty(totalResults) || ~me.hasproposedfl(runName)
    fxptui.showdialog('noproposeddt');
    return;
end

% accepted checkbox
hasAccepted = false;

for i = 1:numel(totalResults)
    if totalResults(i).hasApplicableProposals
        hasAccepted = true;
        if totalResults(i).needsAttention
            % results require attention and checked accepted
            BTN_TEST = me.PropertyBag.get('BTN_TEST');
            btn = fxptui.showdialog('scaleapplyattention',BTN_TEST);
            lblYes = fxptui.message('btnIgnoreAlertAndApply');
            if strcmp(btn,lblYes)
                isProceedScaleApply = true;
            end
            % Proceed to apply if choose Yes; otherwise cancel apply if
            % choose Cancel (isProceedScaleApply remains false)
            return;
        end
    end
end


if hasAccepted
    isProceedScaleApply = true;
else    
    fxptui.showdialog('notacceptchecked');
end

    
    %---------------------------------------------------------------------------
    
    % [EOF]

