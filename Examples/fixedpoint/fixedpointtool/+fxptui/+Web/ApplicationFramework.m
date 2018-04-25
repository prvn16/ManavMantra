classdef ApplicationFramework < handle
    % APPLICATIONFRAMEWORK Provides a basic service of rendering a given URL
    % within a CEF window. It also allows for callbacks to be attached to the
    % window open/close events.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess = private)
        useCEF = true;
        WindowCloseCallback
        WindowReadyCallback
        CEFWindow
        Subscriptions
        SubscribeChannel
        DebugPort = 0;
    end
    
    properties(SetAccess = private)
        URL
        Position
        Title
    end
    
    
    methods
        function this = ApplicationFramework(url, title, debugPort, position)
            if nargin < 2
                [msg, id] = fxptui.message('incorrectInputArgsFramework');
                throw(MException(id, msg));
            end
            connector.ensureServiceOn;
            
            this.URL = fxptui.Web.CreateNoncedURL(url);
            
            this.Title = title;
            if nargin == 3
                this.DebugPort = debugPort;
            end
            if nargin < 4
                this.Position = this.getDefaultPosition;
            else
                this.Position = position;
            end
            this.SubscribeChannel = sprintf('/%s/%s/%s','fxd',strrep(this.Title,' ',''), 'browserready');
            
        end
        
        function addCloseCallback(this, cb)
            if ~isa(cb, 'function_handle')
                [msg, id] = fxptui.message('incorrectInputType','function_handle',class(cb));
                throw(MException(id, msg));
            end
            this.WindowCloseCallback = cb;
        end
        
        function addReadyCallback(this, cb)
            if ~isa(cb, 'function_handle')
                [msg, id] = fxptui.message('incorrectInputType','function_handle',class(cb));
                throw(MException(id, msg));
            end
            this.WindowReadyCallback = cb;
            this.Subscriptions = message.subscribe(this.SubscribeChannel, this.WindowReadyCallback);
        end
        
        function readyChannel = getReadyChannel(this)
            readyChannel = this.SubscribeChannel;
        end
        
        function openUI(this)
            opts = {};
            if isempty(this.CEFWindow)
                this.CEFWindow = matlab.internal.webwindow(this.URL,this.DebugPort, opts{:});
                if isempty(this.WindowCloseCallback)
                    this.CEFWindow.CustomWindowClosingCallback = @(s, e)onBrowserClose(this);
                else
                    this.CEFWindow.CustomWindowClosingCallback = this.WindowCloseCallback;
                end
                this.CEFWindow.Title = this.Title;
                this.CEFWindow.Position = this.Position;
            end
            this.CEFWindow.show;
            this.CEFWindow.bringToFront;
        end
        
        function showUI(this)
                this.CEFWindow.show;
                this.CEFWindow.bringToFront;
        end
        
        function hideUI(this)
            hide(this.CEFWindow);
        end
        
        function b = isVisible(this)
            b = this.CEFWindow.isVisible;
        end
        
        function delete(this)
            % Class destructor
            this.cleanup;
        end
        
        function onBrowserClose(this)
            this.cleanup;
        end
    end
    
    methods(Hidden)
        function cefWindow = getWindow(this)
            cefWindow = this.CEFWindow;
            
        end
        
        function setDebugPort(this, debugPort)
            this.DebugPort = debugPort;
        end
        
        function port = getDebugPort(this)
            port = this.DebugPort;
        end
        
        function url = getURL(this)
            url =  this.URL;
        end
        
        function setTitle(this, title)
            this.CEFWindow.Title = title; 
        end
        
    end
    
    methods(Access = private)
        function cleanup(this)
            if ~isempty(this.Subscriptions)
                message.unsubscribe(this.Subscriptions);
                this.Subscriptions = [];
            end
            if ~isempty(this.CEFWindow)
                delete(this.CEFWindow);
                this.CEFWindow = [];
            end
            this.WindowCloseCallback = [];
            this.WindowReadyCallback = [];
        end
        
        function position = getDefaultPosition(~)
            % Get the default position of the window based on the screen
            % size.
            graphObj = groot;
            width = 1360;
            height = 800;
            screenWidth = graphObj.ScreenSize(3);
            screenHeight = graphObj.ScreenSize(4);
            maxWidth = 0.8 * screenWidth;
            maxHeight = 0.8 * screenHeight;
            if maxWidth > 0 && width > maxWidth
                width = maxWidth;
            end
            if maxHeight > 0 && height > maxHeight
                height = maxHeight;
            end
            
            xOffset = (screenWidth - width) / 2;
            yOffset = (screenHeight - height) / 2;
            
            position = [xOffset yOffset width height];
        end
    end
    
    
    
end
