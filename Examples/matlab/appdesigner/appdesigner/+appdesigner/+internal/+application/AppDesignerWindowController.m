classdef AppDesignerWindowController < handle
    % AppDesignerWindowController manages starting and closing App Designer window
    %
    %   This class will start App Designer browser window, controlling the 
    %   lifetime of the browser window
    %   1) Build the parameters to start browser with specified connection
    %   and BrowserController
    %   2) Listen to PeerModelManager rootSet event to reponse to App
    %   Designer client fully started
    %   3) Listen to PeerModelManager rootUnset event to close browser and
    %   do clean up for client being closed
    %   4) Listen to WindowClosingCallback to handle browser closing
    %   request
    %   5) Listen to MATLABClosingCallback to handle MATLAB closing request
    %   6) Listen to 'ObjectBeingDestroyed' of BrowserController to handle
    %   browser process exits unexpectedly
    
    %   Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Access = public)
        % the private browser target, default value is CEF
        BrowserControllerFactory = appdesservices.internal.peermodel.BrowserControllerFactory.CEF;
        
        % connection object to start the connector
        Connection        
    end
    
    properties (Access = private)
        % the App Designer model.  It is the model in "model = appdesigner"
        AppDesignerModel
        
        % the BrowserController manage to start/close browser
        BrowserController
        
        % the MATLAB side PeerModelManager
        PeerModelManager
        
        % listeners on the peerModelManager's rootset and rootUnset events
        % so the AppDesigner objects can be initialized and cleaned up appropriately
        PeerModelRootSetListener
        PeerModelRootUnsetListener
        
        % Listener on the root peer node's peerEvent to handle AppDesigner closed
        % by exitting MATLAB, like hitting "X" button of MATLAB
		AppDesignerPeerEventListener
    end
    
    methods (Access = public)
        function obj = AppDesignerWindowController(peerModelManager, appDesignerModel, connection)
            
            obj.PeerModelManager = peerModelManager;
            % listen to when the client's root peer node has been created
            obj.PeerModelRootSetListener = addlistener(obj.PeerModelManager, ...
                'rootSet', @(src,event)obj.handlePeerModelRootSet(event));
            
            obj.AppDesignerModel = appDesignerModel;
            
            % Connection object to manage the URL for staring App Designer
            obj.Connection = connection;
            
        end
        
        function startBrowser(obj, urlQueryParams, browserControllerFactory)
            % STARTBROWSER start App Designer client browser
            % 
            %   urlQueryParams : url query parameters object
            %   browserControllerFactory: optional, browser for launching
            %   App Designer
            
            % The browserControllerFactory argument is optional which 
            % specify the browser to launch
            % if not provided, the default would be webwindow
            if nargin == 3
                obj.BrowserControllerFactory = browserControllerFactory;
            end
            
            % ensure we have a fresh URL
            obj.Connection.refresh(urlQueryParams.QueryString);
           
            % set initial Browser State and launch the client
            initialBrowserState.Title = message('MATLAB:appdesigner:appdesigner:AppDesigner').getString();
            initialBrowserState.URL = obj.Connection.AbsoluteUrlPath;
            
            % Pass preference group to browser controller to save browser
            % window postion/state when closing, to restore when launching
            % App Designer next time
            initialBrowserState.PrefGroup = 'appdesigner';
            
            try
                obj.BrowserController = obj.BrowserControllerFactory.launch(initialBrowserState);
            catch e
                % Browser window, for example, CEF, fails to start, and 
                % then clean up, instead of leaving it in a bad state
                obj.delete();
                rethrow(e);
            end
            
            % When the browser is launched, the AppDesigner 
            % registers a close listener on the browser.
            % Then when the browser is closed, the delete()
            % method in this class is called which cleans up the 
            % browser instance.
            % However, if when launching AppDesigner, the user closes 
            % MATLAB very quickly, there is a chance the AppDesigner 
            % client did not have a chance to notify server side to register
            % the listener. If this is the case, there will be asyncio 
            % errors on the command as MATLAB is exiting because AppDesigner 
            % is still holding on to the reference to the browser.
            %
            % To avoid these errors, a CustomWindowClosingCallback on the
            % browser is installed that will perform the cleanup
            % in the situation described above.   
            obj.BrowserController.WindowClosingCallback = @(browserObj, event)delete(obj);
            
            % When CEF process exits unexpectedly, like being killed
            % from Task Manager, clean up App Designer. If this happens,
            % CEF would have no chance to call WindowClosingCallback
            obj.BrowserController.addlistener('ObjectBeingDestroyed', ...
                    @(source, event)delete(obj));
        end
        
        function bringToFront(obj)
            obj.BrowserController.bringToFront();            
        end
        
        function delete(obj)
            % cleanup the browser
            if ~isempty(obj.BrowserController) && isvalid(obj.BrowserController)
                % only startBrower() being called, BrowserController will
                % be created.
                delete(obj.BrowserController);            
            end
            
            % cleanup the listeners on the rootset, rootunset events
            if ~isempty(obj.PeerModelRootUnsetListener)
                % Because ClientCloseListener is set when client fully
                % opened, need to check before deleting
                delete(obj.PeerModelRootUnsetListener);
                
                % Set to empty after deleting, otherwise it would be a
                % value of deleted or invalid object when calling
                % delete() if the user hit "X" before completing
                % initialization
                obj.PeerModelRootUnsetListener = [];                
            end
            delete(obj.PeerModelRootSetListener);
            
            % cleanup the listener on the peerEvent event
            if ~isempty(obj.AppDesignerPeerEventListener)
                % PeerModelRootUnsetListener is setup when AppDesigner client is
                % fully initialized. If the user hit "X" before completing
                % initialization, PeerModelRootUnsetListener would be invalid.
                % So need to check it before deleting.
                delete(obj.AppDesignerPeerEventListener);
                % Set to empty after deleting, otherwise it would be a
                % value of deleted or invalid object when calling
                % delete() if the user hit "X" before completing
                % initialization
                obj.AppDesignerPeerEventListener = [];
            end
        end
    end
    
    methods (Access = private)
        function handlePeerModelRootSet(obj,event)
            % When PeerModelManager's root is set, the App Designer is started.
            % process the App Designer being fully started
            peerNode = event.getTarget();
            
            % Listen to peer event from client side to handle 'appDesignerClosed'
            % which is fired by exiting MATLAB
            obj.AppDesignerPeerEventListener = addlistener(peerNode, ...
                'peerEvent', @(src,event)obj.handleBrowserClosedByMATLAB(event));
            
            % listen to when the client's root peer node has been destroyed
            if obj.BrowserController.isCloseEventSupported()
                % only listen to rootUnset if the browser supports Close
                % event, otherwise refreshing webpage will cause the
                % window closed
                obj.PeerModelRootUnsetListener = addlistener(obj.PeerModelManager, ...
                    'rootUnset',@(src,event)obj.handlePeerModelRootUnset(event));
            end
            
            % the browser is intialized properly so set the 
            % WindowClosingCallback to handleBrowserRequestToClose to
            % let AppDesignerWindowController react to rootUnset to do
            % closing AppDesigner
            obj.BrowserController.WindowClosingCallback = @(browserObj, event)obj.handleBrowserRequestToClose(event);

            % When MATLAB is closed, AppDesigner will be closed directly 
            % without a chance to handle dirty apps. In order to give
            % users oppurtunity to save dirty apps, handle
            % MATLABClosing event from webwindow.
            % Only set this callback when browser is initialized
            % properly, otherwise client side Javascript can't react to this event
            obj.BrowserController.MATLABClosingCallback = @(browserObj, event)obj.handleMATLABRequestToClose(event);            
        end
        
        function handlePeerModelRootUnset(obj, ~)
           % When root node is unset of the PeerModelManager, the App Designer 
           % is closed. and so process the App Designer being closed
           
           delete(obj);
        end
        
        function handleBrowserClosedByMATLAB(obj, event)
            % process the browser being closed by exiting MATLAB
            
            % Get all the event data's names
            eventDataHashMap = event.getData();                        
            
            % Error Checking
            assert(eventDataHashMap.containsKey('Name'), ...
                'The event data is malformed.  It does not contain a ''Name'' field.');
            
            eventDataStruct = appdesservices.internal.peermodel.convertJavaMapToStruct(eventDataHashMap);
            % appDesignerClosedByExitingMATLAB peer event from client side
            if strcmp(eventDataStruct.Name, 'appDesignerClosedByExitingMATLAB')
                delete(obj);

                % At the end try to exit MATLAB because AppDesigner is closed by
                % MATLABRequestToClose event
                exit;                
            end
        end
        
        function handleBrowserRequestToClose(obj, ~)
            % Handle browser window closed event with requesting AppDesigner to close
            
            % Send BrowserRequestToClose event to client to let AppDesigner
            % have a chance to handle dirty apps
            obj.sendRequestToCloseEventToClient('BrowserRequestToClose');
        end
        
        function handleMATLABRequestToClose(obj, ~)
            % Handle MATLABClosing event with requesting AppDesigner to close
            
            % Send MATLABRequestToClose event to client to let AppDesigner
            % have a chance to handle dirty apps
            obj.sendRequestToCloseEventToClient('MATLABRequestToClose');
        end
        
        function sendRequestToCloseEventToClient(obj, eventName)
            % Bring AppDesigner to front and send peerEvent to client to
            % request to close
            
            % Bring AppDesigner to front to let users to answer save or not
            % if there's any dirty apps
            obj.BrowserController.bringToFront();
            
            % Send "request to close event" to client to let AppDesigner
            % have a chance to handle dirty apps
            controllerHandle = obj.AppDesignerModel.getControllerHandle();
            controllerHandle.ProxyView.sendEventToClient(eventName, {});
        end
        
    end    
end

