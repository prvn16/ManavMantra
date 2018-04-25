classdef CEFFigurePlatformHost < matlab.ui.internal.controller.platformhost.FigurePlatformHost

    % FigurePlatformHost class containing the CEF platform-specific functions for
    % the matlab.ui.internal.controller.FigureController object
    % 
    % Copyright 2016-2017 The MathWorks, Inc.
   
    properties (Access = protected)
        ReleaseHTMLFile = 'cefComponentContainer.html';
    end    
    properties (Hidden, Access = private)
        CEF;            % CEF webwindow
        hasCEF = false; % indicates whether or not the CEF webwindow has been created
        UpdateWindowStatePending = false; % indicates that a WindowState property update is in progress
        currentWindowState; % local copy of WindowState value
        normalStatePending = false; % is a CEF.restore() intended to transition to 'normal' state? 
        ignoreNextWindowStateChange;
    end % Hidden properties with private access
    properties (Hidden, Dependent, Access=private)
        CEFWindowState
    end

    methods (Access = public)

        % constructor
        function this = CEFFigurePlatformHost(updatesFromClientImpl)
            this = this@matlab.ui.internal.controller.platformhost.FigurePlatformHost(updatesFromClientImpl);
      end % constructor

        % destructor
        function delete(this)
            % delete CEF window object if it was ever created
            if this.hasCEF
                delete(this.CEF);
            end
        end % delete()
        
        %
        % methods delegated to by FigureController and implemented by this FigurePlatformHost child class
        %

        % createView() - perform platform-specific view creation operations
        function createView(this, peerModelInfo, position, ~, visible, ~, windowState)
            if ~(matlab.ui.internal.hasDisplay() && matlab.ui.internal.isFigureShowEnabled)
                % There is no display connected to the MATLAB session, or
                % MATLAB was started with the -nodisplay flag
                % Silently skip view creation...
                return;
            end
            
            this.createView@matlab.ui.internal.controller.platformhost.FigurePlatformHost(peerModelInfo);
            
     
            % create and set up the CEF webwindow only if creation has not been disabled
            if ~this.disableWindowCreation()
            
                % create the CEF webwindow
                this.CEF = matlab.internal.webwindow(peerModelInfo.URL, peerModelInfo.DebugPort, position);
                this.hasCEF = true;
                
                this.currentWindowState = windowState;
                
                % if the CEF window is to be created maximized or minimized
                % AND it is visible, then apply that window state value right away
                if ~isempty(visible) && logical(visible) && (strcmp(windowState, 'maximized') || strcmp(windowState, 'minimized'))
                    this.applyWindowState(windowState);
                end
            
                 % Apply the standard Figure icon
                icondir = fullfile(toolboxdir('matlab'),'uitools','uicomponents','resources','images');
                if (ismac || ispc)
                    icon = fullfile(icondir,'figure.ico');
                else                
                    icon = fullfile(icondir,'figure_48.png');
                end
                this.CEF.Icon = icon;

                % add resize request callback
                this.CEF.CustomWindowResizingCallback = @(event, data) resizeRequest(this, event, data);
                
                % add view killed callback
                this.CEF.MATLABWindowExitedCallback = @(event, data) this.onViewKilled();
                
                this.CEF.WindowStateCallback = @(event, data) windowStateChanged(this, event, data);
            end
        end % createView()
        
        % isDrawnowSyncSupported() - platform-specific function to return whether or not drawnow synchronization is supported
        function status = isDrawnowSyncSupported(this)
            status = ~this.disableWindowCreation();
        end
        
        % isWindowMaximized() - platform-specific function to return whether or not window is maximized
        function maximized = isWindowMaximized(this)
            maximized = false;
            if this.hasCEF
                maximized =  this.CEF.isMaximized;
            end
        end % isWindowMaximized()
        
        % overrideClose() - platform-specific function to wire up the close callback on the Figure to a handler function
        function overrideClose(this, fcn)
        % NOTE: This prevents the CEF window from being closed when the 'x' 
        % is clicked. It is up to the handler to delete the CEF window.
            if this.hasCEF
                this.CEF.CustomWindowClosingCallback = fcn;
            end
        end % overrideClose()
        
        % updatePosition() - platform-specific supplement to FigureController.updatePosition()
        function updatePosition(this, newPos)
            % set Position only if it differs from current Position (g1429917)
            if this.hasCEF
                rPos = round(newPos);
                if ~isequal(rPos, this.CEF.Position)
                    this.CEF.Position = rPos;
                end
            end
        end % updatePosition()
        
        % updateResize() - platform-specific supplement to FigureController.updateResize()
        function updateResize(this, newResizable)
            if strcmp(this.currentWindowState, 'fullscreen')
                % setting resizable disturbs full-screen mode
                return;
            end
            if this.hasCEF
                this.CEF.setResizable(newResizable);
            end
        end % updateResize()

        % updateTitle() - platform-specific supplement to FigureController.updateTitle()
        function updateTitle(this, newTitle)
            if this.hasCEF
                this.CEF.Title = newTitle;
            end
        end % updateTitle()

        % updateVisible() - platform-specific supplement to FigureController.updateVisible()
        function updateVisible(this, newVisible)
            if this.hasCEF
                if ~this.disableWindowCreation()
                    if newVisible
                        % Make sure any window state set while hidden is applied
                        if ~isempty(this.currentWindowState)
                            try
                                this.applyWindowState(this.currentWindowState)
                            catch
                                % ignore unsupported window state errors from webwindow
                            end
                        end
                        if strcmp(this.currentWindowState, 'minimized')
                            % special handling for minimize--must be shown before minimizing
                            % because showing the CEF window restores it to normal state
                            this.CEF.show();
                            this.CEF.minimize();
                        elseif ~strcmp(this.currentWindowState, 'fullscreen') || ~ismac
                            % bring the figure to the front as well as show
                            % it, but not if full-screen on Mac
                            this.CEF.bringToFront();
                        end
                    else
                        this.CEF.hide();
                    end
                end
            end
        end % updateVisible()

        % updateWindowState() - platform-specific supplement to FigureController.updateWindowState()
        function updateWindowState(this, newWindowState)
            this.currentWindowState = newWindowState;
            
            if this.hasCEF
                if ~this.CEF.isVisible()
                    return;
                end
            
                % Ignore CEF window callbacks while updating state
                this.UpdateWindowStatePending = true;
                resetFlag = onCleanup(@this.resetUpdateWindowStatePendingFlag);

                try
                    if strcmp(newWindowState, 'normal')
                        % Take note if the new state is "normal" because it could require special
                        % handling in the CEF callback
                        this.normalStatePending = true;
                    end
                    
                    this.applyWindowState(newWindowState);
                catch err
                    % If changing the window state fails, change the property
                    % back to its original value. This can happen with Mac
                    % split-screen mode, for example.
                    if strcmp(err.identifier, 'cefclient:webwindow:UnsupportedOpForWindowType')
                        this.UpdatesFromClientImpl.updateWindowStateFromClient(this.CEFWindowState);
                    end
                end
            end
        end % updateWindowState()

        % toFront() - request that the CEF window be brought to the front
        function toFront(this)
            bringToFront(this.CEF);
        end
    
    end % public methods

    methods (Access = private)
        
        % applyWindowState() - make the appropriate webwindow call for the given window state value
        % can throw an error if the given window state isn't supported
        function applyWindowState(this, windowState)
            if strcmp(this.CEFWindowState, windowState)
                % If the CEF window is already in the requested state, do nothing
                return;
            end
            switch windowState
              case 'maximized'
                this.CEF.maximize();
              case 'minimized'
                this.CEF.minimize();
              case 'fullscreen'
                % putting hidden CEF windows into full-screen mode can
                % cause problems so show it first
                if ~this.CEF.isVisible
                    this.ignoreNextWindowStateChange = 'WindowRestored';
                    this.CEF.show;
                end
                this.CEF.fullscreen();
              case 'normal'
                this.CEF.restore();
            end
        end
        
        function resetUpdateWindowStatePendingFlag(this)
            this.UpdateWindowStatePending = false;
        end

        % resizeRequest() - notify the FigureUpdatesFromClient interface implementation
        function resizeRequest(this, ~, ~)
            % There is no need to check for CEF presence here as this callback is set only after the CEF
            % webwindow has been created: both occur in createView(), above.
            this.UpdatesFromClientImpl.updatePositionFromClient(this.CEF.Position);
        end % resizeRequest()
        
        % windowStateChanged - notify FigureUpdatesFromClient when window maximized, etc.
        % As with resizeRequest, it is not necessary to check the CEF window
        % exists because this function is only called as a CEF callback.
        function windowStateChanged(this, ~, newState)
            if (this.UpdateWindowStatePending)
                return;
            end
            
            if ~isempty(this.ignoreNextWindowStateChange)
                this.ignoreNextWindowStateChange = [];
                return;
            end
            
            switch newState
              case 'WindowMaximized'
                if this.normalStatePending
                    % The CEF.restore() function restores a minimized window to maximized
                    % if that was the previous state. If we intend to go directly to normal
                    % state, we have to restore a second time here. See g1717565.
                    this.normalStatePending = false;
                    this.CEF.restore();
                    return;
                else
                    newWindowState = 'maximized';
                end
              case 'WindowMinimized'
                newWindowState = 'minimized';
              case 'WindowRestored'
                newWindowState = 'normal';
              case 'WindowFullscreen'
                newWindowState = 'fullscreen';
              otherwise
                newWindowState = [];
            end
            
            if ~strcmp(newWindowState, 'normal')
                this.normalStatePending = false;
            end
            
            if ~isempty(newWindowState)
                this.UpdatesFromClientImpl.updateWindowStateFromClient(newWindowState);
            end
        end
        
    end % private methods
    
    methods (Static=true, Access={?matlab.ui.internal.controller.FigureController})

        % disableWindowCreation() - used by FigureControllerTestHelper to enable and disable window creation
        %                           used by FigurePlatformHost child classes to detect enabled versus disabled state
        function status = disableWindowCreation(dohide)
            persistent hidewindow;
            if isempty(hidewindow)
                hidewindow = false;
            end

            if nargin >= 1
                if ~islogical(dohide)
                    error('MATLAB:ui:internal:controller:FigureController:incorrectLogicalInput', 'Incorrect input. Expected a logical value of true or false');
                end
                hidewindow = dohide;
            end
            status = hidewindow;
        end % disableWindowCreation()

    end % static limited access methods
    
    methods
        function windowState = get.CEFWindowState(this)
            if this.CEF.isMaximized
                windowState = 'maximized';
            elseif this.CEF.isMinimized
                windowState = 'minimized';
            elseif this.CEF.isFullscreen
                windowState = 'fullscreen';
            else
                windowState = 'normal';
            end
        end
    end % property get methods

end
