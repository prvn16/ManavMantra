function locRestore(h)
%LOCRESTORE restore the state of FPT

%   Copyright 2011-2015 The MathWorks, Inc.

wasBeingSimulated = false;
if strcmpi(h.status,'running') || strcmpi(h.status,'paused')
    wasBeingSimulated = true;
end
h.status = 'done';
h.restoreactionstate;
%restore the state of backtrace when the model stops running
state = h.userdata.warning.backtrace.state;
warning(state, 'backtrace')
% If there are proposals in any of the runs, leave the view as-as, don't take away the proposedDT fields.
existing_propDt = h.hasproposedfl;
if ~existing_propDt && wasBeingSimulated
    vm = h.getViewManager;
    if ~isempty(vm)
        hasDerived = h.hasDerivedMinMax;
        hasSim = h.hasSimMinMax;
        if hasDerived && hasSim
            simView = vm.getView(fxptui.message('labelViewDataCollection'));
            vm.SuggestedViewName = 'data_collection';
        elseif hasSim && ~hasDerived
            simView  = vm.getView(fxptui.message('labelViewSimulation'));
            vm.SuggestedViewName = 'sim_view';
        elseif hasDerived && ~hasSim
            simView = vm.getView(fxptui.message('labelViewDerivedMinMax'));
            vm.SuggestedViewName = 'derived_view';
        else
            simView  = vm.getView(fxptui.message('labelViewSimulation')); 
            vm.SuggestedViewName = 'sim_view';
        end
        if ~h.LockColumnView && ~isempty(simView)
            vm.ActiveView = simView;
        end
    end
end
% highlight overflows in results.
fxptui.cb_togglehighlight;

h.wake;

%update enabledness of dialog buttons
h.getTopNode.fireHierarchyChanged;
h.refreshDetailsDialog;

% Update the status of the record button when restoring the UI. This is triggered after data has been updated in the tool.
if ~isempty(h.initRecordState)
    sdiEngine = Simulink.sdi.Instance.engine();
    if strcmpi(h.initRecordState,'off')
        sdiEngine.stop;
    end
end

if wasBeingSimulated && fxptui.isMATLABFunctionBlockConversionEnabled()
    % Notify F2F and Code View (if open) that a simulation has completed
    % and run updating is complete.
    coder.internal.mlfb.gui.CodeViewUpdater.markSimCompleted();
end

%--------------------------------------------------------------------------

% [EOF]
