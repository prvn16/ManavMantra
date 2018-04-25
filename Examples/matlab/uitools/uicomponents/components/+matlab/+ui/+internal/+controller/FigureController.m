classdef FigureController < matlab.ui.internal.controller.WebCanvasContainerController & ...
                            matlab.ui.internal.controller.FigureUpdatesFromClient
    % FIGURECONTROLLER Controller object for matlab.ui.Figure
    % This is the controller object that connects matlab.ui.Figure objects
    % to an HTML-based view.
    %
    % Copyright 2013-2017 The MathWorks, Inc.

    properties (Access = private)
        PositionListener
        % This variable is used for the setPosition for the figure as Set is happening in the Matlab 
        % and get is happening on the client side. This will be cleaned off
        % once set is wired up on the client side with same channel
        FigureToolsHeight = 0; 
        URLMapKey
        PlatformHost    % host that performs platform-specific operations for the current platform
        PeerModelInfo
        PeerModelSynchronizer = [];
    end

    methods

        function this = FigureController(model, varargin)
            % instantiate base class
            this = this@matlab.ui.internal.controller.WebCanvasContainerController(model, varargin{:});
            
            % get the PlatformHost for the environment in which we are being created,
            %  passing in the model's controllerInfo structure and our
            % instance of the FigureUpdatesFromClient interface, which happens to be us.
            factory = matlab.ui.internal.controller.platformhost.FigurePlatformHostFactory;
            this.PlatformHost = factory.createHost(this.Model.getControllerInfo(), this);

            model.setDrawnowSyncReady(this.PlatformHost.isDrawnowSyncSupported());
        end

        function delete(this)
            % delete the PeerModelInfo AFTER the PlatformHost, which may use it
            delete(this.PlatformHost);
            delete(this.PeerModelInfo);
            matlab.ui.internal.FigureServices.removeFigureURL(this.URLMapKey);
        end

        % This is the entry point for the Position set through PMS
        function newPos = updatePosition(this)
            newPos = this.Model.Position_I;

            % Ideally this should be done in a custom "post/side-effect" function
            % which accepts the output from this function (newPos)
            positionChanged(this);
        end

        % This is the entry point for the Position set through FigureWindowMethods
        % during initialization. Ideally, this will be removed once PMS handles
        % initialization
        function positionChanged(this)
            % As Figure tools area is not part of Figure client area 
            % we append the height of Figure tools to the window height
            figToolsPosition = [0 0 0 this.FigureToolsHeight]; 
            adjPos = this.Model.Position_I + figToolsPosition;
            this.PlatformHost.updatePosition(adjPos);
        end

        function newTitle = updateTitle(this)
            newTitle = this.getTitle();
            this.PlatformHost.updateTitle(newTitle);    % delegate update to PlatformHost
        end

        function newVisible = updateVisible(this)
            newVisible = this.getVisible();
            this.PlatformHost.updateVisible(newVisible);    % delegate update to PlatformHost
        end

        function newResizable = updateResize(this)
            newResizable = this.getResizable();
            this.PlatformHost.updateResize(newResizable);   % delegate update to PlatformHost
        end
        
        function newWindowState = updateWindowState(this)
            newWindowState = this.getWindowState();
            if strcmp(newWindowState, 'fullscreen')
                this.showBanner(message('MATLAB:ui:uifigure:FullscreenModeEscapeHint'));
            else
                this.hideBanner();
            end
            this.PlatformHost.updateWindowState(newWindowState);   % delegate update to PlatformHost
        end
        
        % return the maximized state of the window
        function maximized = isWindowMaximized(this)
            maximized = this.PlatformHost.isWindowMaximized();            
        end
        
        
    end % unqualified (public) methods
    
    methods (Access = private)
        function showBanner(this, msg)
            params = struct('action', 'showBanner');
            if isa(msg, 'message')
                params.message = msg.getString();
            else
                params.message = msg;
            end
            channelID = ['/gbt/figure/DialogService/' this.getId()];
            publishHandle = @() message.publish(channelID, params);
            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(this.Model, publishHandle);
        end
        
        function hideBanner(this)
            params = struct('action', 'hideBanner');
            channelID = ['/gbt/figure/DialogService/' this.getId()];
            publishHandle = @() message.publish(channelID, params);
            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(this.Model, publishHandle);
        end

        % Using the Property Management Service ( PMS ), the 'Title' property has
        % defined dependency on the 'NumberTitle', 'IntegerHandle' and 'Name' properties.
        % If any of these properties change this update function will be invoked by the PMS.
        function title = getTitle (this)
            % Using the Property Management Service ( PMS ), the 'Title' property has
            % defined dependency on the 'NumberTitle', 'IntegerHandle' and 'Name' properties.
            % If any of these properties change this update function will be invoked by the PMS.
            name = this.Model.Name;
            title = '';
            if (~isempty(name) || ...
                  (this.is(this.Model.IntegerHandle) && this.is(this.Model.NumberTitle)))
                % Assemble the Figure's title (e.g. "Figure 1: My Figure")
                if (this.is(this.Model.IntegerHandle) && this.is(this.Model.NumberTitle))
                    title = ['Figure ' num2str(this.Model.Number)];
                    if (~isempty(name))
                        title = [title ': '];
                    end
                end
                if (~isempty(name))
                    title = [title name];
                end
            end
        end
        
        function visible = getVisible (this)
            visible = false;
            if (this.is(this.Model.Visible))
                visible = true;
            end
        end

        function resizable = getResizable (this)
            resizable = false;
            if (this.is(this.Model.Resize))
                resizable = true;
            end
        end
        
        function windowState = getWindowState (this)
            windowState = this.Model.WindowState;
        end
    end
    
    methods (Access = protected)

        function defineViewProperties( this )
            % Define view properties specific to the figure, then call super
            this.PropertyManagementService.defineViewProperty('Color');
            this.PropertyManagementService.defineViewProperty('Position_I');
            this.PropertyManagementService.defineViewProperty('Title');
            this.PropertyManagementService.defineViewProperty('Visible');
            this.PropertyManagementService.defineViewProperty('Resize');
            this.PropertyManagementService.defineViewProperty('AutoResizeChildren');
            this.PropertyManagementService.defineViewProperty('WindowState');
            defineViewProperties@matlab.ui.internal.controller.WebCanvasContainerController(this);
        end

        function defineRenamedProperties( this )
            % Define renamed properties specific to the figure, then call super
            this.PropertyManagementService.defineRenamedProperty('Color','BackgroundColor');
            % Rename Position_I to FigurePosition to be consistent with the
            % property name stored on the peer node from the dependency defn
            this.PropertyManagementService.defineRenamedProperty('Position_I','Position');
            defineRenamedProperties@matlab.ui.internal.componentframework.WebComponentController(this);
        end

        function definePropertyDependencies( this )
            % Define property dependencies specific to the figure, then call super
            this.PropertyManagementService.definePropertyDependency('NumberTitle','Title');
            this.PropertyManagementService.definePropertyDependency('IntegerHandle','Title');
            this.PropertyManagementService.definePropertyDependency('Name','Title');
            this.PropertyManagementService.definePropertyDependency('Visible','Visible');
            this.PropertyManagementService.definePropertyDependency('Resize','Resize');
            this.PropertyManagementService.definePropertyDependency('WindowState','WindowState');

            % Define Position_I as a dependency property to get a hook to
            % customize the delegation. In the future, PMS may accommodate
            % the ability to invoke a custom post/side-effect function
            % The expected result here is that a "FigurePosition" PV pair
            % will be set on the peer node, and the updateFigurePosition
            % function will be called.
            this.PropertyManagementService.definePropertyDependency('Position_I','Position');
            definePropertyDependencies@matlab.ui.internal.componentframework.WebComponentController(this);
        end

        function parentView = getParentView(~, ~)
        % The Figure has no parent peer node, so it returns empty.
            parentView = [];
        end

        function createView(this, ~, ~, ~)
            % get the html file form the platform host and send to the 
            % FigurePeerModelInfo for the URL construction
            htmlFile = this.PlatformHost.getHTMLFile();
            % Create the peer node by using the FigurePeerModelInfo.
            this.PeerModelInfo = matlab.ui.internal.controller.FigurePeerModelInfo(htmlFile);
            this.ProxyView.PeerNode = this.PeerModelInfo.FigurePeerNode;
            this.ProxyView.PeerModelManager = this.PeerModelInfo.PeerModelManager;
            
            % Get the Properties to be send to the specific platform host
            % used for the initialization
            pos = this.Model.Position_I;
            title = this.getTitle();
            visible = this.getVisible();
            resizable = this.getResizable();
            windowState = this.getWindowState();
            % Perform platform-specific view creation operations
            this.PlatformHost.createView(this.PeerModelInfo, pos, title, visible, resizable, windowState);
            
            % CommandSender setup
            [commandSenderChannel, unloadEventChannel, reconnectEventChannel] = this.Model.createPubSubConnection;

            % Use Property Management Service (PMS)
            pvPairs = this.PropertyManagementService.definePvPairs( this.Model );
            
            % add pubsub channels
            pvPairs{end+1} = 'CommandSenderChannel';
            pvPairs{end+1} = commandSenderChannel;
            pvPairs{end+1} = 'UnloadEventChannel';
            pvPairs{end+1} = unloadEventChannel;
            pvPairs{end+1} = 'ReconnectEventChannel';
            pvPairs{end+1} = reconnectEventChannel;
            
            % Add the window maximized state to the figure peernode so it can be
            % used for the figure inner position calculation in the maximized state 
            pvPairs{end+1} = 'windowMaximize';
            pvPairs{end+1} = this.isWindowMaximized();
            
            % Add the type of host to figure peernode so it can be
            % used for creating corresponding platform strategy in the java script
            pvPairs{end+1} = 'hostType';
            if isa(this.PlatformHost, 'matlab.ui.internal.controller.platformhost.MOFigurePlatformHost')
                pvPairs{end+1} = 'moclient';
            elseif isa(this.PlatformHost, 'matlab.ui.internal.controller.platformhost.CEFFigurePlatformHost')
                if(~this.PlatformHost.disableWindowCreation())
                    pvPairs{end+1} = 'cefclient';
                else
                    pvPairs{end+1} = '';
                end
            elseif isa(this.PlatformHost, 'matlab.ui.internal.controller.platformhost.WebAppsFigurePlatformHost')
                 pvPairs{end+1} = 'webappsclient';
            else 
                pvPairs{end+1} = '';    % this covers DesktopFigurePlatformHost
            end
            
            % TODO: Should the conversion be implemented through the EHS?
            %       If our approach changes in the future, there will be one place to change it.
            map = appdesservices.internal.peermodel.convertPvPairsToJavaMap( pvPairs );
            % TODO: Should setting the properties done through the EHS, after EHS attaches to the view?
            this.ProxyView.PeerNode.setProperties( map );

            % Attach to view
            this.EventHandlingService.attachView( this.ProxyView );

            % Cache the Figure's URL
            this.URLMapKey = double(this.Model); % KLUDGE: This bleeds the abstraction.
                                                 % The Component Framework should provide a hook as the model is being destroyed,
                                                 % so the controller can do any cleanup needed where the model is still required.
            matlab.ui.internal.FigureServices.setFigureURL(this.URLMapKey, this.PeerModelInfo.URL);

            % Wire up the close behavior to invoke the hg closereq function
            this.PlatformHost.overrideClose(@(o,e)this.Model.hgclose());
            
        end

        function handleEvent( this, src, event )

            if( this.EventHandlingService.isClientEvent( event ) )
                
                eventStructure = this.EventHandlingService.getEventStructure( event );
                switch ( eventStructure.Name )
                    case 'positionChangedEvent'
                        figurePosition = [eventStructure.x eventStructure.y eventStructure.width eventStructure.height];
                        %Update the Model with rendered position
                        this.Model.setPositionFromClient(figurePosition);
                        %Set the height of the Figure tools area from the
                        %client which used in setting the position 
                        this.FigureToolsHeight = eventStructure.figToolsHeight;
                        %Sync the peernode with position from the model
                        this.EventHandlingService.setProperty( 'Position', this.Model.Position );
                    case 'escapeFullscreen'
                        if strcmp(this.Model.WindowState, 'fullscreen')
                            this.Model.setWindowStateFromClient('normal');
                            this.updateWindowState();
                        end
                    case 'toggleFullscreen'
                        if strcmp(this.Model.WindowState, 'fullscreen')
                            this.Model.setWindowStateFromClient('normal');
                            this.updateWindowState();
                        else
                            this.Model.setWindowStateFromClient('fullscreen');
                            this.updateWindowState();
                        end
                    otherwise
                        % Now, defer to the base class for common event processing
                        handleEvent@matlab.ui.internal.controller.WebCanvasContainerController( this, src, event );
                end    
            end
        end
        
        function postSet( obj, property )
           % Customizable method provided by the MATLAB Component Framework (MCF)
           % that will be invoked after to the setting of the property. 
               
           if(strcmp(property, 'BeingDeleted'))
               % Note: We are using the postSet method to react when
               % BeingDeleted is updated instead of adding the property
               % to the peer node and using updateBeingDeleted because
               % currently, the view does not need BeingDeleted to be
               % sent. If that becomes the case, this code can move
               % into updateBeingDeleted.

               value = obj.Model.get( property );
               if(strcmp(value, 'on'))
                   % The figure is about to be deleted, hide the figure
                   % so users don't have see components being deleted
                   % one at a time (g1496493).
                   obj.PlatformHost.updateVisible(false);
               end
           end

           postSet@matlab.ui.internal.controller.WebCanvasContainerController(obj, property);
        end
        
    end % protected methods

    methods (Access = public)
        % These functions constitute the FigureController's implementation of the FigureUpdatesFromClient interface
        
        function onViewKilled(this)
            delete(this.Model);
        end % viewKilled()

        function updatePositionFromClient(this, position)
            this.EventHandlingService.setProperty( 'windowMaximize', this.isWindowMaximized() );
            % update the model's position only if it differs from its current position
            if ~isequal(position, this.Model.Position)
                this.Model.setPositionFromClient(position);
            end
        end % updatePositionFromClient()
        
        function updateWindowStateFromClient(this, newState)
            this.EventHandlingService.setProperty('windowMaximize', this.isWindowMaximized());
            if ~isequal(newState, this.Model.WindowState)
                this.Model.setWindowStateFromClient(newState);
            end
        end % updateWindowStateFromClient

        function windowClosed(this)
            this.Model.hgclose();
        end % windowClosed()
        
    end % public methods
    
    methods (Access = { ?matlab.ui.Figure, ?tFigureController } )
        
        % Used by Figure.flushCoalescer() to implement the short-term solution
        % for drawnow property updates. When the long-term solution is
        % implemented, this method can be removed; see g1658467.
        function flushCoalescer(this)
            % It's possible that PeerModelInfo has not been set yet. If
            % that's the case, then there is no synchronizer, and therefore
            % no coalescer to flush.
            if ~isempty(this.PeerModelInfo)
                this.PeerModelInfo.Synchronizer.flushCoalescer;
            end
        end

        % Requests that the Figure's window be brought to the front
        function toFront(this)
            toFront(this.PlatformHost);
        end
 
    end % FigureHelper limited access methods
  
    methods (Static=true, Access = {?util.FigureControllerTestHelper})
        
        % disableWindowCreation() - used by FigureControllerTestHelper to enable and disable window creation
        function status = disableWindowCreation(dohide)
            status = matlab.ui.internal.controller.platformhost.CEFFigurePlatformHost.disableWindowCreation(dohide);
        end % disableWindowCreation()
        
    end % static limited access methods

end
