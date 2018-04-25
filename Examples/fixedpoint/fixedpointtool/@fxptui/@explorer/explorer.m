function h = explorer(varargin)
% EXPLORER constructor
%

%   Copyright 2006-2017 The MathWorks, Inc.

%persistent FPTPersistentRoot;
mdlname = '';
%keep track of the incoming sleep state. it will be true if called while
%demo is loading and if the ui was closed from the file menu or 'x'
if nargin > 0
    mdlname = varargin{1};
end
h = fxptui.getexplorer;
%if an instance of explorer exists and no args were passed return this
%instance (mimic a singleton pattern)
if(isempty(mdlname) && ~isempty(h))
    return;
end


%if explorer doesn't exist create one
if(isempty(h))
    title = sprintf('%s %s',fxptui.message('labelInitializeFPT'),...
        fxptui.message('titleFPTool'));
    %create a dataset for this explorer (backend)
    %create tree with the model at root
    root = fxptui.ExplorerRoot(mdlname);
    
    %create a fxptui.explorer(ROOT, TITLE, SHOW?)
    h = fxptui.explorer(root, fxptui.message('titleFPTool'), 0);
    
    %Only proceed if the Explorer was constructed successfully.
    if isa(h,'DAStudio.Explorer')        
        pb = fxptui.createprogressbar(title);
        
        % Add the new root to map to prevent destruction of node due to cycle
        if isempty(h.RootNode)
            h.RootNode = Simulink.sdi.Map(char('a'), '?handle');
            h.RootNode.insert(mdlname, root);
        else
            h.RootNode.insert(mdlname, root);
        end
        
        % create a ResultInfoController object
        if(isempty(h.ResultInfoController))
            h.ResultInfoController = fxptui.Web.ResultInfoController;
        end
        
        h.GoalSpecifier = fxptui.ConversionGoals(mdlname);
        initializeStartup(h, mdlname);

        %create a place to store results (UI)
        h.userdata.warning.backtrace.state = '';
        h.PropertyBag = java.util.HashMap;
        
        if fxptui.isMATLABFunctionBlockConversionEnabled()
            h.ExternalViewer = fxptui.CodeViewExternal;
        else
            h.ExternalViewer = fxptui.ExternalViewer;
        end
        
        initShortcutMaps(h);
        loadCustomshortcuts(h);
        
        % Add custom property names for the properties
        locAddCustomPropNames(h);
        
        %build UI
        creatui(h);
        
        %if  explorer exists and the model == root, return
        %listen for the explorer being closed via command line i.e.: delete(me)
        h.listeners(end+1) = handle.listener(h, 'ObjectBeingDestroyed', @(s,e)destroy(h));
        h.listeners(end+1) = handle.listener(h,'METreeSelectionChanged',@(s,e) locUpdateListView(h, e));
        % Update dialog view if a group node is selected.
        h.listeners(end+1) = handle.listener(h,'MEListSelectionChanged',@(s,e) locUpdateDialogView(h,e));
        h.listeners(end+1) = handle.listener(h,'MEPostShow', @(s,e)selectNode(h));
        h.PostHideListener = handle.listener(h, 'MEPostClose', @(s,e)cleanup(h));
        
        initSDIEngineListeners(h);
        
        %add listeners to new root
        addrootlisteners(h);
        hupdatedata(h);
        syncstatuswithengine(h);
        
        % load preferences
        loadPreferenceSettings(h);
        
        pb.dispose;
    end
elseif(strcmpi(h.getTopNode.getDAObject.getFullName, mdlname))
    hupdatedata(h);
    syncstatuswithengine(h);
    %if  explorer exists and the model != root, swap out the root
