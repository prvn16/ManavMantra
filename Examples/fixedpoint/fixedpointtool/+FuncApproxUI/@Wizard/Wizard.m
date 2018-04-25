classdef Wizard < handle
    % WIZARD singleton class that instantiated and maintains the Look-Up
    % Table application
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess=private)
        DebugURL = 'toolbox/fixedpoint/fixedpointtool/web/lookuptable/index-debug.html';
        ReleaseURL = 'toolbox/fixedpoint/fixedpointtool/web/lookuptable/index.html';
        LutFinishSubscribeChannel = '/lookuptable/finish'
        WebWindow
        WizardController
        Subscriptions
        % g1682803 - Make window size bigger to accommodate data type info
        % in the optimization report
        DlgPosition = [100 100 1024 650]
        AppUniqueID
        MsgServiceInterface
        AppReady = false
        AppTitle = FuncApproxUI.Utils.lookuptableMessage('appTitle');
    end
    
    methods(Access = private)
        function this = Wizard
            % WIZARD Construct an instance of this class
            % Ensure the connector is on before subscribing. Connector depends on java & jvm to work.
            if usejava('jvm')
                connector.ensureServiceOn;
            else
                % throw an error and close the application               
                [msg, msg_ID] = FuncApproxUI.Utils.lookuptableMessage('javaRequired');                
                lut_exception = MException(msg_ID, msg);
                throwAsCaller(lut_exception);
            end
            mlock;
        end
        
        function createApplication(this, debugPort)
            this.WebWindow = fxptui.Web.ApplicationFramework(this.ReleaseURL, this.AppTitle, debugPort, this.DlgPosition);
            this.WebWindow.addCloseCallback(@(s,e)close(this));
        end
        
        initControllers(this, clientData);
        deleteControllers(this);
    end
    
    methods(Hidden)
        function webWindow = getWebWindow(this)
            webWindow = this.WebWindow;
        end
        
        function url = getURL(this)
            url = this.WebWindow.getURL;
        end
        
        function port = getDebugPort(this)
            port = this.WebWindow.getDebugPort;
        end
        
        function show(this)
            this.WebWindow.openUI;
        end
        
        function delete(this)
            this.close;
        end
        
        function lutInfo = getWizardController(this)
            lutInfo = this.WizardController;
        end
        
        function type = getSelectedLutType(this)
            type = this.WizardController.getSelectedLutType;
        end
        
        function uniqueID = getAppUniqueId(this)
            uniqueID = this.AppUniqueID;
        end
        
        function msgServiceInterface = getMsgServiceInterface(this)
            msgServiceInterface = this.MsgServiceInterface;
        end  
        
        function setMsgServiceInterface(this, msgServiceInterface)
            this.MsgServiceInterface = msgServiceInterface;
        end
        
        function bool = isAppReady(this)
            bool = this.AppReady;
        end        
    end
    
    methods
        open(this, debugPort);
        close(this);
    end
   
    methods (Static)
        instance = getExistingInstance;        
        launch(debug);
    end
    
    methods(Static, Access = private)
        instance = getInstance;
    end
end

% LocalWords:  fixedpointtool lookuptable
