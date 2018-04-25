function cb_scalepropose(varargin)
%CB_SCALEPROPOSE

%   Copyright 2006-2016 The MathWorks, Inc.

if nargin > 0
    closeAction = varargin{2};
    if ~strcmpi(closeAction,'Ok') 
        return;
    end
end
me = fxptui.getexplorer;
if ~me.SelectedRunForProposal; return; end

bd =  me.getTopNode; 
if(~isa(bd, 'fxptui.ModelNode'))
	return;
end

topMdlName = bd.getDAObject.getFullName;
appData = SimulinkFixedPoint.getApplicationData(topMdlName);

treenode = initui(me, appData);
if(isempty(treenode)); return; end

% Clean up the diagnostic if it exists.
fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
if ~isempty(fpt_diagViewer)
    fpt_diagViewer.flushMsgs;
    fpt_diagViewer.Visible = false;
    delete(fpt_diagViewer);
end

topModelScaleSetting = appData.settingToStruct();
sudName = treenode.getDAObject.getFullName;
proposalSettings = topModelScaleSetting;

try
	engineContext = SimulinkFixedPoint.DataTypingServices.EngineContext(...
    topMdlName, ...
    sudName, ...
    proposalSettings, ...
    SimulinkFixedPoint.DataTypingServices.EngineActions.Propose);
    engineInterface = SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
    engineInterface.run(engineContext);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
       fxptui.showdialog('scaleproposefailed',fpt_exception);
    catch fpt_exception
       restoreui(me, treenode, appData);
       rethrow(fpt_exception);
    end
    restoreui(me, treenode, appData);
    return;
end


try
  SimulinkFixedPoint.ApplicationData.updateResultsInModelsBlocks(topMdlName, topModelScaleSetting.scaleUsingRunName);
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
       fxptui.showdialog('scaleproposefailed',fpt_exception);
    catch fpt_exception
       restoreui(me, treenode, appData);
       rethrow(fpt_exception);
    end
    restoreui(me, treenode, appData);
    return;
end

restoreui(me, treenode, appData);
setaccepton(me, appData);
if hasmarkedred(me, appData)
  fxptui.showdialog('scaleproposeattention');
end

me.ExternalViewer.typesProposed(treenode.getDAObject());

%--------------------------------------------------------------------------
function treenode = initui(me, appData)

treenode = [];
success = loadReferencedModels(me);
if ~success; return; end

mdl = me.getTopNode.getDAObject;
%apply changes before proposing data types
if(~isempty(me.imme.getDialogHandle)&& me.imme.getDialogHandle.hasUnappliedChanges)
    me.imme.getDialogHandle.apply;
end

% Issue a question dialog if the model is in non-normal mode. A user can choose to change it from the dialog.
if ~strcmpi(mdl.SimulationMode,'normal')
    BTN_TEST = me.PropertyBag.get('BTN_TEST');
    BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
    BTN_CANCEL = fxptui.message('btnCancel');
    btn = fxptui.showdialog('proposedtsimmodewarning', BTN_TEST);
    switch btn 
      case BTN_CHANGE_SIM_MODE
        set(mdl,'SimulationMode','normal');
      case BTN_CANCEL
        return;
      otherwise
    end
end

treenode = me.ConversionNode;

% If the selected node is an unsupported node for actions in a tree (state,
% mdlref block), then perform the action on the selected nodes' parent.
treenode = getSupportedParentTreeNode(treenode);
if isempty(treenode); return; end

if(~isDoScaling(treenode, appData))
  treenode = [];
  return;
end

%turn backtrace off while the model is running.
me.userdata.warning.backtrace = warning('backtrace');
warning('off', 'backtrace');
%disable all actions in the ui
me.setallactions('off');
%update selected system's dialog - we just disabled all actions
treenode.firePropertyChanged;
% Put the UI to sleep after updating the dialog.
me.sleep;
%suppress progressbar in BAT
if(~me.istesting)
  me.progressbar = fxptui.createprogressbar(me,fxptui.message('labelSCALEPROPOSEDT'));
end