else
    oldModelName = h.getTopNode.getDAObject.getFullName;
    title = sprintf('%s %s',fxptui.message('labelInitializeFPT'),...
        fxptui.message('titleFPTool'));
    pb = fxptui.createprogressbar(title);
    newroot = locChangerootui(h,mdlname);
    % Add the new root to map to prevent destruction of node due to cycle
    % detection.
    h.RootNode.insert(mdlname, newroot);
    if h.RootNode.isKey(oldModelName)
        h.RootNode.deleteDataByKey(oldModelName);
    end
    
    pb.dispose;
    h.isSUDVerified = false;
    h.DeriveChoice = 0;
    h.GoalSpecifier = fxptui.ConversionGoals(mdlname);
    h.ConversionNode = [];
    % Force cleanup of the previous object to cleanup any open dialogs
    delete(h.sudlisteners);
    h.sudlisteners = [];
    delete(h.StartupObj);
    initializeStartup(h, mdlname);
end

%--------------------------------------------------------------------------
function syncstatuswithengine(h)
enginestatus = h.getTopNode.getDAObject.SimulationStatus;
switch enginestatus
    case 'running'
        locStart(h);
        locContinue(h);
    case 'paused'
        locPause(h);
    case 'compiled'
        % This status is for Fast Restart
        locCompiled(h);
    otherwise
end

%--------------------------------------------------------------------------
function locInit(h)
if(~strcmp('done', h.status)); return; end

%apply changes on the FPT dialog before running the simulation
if(~isempty(h.imme.getDialogHandle) && h.imme.getDialogHandle.hasUnappliedChanges)
    h.imme.getDialogHandle.apply;
end

% --------------------------------------------------------------------------
function locStart(h)
try
    h.HasCompletedDataCollection = false;
    %set explorer status to running
    h.status = 'starting';
    %turn backtrace off while the model is running.
    bState = warning('backtrace');
    % If it is already off, then don't do anything.
    if ~strcmpi(bState.state,'off')
        h.userdata.warning.backtrace = bState;
        warning('off', 'backtrace')
    end
    % Initiate SDI record only if Signal logging is turned on & FPT
    % window is open.
    if strcmpi(get_param(h.getTopNode.getDAObject.getFullName,'SignalLogging'),'on') && h.isVisible
        % Turn on the record button on the Simulation data inspector to capture timeseries data.
        if h.reAttachSDIListeners
            initSDIEngineListeners(h);
        end
        sdiEngine = Simulink.sdi.Instance.engine();
        if ~Simulink.sdi.Instance.record
            h.initRecordState = 'off';
            sdiEngine.record;
        end
    else
        deleteSDIEngineListeners(h);
    end
    
    %     % Set a flag that is used to check if the function nodes for a MLFB was
    %     % added to the tree
    %     h.WasTreeUpdatedWithMLFunctions = false;
    
    % This callback is triggered when range analysis is triggered. Since we
    % have already captured the state of the actions, don't do it again.
    % This will corrupt the initial state that was captured.
    % turn off all menu and toolbar actions except pause and stop
    h.setallactions('off');
    % Pause/Stop button is disabled for external mode
    if ~strcmpi('external',h.getTopNode.getDAObject.SimulationMode)
        h.getaction('PAUSE').Enabled = 'on';
        h.getaction('STOP').Enabled = 'on';
    end
    
    % Clean up simulation based results in FPT.
    allDS = h.getAllDatasets;
    for i = 1:length(allDS)
        runObj = allDS{i}.getRun(get_param(h.getTopNode.getDAObject.getFullName,'FPTRunName'));
        isMerge = strcmpi(get_param(h.getTopNode.getDAObject.getFullName,'MinMaxOverflowArchiveMode'),'Merge');
        runObj.cleanupOnSimulation(isMerge);
    end
    
    %update enabledness of dialog buttons
    node = h.getSelectedTreeNode;
    if(isa(node, 'fxptui.SubsystemNode'))
        node.firePropertyChanged;
    end
catch fpt_exception
    h.status = 'done';
    rethrow(fpt_exception);
end

%-----------------------------------------------------------------------
function locPause(h)
switch h.status
    case 'running'
        h.status = 'paused';
        h.getaction('START').Enabled = 'on';
        h.getaction('PAUSE').Enabled = 'off';
        h.getaction('STOP').Enabled = 'on';
    otherwise
end

