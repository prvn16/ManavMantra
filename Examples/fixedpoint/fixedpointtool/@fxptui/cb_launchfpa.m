function cb_launchfpa
%CB_LAUNCHFPA

%   Copyright 2006-2015 The MathWorks, Inc.

b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicensefpa');
    return; 
end

me = fxptui.getexplorer;
treenode = initui(me);
if(isempty(treenode)); return; end

try
  fpcadvisor(treenode.getDAObject.getFullName);
catch fpa_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
       fxptui.showdialog('launchfpafailed',fpa_exception);
    catch fpa2_exception
       restoreui(me, treenode);
       rethrow(fpa2_exception);
    end
    restoreui(me, treenode);
    return;
end
restoreui(me, treenode);

%--------------------------------------------------------------------------
function supportedNode = initui(me)

success = loadReferencedModels(me);
if ~success; supportedNode = [];return; end

    treenode = me.ConversionNode;
    supportedNode = getSupportedParentTreeNode(treenode);
% If the selected node is an unsupported node for actions in a tree (state,
% mdlref block), then perform the action on the selected nodes' parent.

if isempty(supportedNode); return; end

% MATLABFunction block is supported for all actions other than FPA
if isa(supportedNode, 'fxptui.MATLABFunctionBlockNode')
    isSupported = false;
    parent = supportedNode.DAObject;
    while ~isa(parent,'Simulink.BlockDiagram') && ~isSupported
        parent = supportedNode.DAObject.getParent;
        switch class(parent)
            case {'Stateflow.EMChart',...
                    'Stateflow.Chart', ...
                    'Stateflow.LinkChart', ...
                    'Stateflow.TruthTableChart', ...
                    'Stateflow.ReactiveTestingTableChart', ...
                    'Stateflow.StateTransitionTableChart'}
                parent = parent.up;
            otherwise
        end
        supportedNode = me.getFPTRoot.findNodeInCompleteHierarchy(parent);
        isSupported = supportedNode.isNodeSupported;
    end

end

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
treenode.firePropertyChanged;
% Put the UI to sleep after updating the dialog.
me.sleep;

%--------------------------------------------------------------------------
function restoreui(me, treenode)

me.wake;
me.restoreactionstate;
me.updateactions;
treenode.firePropertyChanged;
state = me.userdata.warning.backtrace.state;
warning(state, 'backtrace');
beep;

% [EOF]
