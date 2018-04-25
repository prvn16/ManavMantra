classdef (Sealed = true) AddOnsWindow < handle
    %%%%%%%%%%
    %
    %  Copyright: 2016-2017 The MathWorks, Inc.
    %
    %  The class represents Add-Ons Window
    %%%%%%%%%%
    
    properties (Access = private)
        webwindow
        
        debugPort
        
        % Browser position at normal window state for restoring from
        % maximized window state
        normalWindowPosition
    end
    
    properties (Access = public)
        clientTitle
        
        addOnsCommunicator
        
        uiNotifier
    end
    
    events
        % This event is triggered before the window is actually closed
        AddOnsWindowClosing
    end
    
    methods (Access = {?matlab.internal.addons.Explorer, ?matlab.internal.addons.Manager})
        
        function obj = AddOnsWindow(clientType, position)
            obj.normalWindowPosition = position;
            uniqueId = java.lang.String.valueOf(randi(1000,1));
            obj.addOnsCommunicator = com.mathworks.addons.AddonsCommunicator(uniqueId);
            obj.addOnsCommunicator.startMessageService;
            obj.uiNotifier = clientType.getUINotifier(obj.addOnsCommunicator);
            com.mathworks.addons_common.notificationframework.UINotifierRegistry.register(obj.uiNotifier);
            obj.clientTitle = clientType.getTitle;
        end
        
        function launch(obj, url, maximized)
            obj.debugPort = matlab.internal.getOpenPort;
            obj.webwindow = matlab.internal.webwindow(char(url.toString()), obj.debugPort, obj.normalWindowPosition);
            obj.webwindow.Title = char(obj.clientTitle);
            obj.webwindow.CustomWindowClosingCallback = @obj.dispose;
            if(maximized)
                % call bringToFront before maximize
                % otherwise maximize would fail to restore the window back
                % to the pervious normalWindowPosition
                obj.webwindow.bringToFront();
                obj.webwindow.maximize;  
            else
                obj.webwindow.show;
            end
            
            obj.webwindow.CustomWindowResizingCallback = @(cefobj, event)obj.handleBrowserResizing(event);
        end
        
        function bringToFront(obj)
            obj.webwindow.bringToFront();
        end
        
        function updateUrl(obj, url)
            obj.webwindow.URL = char(url.toString());
        end
        
        function debugPort = getDebugPort(obj)
            debugPort = obj.debugPort;
        end
        
        function url = getUrl(obj)
            url = replace(obj.webwindow.executeJS('window.location.href'),'"','');
        end
        
        function dispose(obj,~,~)
            notify(obj, 'AddOnsWindowClosing');
            com.mathworks.addons_common.notificationframework.UINotifierRegistry.unRegister(obj.uiNotifier);
            obj.addOnsCommunicator.unsubscribe;
        end
        
        function close(obj)

			if ismac
                com.mathworks.util.NativeJava.macActivateIgnoringOtherApps();
            end

			obj.webwindow.close();
        end
        
        function windowPosition = getNormalWindowPosition(obj)
            windowPosition = obj.normalWindowPosition;
        end
        
        function maximized = isMaximized(obj)
            maximized = obj.webwindow.isMaximized;
        end
        function handleBrowserResizing(obj, ~)
            if(~obj.webwindow.isMaximized())
                obj.normalWindowPosition = obj.webwindow.Position;
            end
        end
    end
end