%-----------------------------------------------------------------------
function locCompiled(h)
switch h.status
    case 'running'
        h.status = 'paused';
        h.getaction('START').Enabled = 'on';
        h.getaction('PAUSE').Enabled = 'off';
        h.getaction('STOP').Enabled = 'on';
    otherwise
end
% The model is in initialized in Fast Restart. Warn the user about absence of min/max data
fxptui.showdialog('hotrestartwarning');


%--------------------------------------------------------------------------
function locContinue(h)
switch h.status
    case {'done'}
        h.status = 'running';
        h.setallactions('off');
        h.getaction('START').Enabled = 'off';
        if(strcmp('SIM', h.getTopNode.getDAObject.ModelReferenceTargetType))
            h.getaction('PAUSE').Enabled = 'off';
            h.getaction('STOP').Enabled = 'off';
        else
            h.getaction('PAUSE').Enabled = 'on';
            h.getaction('STOP').Enabled = 'on';
        end
        
    case {'starting', 'paused'}
        h.status = 'running';
        h.getaction('START').Enabled = 'off';
        if(strcmp('SIM', h.getTopNode.getDAObject.ModelReferenceTargetType))
            h.getaction('PAUSE').Enabled = 'off';
            h.getaction('STOP').Enabled = 'off';
        else
            h.getaction('PAUSE').Enabled = 'on';
            h.getaction('STOP').Enabled = 'on';
        end
    otherwise
end

%--------------------------------------------------------------------------
function locTerminating(h)
if(~strcmpi('normal', h.getTopNode.getDAObject.SimulationMode)); return; end
if (strcmpi('running',h.status) || strcmpi('paused',h.status))
    h.sleep;
else
    return;
end

%--------------------------------------------------------------------------
function locStop(h)

%  restore the state of backtrace when the model stops running
state = h.userdata.warning.backtrace.state;
warning(state, 'backtrace')

% If not in 'Normal' simulation mode, don't update data - just reset the state of the sim buttons.
if ~h.isBeingDerived && (~strcmpi('normal', h.getTopNode.getDAObject.SimulationMode))
    switch h.status
        case {'running','paused'}
            h.getaction('STOP').Enabled = 'off';
            h.getaction('START').Enabled = 'on';
            h.getaction('PAUSE').Enabled = 'off';
        otherwise
    end
end
%if something caused this to get called other than what we expected ignore
%it. ex: when autoscaling runs, this callback gets invoked while it is
%running and causes data corruption and action state problems.
switch h.status
    case 'compfailed'
        %if the model doesn't compile restore state and return
        locRestore(h);
        beep;
    otherwise
end

%--------------------------------------------------------------------------
function locCompFailed(h)
%if(~strcmp('normal', h.getRoot.getDAObject.SimulationMode)); return; end
if(~strcmp('running', h.status))
    return;
end
h.status = 'compfailed';

%--------------------------------------------------------------------------
function newroot = locChangerootui(h,mdlname)
% Set the root of the FPT to the new model.

% Reset a flag that is used to check if the function nodes for a MLFB was
% added to the tree
h.WasTreeUpdatedWithMLFunctions = false;

% Change the root
oldroot = h.getFPTRoot;

newroot =  fxptui.ExplorerRoot(mdlname);
h.setRoot(newroot);

% Delete listeners attached to the old root
idx = [];
appData = SimulinkFixedPoint.getApplicationData(oldroot.getDAObject.getFullName);
for i = 1:numel(h.listeners)
    if isequal(h.listeners(i).SourceObject,oldroot.getDAObject) || ...
            isequal(h.listeners(i).Container, appData)
        delete(h.listeners(i));
        idx = [idx i];        %#ok<AGROW>
    end
end
h.listeners(idx) = [];

delete(h.DatasetListener);
h.DatasetListener = [];

% % Unpopulate after setting the newroot - G469179
oldroot.unpopulate;
resetShortcutMapForModel(h);
loadCustomshortcuts(h);
%add listeners to new root
addrootlisteners(h);
hupdatedata(h);
syncstatuswithengine(h);
if ~isempty(h.BAExplorer)
    changeRoot(h.BAExplorer, mdlname);
end

