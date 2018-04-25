classdef FixedPointTool < handle
    % FixedPointTool singleton class that instantiates and maintains the Fixed-Point Tool application
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Constant,GetAccess=private)
        % Stores the class instance as a constant property
        Instance = fxptui.FixedPointTool;
    end
    
    properties(SetAccess = private, GetAccess = public)
        isReadyPostCallback = false;
    end
    
    properties(SetAccess = private, GetAccess=private)
        DebugURL = 'toolbox/fixedpoint/fixedpointtool/web/fixedpoint/fpt-debug.html';
        ReleaseURL = 'toolbox/fixedpoint/fixedpointtool/web/fixedpoint/fpt.html';
        SimStartPublishChannel;
        SimFailPublishChannel;
        WebWindow
        TreeController
        DataController
        StartupController
        WorkflowController
        ShortcutManager
        ResultInfoController
        GoalSpecifier
        ExternalViewer
        Model
        ModelObject
        Subscriptions
        InitialSelectedSystem
        Listener
        CloseModelListener
        SDIListeners
        SimStartListener
        SimFailedListener
        SimStopListener
        InitSDIRecordState
        RestoreSettingsListener
        CaptureOriginalSettings = false;
        ModelHierarchy
    end
    
    events
        UpdateSUDEvent
        FPTCloseEvent
        SimulationDataCompleteEvent
    end
    
    methods(Access=private)
        function this = FixedPointTool
            % Ensure the connector is on before subscribing. Connctor depends on java & jvm to work.
            if usejava('jvm')
                connector.ensureServiceOn;
            end
            sdiEngine = Simulink.sdi.Instance.engine();
            this.SDIListeners = event.listener(sdiEngine,'runAddedEvent',@(s,e) updateForTimeSeriesData(this, e));
        end
        
        function attachPostSaveCallback(this)
            % Register a callback on FPT Model Save as
            % Pass the replace_existing flag as input argument.If supplied and true
            % then any existing callback with the same type and ID will be replaced.
            
            Simulink.addBlockDiagramCallback(this.Model,'PostSave','FPTModelSaveAs',@()fxptui.launchFPTOnModelRename(this.ModelObject, this.Model), true);
        end
        
        function createApplication(this, debugPort)
            this.WebWindow = fxptui.Web.ApplicationFramework(this.ReleaseURL, this.constructTitle, debugPort);
            this.WebWindow.addCloseCallback(@(s,e)close(this));
        end
    end
    
    methods
        function updateData(this,opCode, varargin)
            this.DataController.updateData(opCode, varargin{:});
            addedTree = this.ModelHierarchy.getAddedTreeData;
            this.TreeController.sendAddedTree(addedTree);
        end
        
        function model = getModel(this)
            model = '';
            if ~isempty(this.WebWindow)
                model =  this.Model;
            end
        end
        
        function modelObj = getModelObject(this)
            modelObj = this.ModelObject;
        end
        
        function updateSelectedSystem(this, systemPath)
            this.InitialSelectedSystem = systemPath;
            % This call will not fail when launching FPT from the canvas
            % because we can only launch from subsystems.
            blk = get_param(systemPath, 'Object');
            this.setSystemForConversion(systemPath,class(blk));
        end
        
        function shortcutManager = getShortcutManager(this)
            shortcutManager = this.ShortcutManager;
        end
    end
    
    methods(Hidden)
        function spreadsheet = getDataController(this)
            spreadsheet = this.DataController;
        end
        
        function spreadsheet = getSpreadsheetController(this)
            spreadsheet = [];
            if isempty(this.DataController)
                return
            end
            spreadsheet = this.DataController.getSpreadsheetController;
        end
        
        function resultInfo = getResultInfoController(this)
            resultInfo = this.ResultInfoController;
        end
        
        function result = getSelectedResult(this)
            result = this.DataController.getSelectedResult;
        end
        
        function selectResultInUI(this, result)
            this.DataController.selectResult(result);
        end
        
        function selectTreeNodeInUI(this, treeObject)
            this.TreeController.selectTreeNode(treeObject);
        end
        
        function selectTreeAndThenResultInUI(this, treeObj, result)
            % If the block is not within the provided scope then we need to
            % select the parent tree node first and then the result
            this.DataController.setDelayedResultSelection(result);
            this.TreeController.selectTreeNode(treeObj);
        end
        
        function startupController = getStartupController(this)
            startupController = this.StartupController;
        end
        
        function workflow = getWorkflowController(this)
            workflow = this.WorkflowController;
        end
        
        function tree = getTreeController(this)
            tree = this.TreeController;
        end
        
        function externalViewer = getExternalViewer(this)
            externalViewer = this.ExternalViewer;
        end
        
        function url = getURL(this)
            url = this.WebWindow.getURL;
        end
        
        function port = getDebugPort(this)
            port = this.WebWindow.getDebugPort;
        end
        
        function show(this)
            this.WebWindow.showUI;
        end
        
        function reEnableUI(this, msg)
            % Re-enable the UI
            message.publish(this.SimFailPublishChannel, msg);
            this.enableCodeView(true);
        end
        
        function webWindow = getWebWindow(this)
            webWindow = this.WebWindow;
        end
        
        function deleteBlockDiagramCallbacks(this)
            %  Remove the callback registered on FPT Model 'Save as'
            if isa(this.ModelObject, 'Simulink.BlockDiagram')
                if this.ModelObject.hasCallback('PostSave','FPTModelSaveAs')
                    Simulink.removeBlockDiagramCallback(this.ModelObject.Handle,'PostSave','FPTModelSaveAs');
                end
            end
        end
        
        function enableCodeView(this, enable)
            this.ExternalViewer.updateGlobalEnabledState(enable);
        end
        
        function title = constructTitle(this)
            title = sprintf('%s - %s', fxptui.message('titleFPTool'),...
                fxptui.message('titleSUD',fxptui.removeLineBreaksFromName(this.getSystemForConversion)));
        end
        function setTitle(this, title)
            this.WebWindow.setTitle(title);
        end
    end
    
    methods(Access = private)
        initControllers(this, clientData);
        setModel(this, modelName);
        publishInitialData(this, clientData);
        deleteControllers(this);
        deleteListeners(this);
        deleteShortcutEditor(this);
        recordSignals(this);
        allDatasets = getAllDatasets(this);
        initSDIEngineListeners(this);
        deleteSDIEngineListeners(this);
        updateSUD(this, source, eventData);
        externalviewer = createExternalViewer(this);
        onModelClose(this);
        restoreIfSimNeverStarted(this);
    end
    
    methods
        open(this, debugPort);
        close(this);
        system = getSystemForConversion(this);
        modelHierarchy = getModelHierarchy(this);
    end
    
    methods(Hidden)
        isFPTOpen = isFPTLaunchedOnSameModel(this, modelObj);
        success = loadReferencedModels(this);
        postProcessSimulationData(this);
        updateForTimeSeriesData(this, eventData);
        restoreSystemSettings(this);
        applyIdealizedSettings(this);
        applyEmbeddedSettings(this);
        turnOnInstrumentationAndRestoreDirty(this);
        captureCurrentSystemSettings(this);
        triggerProposalFromCodeView(this);
        triggerApplyFromCodeView(this);
        result = getSelectedTreeNode(this);
        blkObj = setSystemForConversion(this, sysPath, objectClass);
        handleCompFailure(this);
    end
    
    methods (Static)
        instance = getExistingInstance;
        instance = getInstance(model);
        launch(system, debugMode);
    end
end

% LocalWords:  fixedpointtool fpt FP
