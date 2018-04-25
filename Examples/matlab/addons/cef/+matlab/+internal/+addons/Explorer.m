classdef (Sealed = true) Explorer < handle
    %%%%%%%%%%
    %     Copyright: 2016-2017 The MathWorks, Inc.
    %     This class manages Add-Ons Explorer CEF window
    %%%%%%%%%%
    
    properties (Access = private)
        addOnsWindowInstance

        windowStateUtil = matlab.internal.addons.WindowStateUtil
    end
    
    methods (Access = private)
        
        function newObj = Explorer()
            newObj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow.empty();
        end
        
    end
    
    methods (Static, Access = public)
        
        function obj = getInstance()
            persistent uniqueExplorerInstance;
            if(isempty(uniqueExplorerInstance))
                obj = matlab.internal.addons.Explorer();
                uniqueExplorerInstance = obj;
            else
                obj = uniqueExplorerInstance;
            end
        end
    end
    
    methods (Access = public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %   1. Creates new Add-Ons Explorer if it is not already open 
        %   2. If Add-Ons Explorer is already open, the function brings it to front
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function show(obj, navigationData)
            obj.showExplorer(navigationData);
        end

        function exists = windowExists(obj)
            exists = ~(isempty(obj.addOnsWindowInstance));
        end
        
        function bringToFront(obj)
            obj.addOnsWindowInstance.bringToFront();
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

        function sendMessage(obj, communicationMessage)
            if(obj.windowExists)
                obj.publish(communicationMessage);
            end
        end

    end

    methods (Access = private)

        function createNewWindow(obj)
            obj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow(com.mathworks.addons.ClientType.EXPLORER, obj.windowStateUtil.getPositionForExplorer);
            addlistener(obj.addOnsWindowInstance, 'AddOnsWindowClosing', @obj.dispose);
        end

        function dispose(obj,~,~)
            currentPosition = obj.addOnsWindowInstance.getNormalWindowPosition;
            isMaximized = obj.addOnsWindowInstance.isMaximized;
            obj.addOnsWindowInstance.close();
            obj.windowStateUtil.setExplorerPositionSetting(currentPosition);
            obj.windowStateUtil.setExplorerWindowMaximizedSetting(isMaximized);
            obj.addOnsWindowInstance = matlab.internal.addons.AddOnsWindow.empty();
        end

        function showExplorer(obj, navigationData)
            if(obj.windowExists)
                obj.publish(obj.getMatlabToAddonsViewClientMessage(navigationData.getJson));
            else
                obj.createNewWindow;
                obj.loadUrlForNavigateToMessage(navigationData);
            end
            obj.addOnsWindowInstance.bringToFront();
        end

        function loadUrlForNavigateToMessage(obj, navigationData)
            uniquePubSubChannelKey = obj.addOnsWindowInstance.addOnsCommunicator.getUniqueKey;
            url = com.mathworks.addons.MatlabPlatformStrategyFactory.createStrategyForCurrentPlatform().getExplorerUrl(uniquePubSubChannelKey, navigationData);
            obj.addOnsWindowInstance.launch(url, obj.windowStateUtil.getExplorerWindowMaximizedSetting);
        end
        function publish(obj, matlabToAddOnsWindowMessage)
            obj.addOnsWindowInstance.addOnsCommunicator.publish(matlabToAddOnsWindowMessage);
        end

        function communicationMessage = getMatlabToAddonsViewClientMessage(~, navigationData)
            communicationMessage = com.mathworks.addons.CommunicationMessage(com.mathworks.addons.CommunicationMessageType.NAVIGATE_TO, navigationData);
        end
    end
end