% Close the diagnostic viewer if it exists
fpt_diagViewer = DAStudio.DiagViewer.findInstance('FPTDiagnostics');
if ~isempty(fpt_diagViewer)
    fpt_diagViewer.Visible = false;
end

%--------------------------------------------------------------------------
function addrootlisteners(h)
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimulationStart',  @(s,e)locStart(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusInitializing',  @(s,e)locInit(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusTerminating',  @(s,e)locTerminating(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusRunning',  @(s,e)locContinue(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusPaused',  @(s,e)locPause(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusCompiled',  @(s,e)locCompiled(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineSimStatusStopped',  @(s,e)locStop(h));
h.listeners(end+1) = handle.listener(h.getTopNode.getDAObject, 'EngineCompFailed',  @(s,e)locCompFailed(h));

%-------------------------------------------------------------------------
function locAddCustomPropNames(h)

h.addPropDisplayNames({...
    'OverflowWrap','OverflowWraps',...
    'OverflowSaturation', 'Saturations',...
    'InitialValueMin','InitValueMin',...
    'InitialValueMax','InitValueMax',...
     });


%-------------------------------------------------------------------------
function locUpdateListView(h,ev)
% Update list view for filter selection when tree node selection is
% changed.

node = ev.EventData;
if isa(ev.EventData,'DAStudio.DAObjectProxy')
    node = ev.EventData.getMCOSObjectReference;
end
if isa(node, 'fxptui.ModelReferenceNode')
    loadReferencedModels(h);
end

if strcmp(h.status, 'done')
    % when the model is still running, no need to update
    h.updateactions;
end

%-----------------------------------------------------------------------
function locUpdateDialogView(h, event)
% Update the dialog view when a group node is selected.

if isa(event.EventData,'DAStudio.Group')
    h.replaceDialog(h.imme.getCurrentTreeNode);
end
refreshDetailsDialog(h);


%------------------------------------------------------------------------
function initSDIEngineListeners(h)
% Add listener on the global SDI engine for time-series data.

sdiEngine = Simulink.sdi.Instance.engine();
h.SDIListeners = event.listener(sdiEngine,'runAddedEvent',@(s,e) updateForTimeSeriesData(h, e));
h.reAttachSDIListeners = false;

%-------------------------------------------------------------------------
function deleteSDIEngineListeners(h)
% Add listener on the global SDI engine for time-series data.

if ~isempty(h.SDIListeners)
    delete(h.SDIListeners);
    h.SDIListeners = [];
end
h.reAttachSDIListeners = true;

%-------------------------------------------------------------------------
function selectNode(h)
% Select the Top node and expand it once the explorer is shown.

selectedNode = h.getSelectedTreeNode;
if isempty(selectedNode) || isa(selectedNode,'fxptui.ExplorerRoot')
    h.imme.selectTreeViewNode(h.getTopNode);
    h.imme.expandTreeNode(h.getTopNode);
end

%-------------------------------------------------------------------------
function loadPreferenceSettings(h)

preferenceFile = fullfile(prefdir, 'fixedpointtoolprefs.mat');
% If the file and variable exist, then  load it in, else default to false
lockAction = h.getaction('VIEWMANAGER_LOCK');
if exist(preferenceFile, 'file')
    existStatus = whos('-file', preferenceFile, 'LockColumnView');
    if ~isempty(existStatus)
        outputStruct = load(preferenceFile, 'LockColumnView');
        if outputStruct.LockColumnView
            lockAction.on = 'on';
        else
            lockAction.on = 'off';
        end
    else
        lockAction.on = 'off';
    end
else
    lockAction.on = 'off';
end

%-------------------------------------------------------------------------
function initializeStartup(h, mdlname)

h.StartupObj = fxptui.Startup(mdlname);
h.sudlisteners = addlistener(h.StartupObj, 'SUDChangedEvent', @(s,e)updateSUD(h, e));

%-------------------------------------------------------------------------
function updateSUD(h, evData)
% Update the SUD for the application

data = evData.getData;
h.isSUDVerified = true;
h.setSystemForConversion(data.SUD, data.ObjectClass);


% [EOF]