%--------------------------------------------------------------------------
function restoreui(me, treenode, appData)
% update the list view based on filter selection
vm = me.getViewManager;
if ~isempty(vm)
      hasDerived = appData.AutoscalerProposalSettings.isUsingDerivedMinMax;
      hasSim = appData.AutoscalerProposalSettings.isUsingSimMinMax;
    if hasSim && hasDerived
        FPTView = vm.getView(fxptui.message('labelViewAutoscaling'));
        vm.SuggestedViewName = 'datatyping_view_data';
    elseif hasSim && ~hasDerived
        FPTView = vm.getView(fxptui.message('labelViewAutoscalingSimMinMax')); 
        vm.SuggestedViewName = 'datatyping_view_sim';
    elseif hasDerived && ~hasSim
        FPTView = vm.getView(fxptui.message('labelViewAutoscalingDerivedMinMax')); 
        vm.SuggestedViewName = 'datatyping_view_derived';
    else
        FPTView = vm.getView(fxptui.message('labelViewAutoscalingSimMinMax'));
        vm.SuggestedViewName = 'datatyping_view_sim';
    end
    if ~me.LockColumnView && ~isempty(FPTView)
        vm.ActiveView = FPTView;
    end
end
me.wake;
me.restoreactionstate;
me.updateactions;
me.refreshDetailsDialog;
fxptui.cb_togglehighlight;
treenode.fireHierarchyChanged;
state = me.userdata.warning.backtrace.state;
warning(state, 'backtrace');
if(~me.istesting && ~isempty(me.progressbar))
  me.progressbar.dispose;
end
beep;

%--------------------------------------------------------------------------
function setaccepton(me ,appData)
if(isempty(me)); return; end
results = me.getresults(appData.ScaleUsing);
if(isempty(results)); return; end

for r = 1:numel(results)
    results(r).updateAcceptFlag;
end

%--------------------------------------------------------------------------
function isDoScaling = isDoScaling(sys, aData)
isDoScaling = true;
me = fxptui.getexplorer;
if(isempty(me) || isempty(sys)); return; end
%if the user is attempting to scale against fixed point data, ask if that
%is really what they want to do. The normal workflow calls for scaling
%against floating point data.
results = sys.getChildren;
if(isempty(results)); return; end

if aData.AutoscalerProposalSettings.isUsingSimMinMax || aData.AutoscalerProposalSettings.isUsingDerivedMinMax
    numSimDT = 0;
    numDrvDT = 0;
    numFixdt = 0;
    
    for r = 1:numel(results)
        runName = results(r).getRunName;
        if ~isequal(runName,aData.ScaleUsing)
            continue; 
        end
        
        if results(r).hasCompiledDT          
            if aData.AutoscalerProposalSettings.isUsingSimMinMax
                numSimDT = numSimDT + 1;
            end
            if aData.AutoscalerProposalSettings.isUsingDerivedMinMax
                numDrvDT = numDrvDT + 1;
            end
            if(results(r).hasFixedDT)
                numFixdt = numFixdt + 1;
            end
        end
    end
 

    % Warn if attempting to propose scaling using fixed point data.
    % It would be reasonable for a floating point model to contain
    % some small used of fixed-point/integer.  To limit "false positive"
    % warnings, the arbitrary threshold of 4% is used.
    % If more than 4% of the data types logging min/max are fixed-point
    % or integer then warn.
    
    if numFixdt > ( 0.04 * numSimDT ) || numFixdt > ( 0.04 * numDrvDT )
        
        btn = fxptui.showdialog('scalingfixdt');
        lblNo = fxptui.message('labelNo');
        if(isempty(btn) || strcmp(lblNo, btn))
            isDoScaling = false;
        else
            isDoScaling = true;
        end
    end
end

%--------------------------------------------------------------------------
function b = hasmarkedred(me, appData)
b = false;
results = me.getresults(appData.ScaleUsing);
if(isempty(results)); return; end
for i = 1:numel(results)
    alerts = results(i).getAlert;
    if strcmp('red', alerts)
        b = true;
        return;
    end
end

% [EOF]
