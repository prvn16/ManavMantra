classdef (Sealed = true) Manager < handle
    %%%%%%%%%%
    %     Copyright: 2016 The MathWorks, Inc.
    %     This class manages Add-Ons Manager CEF window
    %%%%%%%%%%
    
    properties (Access = private)
        windowStateUtil = matlab.internal.addons.WindowStateUtil;

        addOnsWindowInstance
    end
    
    methods (Access = private)
        
        function newObj = Manager()
            newObj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow.empty();
        end
        
    end
    
    methods (Static, Access = public)
        
        function obj = getInstance()
            persistent uniqueManagerInstance;
            if(isempty(uniqueManagerInstance))
                obj = matlab.internal.addons.Manager();
                uniqueManagerInstance = obj;
            else
                obj = uniqueManagerInstance;
            end
        end
    end
    
    methods (Access = public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   1. Creates new Add-Ons Manager if it is not already open
        %   2. If Add-Ons Manager is already open, the function brings it to front
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function show(obj, navigationData)
            if(obj.windowExists)
                obj.publish(obj.getMatlabToAddonsViewClientMessage(navigationData.getJson));
            else
                obj.createNewWindow;
                obj.loadUrlForNavigationData(navigationData);
            end
            obj.addOnsWindowInstance.bringToFront();
        end
        
        function exists = windowExists(obj)
            exists = ~(isempty(obj.addOnsWindowInstance));
        end
        
        function debugPort = getDebugPort(obj)
            debugPort = obj.addOnsWindowInstance.getDebugPort;
        end
        
        function url = getUrl(obj)
            url = obj.addOnsWindowInstance.getUrl;
        end
        
        function close(obj)
            obj.addOnsWindowInstance.dispose;
        end
        
    end
    
    methods (Access = private)
        
        function createNewWindow(obj)
            obj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow(com.mathworks.addons.ClientType.MANAGER, obj.windowStateUtil.getPositionForManager);
            addlistener(obj.addOnsWindowInstance, 'AddOnsWindowClosing', @obj.dispose);
        end
        
        function dispose(obj,~,~)
            currentPosition = obj.addOnsWindowInstance.getNormalWindowPosition;
            isMaximized = obj.addOnsWindowInstance.isMaximized;
            obj.addOnsWindowInstance.close();
            obj.windowStateUtil.setManagerPositionSetting(currentPosition);
            obj.windowStateUtil.setManagerWindowMaximizedSetting(isMaximized);
            obj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow.empty();
        end

        function loadUrlForNavigationData(obj, navigationData)
            uniquePubSubChannelKey = obj.addOnsWindowInstance.addOnsCommunicator.getUniqueKey;
            url = com.mathworks.addons.MatlabPlatformStrategyFactory.createStrategyForCurrentPlatform().getManagerUrl(uniquePubSubChannelKey, navigationData);
            obj.addOnsWindowInstance.launch(url, obj.windowStateUtil.getManagerWindowMaximizedSetting);
        end

        function publish(obj, matlabToAddOnsWindowMessage)
            obj.addOnsWindowInstance.addOnsCommunicator.publish(matlabToAddOnsWindowMessage);
        end

        function communicationMessage = getMatlabToAddonsViewClientMessage(~, navigationData)
            communicationMessage = com.mathworks.addons.CommunicationMessage(com.mathworks.addons.CommunicationMessageType.NAVIGATE_TO, navigationData);
        end
    end
end