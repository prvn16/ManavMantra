function cb_simulation(action)
% SIMULATION

%   Copyright 2006-2012 The MathWorks, Inc.

persistent BTN_SIM;
persistent BTN_CANCEL;
me = fxptui.getexplorer;
bd = me.getTopNode; 

if(~isa(bd, 'fxptui.ModelNode'))
	return;
end
mdl = bd.getDAObject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end

% Issue a question dialog if the model is in non-normal mode. A user can
% choose to change it from the dialog.
if (~strcmpi(get_param(mdl.getFullName,'SimulationMode'),'normal') && isLoggingEnabled(bd)  && strcmpi(get_param(mdl.getFullName,'SimulationStatus'),'stopped'))
    BTN_TEST = me.PropertyBag.get('BTN_TEST');
    BTN_CHANGE_SIM_MODE = fxptui.message('btnChangeSimModeAndContinue');
    BTN_CANCEL = fxptui.message('btnCancel');
    btn = fxptui.showdialog('simmodewarning', BTN_TEST);
    switch btn 
      case BTN_CHANGE_SIM_MODE
        set_param(mdl.getFullName,'SimulationMode','normal');
      case BTN_CANCEL
        return;
      otherwise
    end
end

if(~isempty(me.imme.getDialogHandle) && me.imme.getDialogHandle.hasUnappliedChanges)
    me.imme.getDialogHandle.apply;
end
run = mdl.FPTRunName;

if ~isempty(run)
    % % Check if the active run has any proposedFLs
    if me.hasproposedfl(run) && me.hasunacceptedfl(run) && strcmpi(get_param(mdl.getFullName,'SimulationStatus'),'stopped')
        if isempty(BTN_SIM)
            BTN_SIM = fxptui.message('btnIgnoreandSimulate');
        end
        if isempty(BTN_CANCEL)
            BTN_CANCEL = fxptui.message('btnCancel');
        end
        BTN_TEST = me.PropertyBag.get('BTN_TEST');
        btn = fxptui.showdialog('ignoreproposalsandsimwarning', mdl.FPTRunName, BTN_TEST);
        if ~strcmp(btn,BTN_SIM)
            return;
        end
    end
end
switch action
  case 'start',
    if strcmpi(get_param(mdl.getFullName,'SimulationStatus'), 'paused'),
        cmd = 'continue';
    else
        cmd = 'start';
    end
  case 'pause',
    cmd = 'pause';
  case 'stop'
    cmd = 'stop';
end
try
    fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
    if ~isempty(fpt_diagViewer)
        fpt_diagViewer.flushMsgs;
        fpt_diagViewer.Visible = false;
        delete(fpt_diagViewer);
    end
    %G385962 - avoid seg-v when running sim in external mode
    if(~strcmpi(get_param(mdl.getFullName,'SimulationMode'), 'External'))
  	set_param(mdl.Name, 'simulationcommand', cmd);
    end
catch e %#ok
    me.restoreactionstate;
end

%---------------------------------------------------
function b = isLoggingEnabled(root)
bd = root.getDAObject;
if ~strcmpi(get_param(bd.getFullName,'MinMaxOverflowLogging'),'UseLocalSettings') && ~strcmpi(get_param(bd.getFullName,'MinMaxOverflowLogging'),'ForceOff')
    b = true;
    return;
else
    % Find all subsystems under the root model
    ch = find(bd,'-isa','Simulink.SubSystem');
    b = ~isempty(ch.find({'MinMaxOverflowLogging','MinMaxAndOverflow'},'-or',{'MinMaxOverflowLogging','Overflow'}));
end

%--------------------------------------------------
        
        



% [EOF]
