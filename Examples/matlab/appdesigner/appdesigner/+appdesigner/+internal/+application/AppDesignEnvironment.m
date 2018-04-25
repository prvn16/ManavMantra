classdef AppDesignEnvironment < handle
    % APPDESIGNENVIRONMENT  Launches the App Designer
    %
    %    This class manages App Designer related settings, like index url,
    %    NameSpace, and dependent MATLAB services, like RTC, Debug.
    %    This class will launch App Designer browser window, and will open   
    %    an app if App Designer already launched
    
    %    Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Access = private)
        % the PeerModel manager
        PeerModelManager
        
        % the App Designer browser window controller
        AppDesignerWindowController
        
        % listener to the AppDesignerWindowController being destroyed
        WindowControllerDestroyedListener
        
        % app designer settings service used to listen to update of setting
        % value.
        appDesignerSettingsService
    end
    
    properties (SetAccess = private, ...
                GetAccess = ?appdesigner.internal.application.AppCodeTool)
        % the App Designer model
        AppDesignerModel        
    end
    
     properties (Constant)
        % URLs for different App Designer modes
        ReleaseUrl = 'toolbox/matlab/appdesigner/web/index.html'
        DebugUrl = 'toolbox/matlab/appdesigner/web/index-debug.html'
        
        % PeerModel manager namespace for App Designer
        NameSpace = '/appdesigner'
     end
    
    methods
        function obj = AppDesignEnvironment(peerModelManager, appDesignerModel)
            
            obj.initializeMATLABServices();
            
            obj.PeerModelManager = peerModelManager;
            obj.AppDesignerModel = appDesignerModel;
        end
        
        function startAppDesigner(obj, varargin)
            % STARTAPPDESIGNER start App Designer 
            % 
            % If call this method without arugments, will just launching
            % App Designer with opening a default app
            %
            % The optional arguments:
            %    UrlQueryParameters to use when launching App Designer
            %    URL to use when launching App Designer
            %    Browser for starting App Designer

            narginchk(1, 4);

            if obj.isAppDesignerWindowOpen()           
                % App Designer is already open so bring to front
                obj.AppDesignerWindowController.bringToFront();
            else
                % App Designer not open so start it
                
                if nargin > 1
                    urlQueryParams = varargin{1};
                else
                    urlQueryParams = appdesigner.internal.application.UrlQueryParameters();
                end
                
                initialLoadingAppPath = urlQueryParams.getQueryValue('OpenApp');
                if ~isempty(initialLoadingAppPath)
                    obj.AppDesignerModel.InitialLoadingApp = initialLoadingAppPath;
                end
                
                % create Connection for AppDesignerWindowController
                pathToWebPage = appdesigner.internal.application.AppDesignEnvironment.ReleaseUrl;
                if nargin > 2
                    pathToWebPage = varargin{2};
                end
                connection = appdesservices.internal.peermodel.Connection(pathToWebPage);            

                % create the AppDesignerWindowController which will launch App Designer
                % browser window            
                obj.AppDesignerWindowController = appdesigner.internal.application.AppDesignerWindowController( ...
                    obj.PeerModelManager, obj.AppDesignerModel, connection);

                % listen to when the AppDesignerWindowController is destroyed which means
                % the App Designer is closed by the users
                obj.WindowControllerDestroyedListener = addlistener(obj.AppDesignerWindowController,'ObjectBeingDestroyed', ...
                    @(source, event)delete(obj));

                % parse arguments to start App Designer: queryParams and browser
                inputArguments = {urlQueryParams};

                if nargin > 3
                    % browser controller factory
                    inputArguments{end+1} = varargin{3};
                end
                obj.AppDesignerWindowController.startBrowser(inputArguments{:});
            end            
        end
        
        function createNewApp(obj)
            %  CREATENEWAPP Opens a new app in App Designer
            %     
            %   createNewApp() will bring to front/launch App Designer
            %       and create a new blank, unsaved app
            
            if obj.isAppDesignerWindowOpen()
                obj.AppDesignerWindowController.bringToFront();
                obj.AppDesignerModel.createNewApp();
            else
                % If it isn't open, start app designer. It has a new app
                % by default so don't need to create a new one.
                obj.startAppDesigner();
            end
        end
        
        function openApp(obj, filePath)
            %  OPENAPP Open the app in App Designer
            %     
            %   openApp() will bring bring to front or launch App Designer
            %       and open the app if the file path is not empty
            
            assert(~isempty(filePath), 'filePath should not be empty');
                        
            if obj.isAppDesignerWindowOpen()
                obj.AppDesignerWindowController.bringToFront();
                obj.AppDesignerModel.openApp(filePath);
            else
                queryParams = appdesigner.internal.application.UrlQueryParameters({'OpenApp'}, {filePath});
                obj.startAppDesigner(queryParams) 
            end
        end
        
        function openTutorial(obj, tutorialName)
            %  OPENTUTORIAL Opens the tutorial specified by tutorialName
            %     
            %   openTutorial() will bring to front or launch App Designer 
            %       and bring to front or start the tututorial.
            
            assert(~isempty(tutorialName), 'tutorialName should not be empty');
            
            if obj.isAppDesignerWindowOpen()
                obj.AppDesignerWindowController.bringToFront();
                obj.AppDesignerModel.openTutorial(tutorialName);
            else
                queryParams = appdesigner.internal.application.UrlQueryParameters({'OpenTutorial'}, {tutorialName});
                obj.startAppDesigner(queryParams);
            end
        end
        
        function delete(obj)
            if ~isempty(obj.WindowControllerDestroyedListener)
                delete(obj.WindowControllerDestroyedListener);
                obj.WindowControllerDestroyedListener = [];
            end
            
            if ~isempty(obj.AppDesignerWindowController) ...
                    && isvalid(obj.AppDesignerWindowController)
                % The object would be empty if not calling
                % startAppDesigner()
                % If the user hits 'X' to close App Designer,
                % AppDesignerWindowController would already be destroyed
                delete(obj.AppDesignerWindowController);
            end
            
            % clean all the event listners for settings entires
            if ~isempty(obj.appDesignerSettingsService)
                obj.appDesignerSettingsService.delete();
            end
        end
        
        function componentAdapterMap = getComponentAdapterMap(obj)
            componentAdapterMap = obj.AppDesignerModel.ComponentAdapterMap;
        end
    end
    
    methods (Access = private)
        
        function isOpen = isAppDesignerWindowOpen(obj)
            isOpen = ~isempty(obj.AppDesignerWindowController) ...
                    && isvalid(obj.AppDesignerWindowController);
        end
    
        function initializeMATLABServices(obj)                    
            % Start the connector clipboard service to allow interaction
            % with the system clipboard
            com.mathworks.services.clipboardservice.ConnectorClipboardService.getInstance();
            
            % initialize the property listeners for settings entries
            import appdesigner.internal.application.AppDesignerSettingsService;
            obj.appDesignerSettingsService = AppDesignerSettingsService();
        end
    end
    
    methods (Static)
        function peerModelManager = getPeerModelManager(uniqueNameSpace)
            % This method will be called in the very beginning of starting
            % AppDesigner, and at that time connector probably would not be
            % fully on, related connector java class path not being set
            % correctly. getClientInstance() call would fail, especially in
            % the cluster, runlikebat much more likely to fail.
            % So ensure connector fully on, and the following call would be
            % no-op if connector already fully started, otherwise wait
            % until fully loaded
            connector.ensureServiceOn();
            
            % set up the peer model manager with appdesigner namespace            
            peerModelManager = com.mathworks.peermodel.PeerModelManagers.getClientInstance(uniqueNameSpace);
            peerModelManager.setSyncEnabled(true);
        end
    end
end