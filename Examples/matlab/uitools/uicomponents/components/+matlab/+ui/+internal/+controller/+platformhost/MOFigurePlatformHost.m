classdef MOFigurePlatformHost < matlab.ui.internal.controller.platformhost.FigurePlatformHost

    % FigurePlatformHost class containing the MATLAB Online platform-specific functions for
    % the matlab.ui.internal.controller.FigureController object
    % 
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Access = protected)
        ReleaseHTMLFile = 'moComponentContainer.html'; 
    end 
    
    properties (Access = private)
        MOSubscriptionId % message subscription for MATLAB Online
        SubscriptionId  % message subscription ID for specific app/uifigure
        MOChannelId = '/mlapp/figure' % Channel on which messages exchanged between Server and Client 
        MOChannelIdForApp %Channel id specific to the Figure based on the peerNodeId
        Position
        Title
        Resizable
        Visible
    end % private properties

    methods (Access = public)

        % constructor
        function this = MOFigurePlatformHost(updatesFromClientImpl)
            
            this = this@matlab.ui.internal.controller.platformhost.FigurePlatformHost(updatesFromClientImpl);
            
            % subscribe on the general channel to handle Messages for MO
            % refresh
            this.MOSubscriptionId = message.subscribe(this.MOChannelId, @(data)this.handleMOMessage(data));
            
        end % constructor

        % destructor
        function delete(this)
            
            if(~isempty(this.MOChannelIdForApp) && ~isempty(this.SubscriptionId)) 
                %Publish the close message to the Client to Close the mlapp
                message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, 'eventType', 'windowClosed'));
                %unsubscribe on specific figure channel;
                message.unsubscribe(this.SubscriptionId);
                %unsubscribe on the general channel;
                message.unsubscribe(this.MOSubscriptionId);
            end    
        end % destructor
       
        %
        % methods delegated to by FigureController and implemented by this FigurePlatformHost child class
        %

        % createView() - perform platform-specific view creation operations
        function createView(this, peerModelInfo, pos, title, visible, resizable, ~)
            
            %defer to base class for common information 
            this.createView@matlab.ui.internal.controller.platformhost.FigurePlatformHost(peerModelInfo);
            
            % update the properties for the initial creation
            this.Position = pos;
            this.Title = title;
            this.Visible = visible;
            this.Resizable = resizable;
                       
            %create the channel id based on the peerNodeId for particular
            % figure, so that communication happens to particular figure
            this.MOChannelIdForApp = this.createMOChannelIdForApp(this.PeerModelInfo.Id);
                        
            %post msg to client to show figure in iframe
            this.sendOpenMessage();
            
           
                        
            % subscribe on the channel with peerNodeId to handle Messages
            % for specific Figure
            this.SubscriptionId = message.subscribe(this.MOChannelIdForApp, @(data)this.handleMessage(data));
        end % createView()
        
        function sendOpenMessage(this)
            
            
            % publish the URL so MO can show the figure
            message.publish(this.MOChannelId, struct('host', this.PeerModelInfo.URL, 'peerNodeId', this.PeerModelInfo.Id, ...
                            'position', this.Position, 'name', this.Title, 'visibility', this.Visible, ...
                            'resizable', this.Resizable, 'eventType', 'windowOpen'));
            
        end    

        % isDrawnowSyncSupported() - platform-specific function to return whether or not drawnow synchronization is supported
        function status = isDrawnowSyncSupported(this)
            status = true;
        end
            
        % updatePosition() - platform-specific supplement to FigureController.updatePosition()
        function updatePosition(this, newPos)
            
            % save the position, until MO doesn't lose it when visibility is turned off
            this.Position = newPos;

            message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, ...
                            'position', newPos, 'eventType', 'windowPropertyChanged'));
        end % updatePosition()
        
        % updateTitle() - platform-specific supplement to FigureController.updateTitle()
        function updateTitle(this, newTitle)
            
            % save the title, until MO doesn't lose it when visibility is turned off
            this.Title = newTitle;

            message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, ...
                            'name', newTitle, 'eventType', 'windowPropertyChanged'));
        end % updateTitle()

        % updateVisible() - platform-specific supplement to FigureController.updateVisible()
        function updateVisible(this, newVisible)

            this.Visible = newVisible;
            
            message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, ...
                                'visibility', newVisible, 'eventType', 'windowPropertyChanged'));
            
        end % updateVisible()
        
          % updateResize() - platform-specific supplement to FigureController.updateTitle()
        function updateResize(this, newResizable)
            
            % save the resize, until MO doesn't lose it when visibility is turned off
            this.Resizable = newResizable;

            message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, ...
                            'resizable', newResizable, 'eventType', 'windowPropertyChanged'));
        end % updateResize()

        % toFront() - request that the MO virtual window be brought to the front
        function toFront(this)
            message.publish(this.MOChannelIdForApp, struct('peerNodeId', this.PeerModelInfo.Id, ...
                                                           'eventType', 'windowToFront'));
        end

    end % public methods
    
    methods (Access = private)
        
        % create the MOChannelId based on the peerNodeId
        function id = createMOChannelIdForApp(this, peerNodeID) 
            id = strcat(this.MOChannelId, '/', peerNodeID);
        end
        
        % handleMessage() - handle messages sent by client
        function handleMessage(this, data)
            try
                if strcmpi(data.eventType, 'windowClosed')
                    this.onAppFigureWindowClosed();
                elseif strcmpi(data.eventType, 'windowPropertyChanged')
                    if (isnumeric(data.data.position))
                        % save the position, until MO doesn't lose it when visibility is turned off
                        this.Position = data.data.position';
                        this.UpdatesFromClientImpl.updatePositionFromClient(this.Position);
                    end
                end
            catch e %#ok<NASGU>
            end    
            
        end % handleMessage()
        
         function handleMOMessage(this, data)
            try
                if strcmpi(data.eventType, 'moRefreshed')
                    %resend the msg to open the figure 
                    this.sendOpenMessage();
                end
            catch e %#ok<NASGU>
            end    
            
        end % handleMessage()
        
        function onAppFigureWindowClosed(this)
            
            % call to Figure Contoller window close 
            % which will execute the CloseRequestFcn on Model
            this.UpdatesFromClientImpl.windowClosed();
        end
        
    end    

end
