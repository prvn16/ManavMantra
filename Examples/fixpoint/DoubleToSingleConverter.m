classdef DoubleToSingleConverter < handle
    % DOUBLETOSINGLECONVERTER singleton class that instantiates and maintains the Double to single converter application
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Constant,GetAccess=private)
        % Stores the class instance as a constant property
        Instance = DoubleToSingleConverter;
    end
    
    properties(SetAccess = private, GetAccess=private)
        URL = 'toolbox/fixedpoint/fixedpointtool/web/single/index.html';
        WebWindow
        StartupController
        ConvertController
        Model
        Subscriptions
        InitialSelectedSystem
        GoalSpecifier
        Listener
        ConversionProcessDone = false;
        CloseModelListener
        ModelHierarchy
    end
    
    methods (Static)
        function obj = getExistingInstance
            obj =  DoubleToSingleConverter.Instance;
            if isempty(obj.Model)
                obj = [];
            end
        end
        
        function obj = getInstance(model)
            % Returns the stored instance of the repository.
            if nargin < 1
                [msg, identifier] = fxptui.message('incorrectInputArgsModel');
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            if nargin > 0
                sys = find_system('type','block_diagram','Name',model);
                if isempty(sys)
                    [msg, identifier] = fxptui.message('modelNotLoaded',model);
                    e = MException(identifier, msg);
                    throwAsCaller(e);
                end
            end
            obj = DoubleToSingleConverter.Instance;
            obj.Subscriptions{1} = message.subscribe('/singleconverter/ready',@(data)obj.initControllers(data));
            obj.GoalSpecifier = fxptui.ConversionGoals(model);
            obj.setModel(model);
        end
        
           function launch(system, debug)
            
            if nargin < 2
                debug = false;
            end


            model = bdroot(system);
            converterInstance = DoubleToSingleConverter.getExistingInstance;
            if isempty(converterInstance)
                createInstance = true;
            elseif ~strcmpi(converterInstance.getModel, model)
                close(converterInstance);
                createInstance = true;
            else
                createInstance = false;
            end
            
            if createInstance
                converterInstance = DoubleToSingleConverter.getInstance(model);
            end
            blk = get_param(system, 'Object');
            converterInstance.loadReferencedModels;
            currentSystemForConversion = converterInstance.getSystemForConversion;
            if isa(blk,'Simulink.ModelReference')
                % Point to the referenced model if the model block is intended to
                % be the SUD. If not, retain the model block selection.
                if isempty(currentSystemForConversion)
                    selectedSystem = blk.ModelName;
                else
                    selectedSystem = blk.getFullName;
                end
                
            else
                [b, maskedSubsys] = fxptui.isUnderMaskedSubsystem(blk);
                if b
                    selectedSystem = maskedSubsys.getFullName;
                else
                    selectedSystem = blk.getFullName;
                end
            end
            
            if isempty(currentSystemForConversion)
                converterInstance.setSystemForConversion(selectedSystem,class(blk));
            end
            
            converterInstance.updateSelectedSystem(selectedSystem);
            
            if debug
                debugPort = matlab.internal.getOpenPort;
                converterInstance.open(debugPort);
            else
                converterInstance.open;
            end

        end
        
        function convertSystem
            % The scope of the conversion i.e., the SUD has already been
            % set on the Engine at this point.
            converterInstance = DoubleToSingleConverter.getExistingInstance;
            converterInstance.resetConversionStatus;
            DataTypeWorkflow.Single.Engine.getInstance.run(converterInstance.getSystemForConversion);
            converterInstance.setConversionStatus(true);
        end
        
        function highlightBlockWithIdentifier(uniqueIDString, objectClass)
            [~, blockObject] = fxptds.getBlockPathFromIdentifier(uniqueIDString, objectClass);
            if ~isempty(blockObject)
                Simulink.ID.hilite(Simulink.ID.getSID(blockObject));
            end
        end
    end
    
    methods(Access=private)
        function this = DoubleToSingleConverter
            % Ensure the connector is on before subscribing
            connector.ensureServiceOn;
            mlock;
        end
        
        function initControllers(this, clientData)
            if ~isempty(this.StartupController)
                this.deleteControllers
            end
            this.StartupController = fxptui.Web.StartupController(clientData.startupTreeUniqueID, this.ModelHierarchy);
            this.ConvertController = single.Web.SingleConverterController;
            this.Listener = addlistener(this.StartupController,'SUDChangedEvent',@this.updateSUD);
            this.StartupController.updateSelectedSystem(this.InitialSelectedSystem);
            this.setModel(this.Model);
            this.StartupController.publishData(clientData);
        end
        
        function setModel(this, modelName)
            this.Model = modelName;
            bdObj = get_param(modelName, 'Object');
            delete(this.CloseModelListener);
            this.CloseModelListener = handle.listener(bdObj, 'CloseEvent', @(s,e)close(this));
            this.ModelHierarchy = fxptui.ModelHierarchy(modelName);
            this.ModelHierarchy.captureHierarchy;
            if ~isempty(this.StartupController)
                this.StartupController.setModel(modelName);
            end
        end
        
        function loadReferencedModels(this)
            try
                [refMdls, ~] = find_mdlrefs(this.Model);
                if numel(refMdls) == 1 % only listed root model
                    return;
                end
            catch mdl_not_found_exception % Model not on path.
                [msg, identifier] = fxptui.message('msgModelNotFoundError', mdl_not_found_exception.message);
                e = MException(identifier, msg);
                throwAsCaller(e);
            end
            
            for idx = 1:(length(refMdls)-1)
                refMdlName = refMdls{idx};
                load_system(refMdlName);
            end
        end
    end
    
    methods
        function open(this, debugPort)
            if isempty(this.WebWindow)
                if nargin < 2
                    debugPort = 0;
                end
                this.createApplication(debugPort);
            else
                if nargin > 1
                    if ~isequal(debugPort, this.WebWindow.getDebugPort)
                        delete(this.WebWindow);
                        this.createApplication(debugPort);
                    end
                end
            end
            this.WebWindow.openUI;
        end
        
        function close(this)
            this.deleteControllers;
            delete(this.WebWindow);
            this.WebWindow = [];
            this.Model = '';
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
        end
        
        function model = getModel(this)
            model =  this.Model;
        end
        
        function updateSelectedSystem(this, systemPath)
            this.InitialSelectedSystem = systemPath;
            this.GoalSpecifier.setSystemForConversion(get_param(systemPath, 'Object'));
        end
        
        function system = getSystemForConversion(this)
            system = '';
            systemObj = this.GoalSpecifier.getSystemForConversion;
            if ~isempty(systemObj)
                system = systemObj.getFullName;
            end
        end
    end
    
    methods(Hidden)
        function spreadsheet = getStartupController(this)
            spreadsheet = this.StartupController;
        end
        
        function blkObj = setSystemForConversion(this, sysPath, objectClass)
            if ~strncmpi(objectClass,'Stateflow',9)
                blkObj = get_param(sysPath, 'Object');
            else
                blkObj = fxptui.getStateflowChartFromPath(sysPath);
                % The above can return more than one object with the same path, for
                % example, a wrapping Simulink.Subsystem and a stateflow object.
                % We'll use the first object to make the selection.
                if ~isempty(blkObj)
                    blkObj = blkObj(1);
                end
            end
            this.GoalSpecifier.setSystemForConversion(blkObj);
        end
        
        function resetConversionStatus(this)
            this.ConversionProcessDone = false;
        end
        
        function setConversionStatus(this, status)
            if ~islogical(status)
                [msg, id] = fxptui.message('incorrectInputType','logical',class(status));
                throw(MException(id, msg));
            end
            this.ConversionProcessDone = status;
        end
        
        function status = getConversionStatus(this)
            status = this.ConversionProcessDone;
        end
        
        function url = getURL(this)
            url = this.WebWindow.getURL;
        end
        
        function port = getDebugPort(this)
           port = this.WebWindow.getDebugPort;
       end
    end
    
    methods (Access=private)
        function deleteControllers(this)
            delete(this.StartupController);
            this.StartupController = [];
            delete(this.ConvertController);
            this.ConvertController = [];
            delete(this.CloseModelListener);
            this.CloseModelListener = [];
        end
        
        function createApplication(this, debugPort)
            this.WebWindow = fxptui.Web.ApplicationFramework(this.URL, DAStudio.message('SimulinkFixedPoint:singleconverter:titleSingleConverter'), debugPort);
            this.WebWindow.addCloseCallback(@(s,e)close(this));
        end
        
        function updateSUD(this, ~, eventData)
            data = eventData.getData;
            this.setSystemForConversion(data.SUD, data.ObjectClass);
        end
        
    end      
end
