classdef FigurePlatformHost < handle

    % PlatformHost base class defining the set of platform-specific functions performed
    % by its child classes for the matlab.ui.internal.controller.FigureController object
    % 
    % Copyright 2016-2017 The MathWorks, Inc.
   
    properties (Abstract, Access = protected)
        ReleaseHTMLFile;
    end    
    
    properties (Access = protected)
        DebugHTMLFile = 'componentContainer-debug.html';
        PeerModelInfo           % PeerModelInfo used by the figure
        UpdatesFromClientImpl   % implementation of FigureUpdatesFromClient interface
    end % protected properties
    
    methods (Access = public)

        % constructor
        function this = FigurePlatformHost(updatesFromClientImpl)
            this.UpdatesFromClientImpl = updatesFromClientImpl;
        end % constructor

        % destructor
        function delete(~)
        end % delete()

        %
        % public methods delegated to by FigureController and implemented by FigurePlatformHost child classes
        % Most of these methods are empty and none are abstract, so they can serve as stubs for all
        % child classes that have no need to implement platform-specific functionality for them.
        %

        % createView() - perform platform-specific view creation operations
        function createView(this, peerModelInfo, ~, ~, ~, ~, ~)
            this.PeerModelInfo = peerModelInfo;
        end % createView()

        % isDrawnowSyncSupported() - platform-specific function to return whether or not drawnow synchronization is supported
        function status = isDrawnowSyncSupported(this)
            status = false;
        end
        
        % isWindowMaximized() - platform-specific function to return whether or not window is maximized
        function maximized = isWindowMaximized(this)
            maximized = false;
        end % isWindowMaximized()
        
        % onViewKilled() - function to delete the figure when the View has been killed
        function onViewKilled(this)
            this.UpdatesFromClientImpl.onViewKilled();
        end % onViewKilled()
        
        % overrideClose() - platform-specific function to wire up the close callback on the Figure to a handler function
        function overrideClose(~, ~)
        end % overrideClose()
        
        % updatePosition() - platform-specific supplement to FigureController.updatePosition()
        function updatePosition(~, ~)
        end % updatePosition()
        
        % updateResize() - platform-specific supplement to FigureController.updateResize()
        function updateResize(~, ~)
        end % updateResize()

        % updateTitle() - platform-specific supplement to FigureController.updateTitle()
        function updateTitle(~, ~)
        end % updateTitle()

        % updateVisible() - platform-specific supplement to FigureController.updateVisible()
        function updateVisible(~, ~)
        end % updateVisible()

        % updateWindowState() - platform-specific supplement to FigureController.updateWindowState()
        function updateWindowState(this, newWindowState)
        end % updateWindowState()
        
        % toFront() - platform-specific supplement to FigureController.toFront()
        function toFront(this)
        end

        % Return the html File based on the status of the DebugMode of the
        % Application
        function htmlFile = getHTMLFile(this)
            s = settings;
            htmlFile = this.ReleaseHTMLFile;
            
            if s.matlab.ui.UIFigureDebugModeEnabled.ActiveValue
                htmlFile = this.DebugHTMLFile;
            end
        end  

    end % public methods
    
end
