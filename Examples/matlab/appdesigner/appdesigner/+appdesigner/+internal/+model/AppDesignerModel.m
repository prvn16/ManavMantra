classdef  AppDesignerModel < ...
        appdesigner.internal.model.AbstractAppDesignerModel &...
        appdesservices.internal.interfaces.model.ParentingModel
        
    % The "Model" class of appdesinger
    %
    % This class is responsible for holding onto all open AppModels.
    %
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties( GetAccess=public, SetAccess=private)
        % a map of all component adapters registered in the Design
        % Environment.  The keys in the map are component's type
        % (including package info) and the value is that component type's
        % adapter name
        % For example:
        %   key = 'matlab.ui.control.Lamp'
        %   value = appdesigner.internal.componentadapter.uicomponents.adapter.LampAdapter
        ComponentAdapterMap
        
        % the PeerModelManager
        PeerModelManager
    end
    
    properties (Access = private, Transient = true)        
        % listener on the PeerModelManager's rootSet event
        % so the AppDesignerModel object can create ProxyView and Controller
        % appropriately
        PeerModelRootSetListener
        
        % Queue of apps to open
        AppsToOpen = {};
        
        %
        CreateNewAppWhenControllerReady = false;
        TutorialToOpenWhenControllerReady = '';
    end
    
    properties (GetAccess = private, ...
                SetAccess = ?appdesigner.internal.application.AppDesignEnvironment, ...
                Transient = true)
        % App, if any, that is loaded when App Designer is started
        InitialLoadingApp
    end

    methods
         function obj = AppDesignerModel(componentAdapterMap, peerModelManager)
             
             % validate the input arg
             validateattributes(componentAdapterMap, ...
                 {'containers.Map'}, ...
                 {});
             
             % save the Map
             obj.ComponentAdapterMap = componentAdapterMap;                 
             
             % save peerModelManager and 
             % listen to event when the client's root peer node has been 
             % created to create Controller and ProxyView accordingly
             obj.PeerModelManager = peerModelManager;
             obj.PeerModelRootSetListener = addlistener(peerModelManager, ...
                 'rootSet',@(src,event)obj.handlePeerModelRootSet(event));
         end
         
         function delete(obj)
             
             delete@appdesigner.internal.model.AbstractAppDesignerModel(obj);
             delete@appdesservices.internal.interfaces.model.ParentingModel(obj);
             
             delete(obj.PeerModelRootSetListener);
         end
         
         function openApp(obj, filePath)
             if ~isempty(obj.Controller)
                 % When PeerModel manager root not set, Controller will not
                 % be created, which means AppDesigner client is not fully
                 % loaded
                 obj.Controller.ProxyView.sendEventToClient( ...
                    'openAppModel', {'FilePath', filePath});
             else
                 % if AppDesigner client is not fully started, put the file
                 % path of app into the to open queue, which will be
                 % handled one by one when client is ready
                 
                 % The initial loading app does not need to be queued and 
                 % so don't want to add it to the queue. Also don't add to 
                 % the queue an app that is already in the queue.
                 if isempty(obj.InitialLoadingApp) || ... 
                    (~any(strcmpi(filePath, obj.AppsToOpen)) && ...
                    ~strcmpi(filePath, obj.InitialLoadingApp))
                
                    obj.AppsToOpen{end+1} = filePath;
                 end
             end
         end
         
         function createNewApp(obj)
             if ~isempty(obj.Controller)
                 obj.Controller.ProxyView.sendEventToClient('createNewAppModel', {});
             else
                 % App Designer is not fully started and so cache that a 
                 % new app needs to be created once the peer model root has
                 % been set and the Controller has been created.
                 obj.CreateNewAppWhenControllerReady = true;
             end
         end
         
         function openTutorial(obj, tutorialName)
             if ~isempty(obj.Controller)
                 obj.Controller.ProxyView.sendEventToClient('openTutorial', {'TutorialName', tutorialName});
             else
                 % App Designer is not fully started and so cache the 
                 % tutorial that nees to be opened once the peer model root 
                 % has been set and the Controller has been created.
                 obj.TutorialToOpenWhenControllerReady = tutorialName;
             end
             
         end
    end
    
    methods(Access = 'public')
        function controller = createController(obj, proxyView)
            % Creates the controller            
                       
            % create the controller with the proxyView
           controller = appdesigner.internal.controller.AppDesignerController(...
                obj, proxyView, obj.PeerModelManager);
        end
    end
    
    methods (Access = private)
        function handlePeerModelRootSet(obj,event)
            
            % create a proxyView with the root peer node
            peerNode = event.getTarget();
            proxyView = appdesigner.internal.view.DesignTimeProxyView(peerNode);
            
            % create the controller
            obj.createController(proxyView);
            
            % process apps to open in the queue
            for ix = 1:length(obj.AppsToOpen)
                obj.openApp(obj.AppsToOpen{ix})                
            end
            obj.AppsToOpen = {};
            
            % Create a new app if a new app was requested to be created
            % prior to controller being created.
            if obj.CreateNewAppWhenControllerReady
                obj.createNewApp()
                obj.CreateNewAppWhenControllerReady = false;
            end
            
            % Open the tutorial if it was requested to open prior to the
            % controller being created.
            if ~isempty(obj.TutorialToOpenWhenControllerReady)
                obj.openTutorial(obj.TutorialToOpenWhenControllerReady)
                obj.TutorialToOpenWhenControllerReady = '';
            end
            
        end
    end
    
end
