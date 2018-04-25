
%   Copyright 2014-2017 The MathWorks, Inc.

classdef WebCanvasContainerController < matlab.ui.internal.componentframework.WebContainerController
    %WEBCANVASCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here

    properties(Transient)
         % Canvas representation of the web container component
         Canvas
    end

    properties (Access = 'protected')
        PeerEventListener
    end

    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = WebCanvasContainerController( model, varargin )

           this = this@matlab.ui.internal.componentframework.WebContainerController( model, varargin{:} );

            % Force the component to create the canvas type that matches
            % this UI system.
            model.setCanvasFactory(matlab.graphics.primitive.canvas.HTMLCanvasFactory());
        end
    end
    
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:       add
        %
        %  Description:  Method which runs the superclass add method and addlisterner
        %                to the 'peerEvent' for drawing the canvas.
        %
        %  Input :       webComponent -> Web component for which a peer node
        %                will be created using the Component Framework.
        %
        %  Output:       parentController -> Parent's controller.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function add( this, webComponent, parentController )
            
            try
            add@matlab.ui.internal.componentframework.WebContainerController( this, webComponent, parentController );
            
            this.EventHandlingService.attachEventListener( @this.handleEvent );
            
            % Initialize the SceneChannel value in the PeerNode
            updateSceneChannel(this);
                
            catch ME
                if strcmp(ME.identifier, 'MATLAB:class:InvalidHandle') ...
                        && ~isvalid(this)
                    % Ignoring this one exception - Under some
                    % conditions (e.g. if a component is deleted during
                    % a drawnow callback before it is fully created)
                    % the component (and its controller) can be already
                    % deleted before this code is reached.
                    %
                    % Therefore, swallow this exception and silently
                    % return.
                else
                    rethrow(ME);
                end
            end
        end
     
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:       set.Canvas
        %
        %  Description:  Get the id from the component peernode and set the canvas on client ready
        %                event from the client
        %
        %  Output:       Canvas.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.Canvas( obj,canvas )
            obj.Canvas = canvas;
            
            % Update the scene channel that the views should use
            updateSceneChannel(obj);
        end
    end
    
    methods (Access = 'protected')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:       handleEvent
        %
        %  Description:  handle the ClientReady event from the client
        %
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function handleEvent( obj, src, event )
            
            % Now, defer to the base class for common event processing
            handleEvent@matlab.ui.internal.componentframework.WebComponentController( obj, src, event );        
        end
    end
    
    
    methods(Access=private)
        
        function id = getPeerId(obj)
           id = char(obj.ProxyView.PeerNode.getId());
        end
        
        function updateSceneChannel(obj)
            useBinaryChannel = false;
            if ~isempty(obj.Canvas)
                serverID = obj.Canvas.ServerID;
                useBinaryChannel = strcmp(obj.Canvas.BinaryChannelAvailable,'on');
            else
                serverID = '';
            end
            
            % The channel to use is set alongside the id of the peer-node
            % that should use it.  The peer node id acts as an
            % authentication token: if another peer node is given this
            % property value then its id will not match the one in the
            % property and we will know that the channel should not be
            % used in the view.   In practice this situation does arise
            % when objects are duplicated in AppDesigner 
            token = obj.getPeerId();
            
            propValue = struct('ServerID', serverID, 'AuthToken', token, 'UseBinaryChannel', useBinaryChannel); 
            obj.EventHandlingService.setProperty('SceneServer', propValue);
        end
 
    end
end
