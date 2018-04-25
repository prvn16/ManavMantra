classdef AppDesignerController < ...
        appdesservices.internal.interfaces.controller.AbstractController & ...
        appdesservices.internal.interfaces.controller.AppDesignerParentingController & ... 
        matlab.ui.internal.componentframework.services.optional.ControllerInterface
        
    % AppDesignerController is the controller for AppDesigner.

    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Access = private)
        % listener on the peerModelManager's childMoved event
        ChildMovedListener
    end
    
    methods
        
        function obj = AppDesignerController(model, proxyView, peerModelManager)
            % OBJ = APPDESIGNERCONTROLLER(model) creates
            % a new instance of the App DesignerController.
            
            % There is no parent controller because the AppDesigner is the
            % "root"
            parentController = [];
            obj = obj@appdesservices.internal.interfaces.controller.AbstractController(model, parentController, proxyView);
            
            % construct the DesignTimeParentingController with the factory to
            % create child model objects
            factory = appdesigner.internal.model.AppDesignerChildModelFactory();
            
            obj = obj@appdesservices.internal.interfaces.controller.AppDesignerParentingController(factory);
            
            % listen to childMoved event for reparenting components
            obj.ChildMovedListener = addlistener(peerModelManager,'childMoved',@(src,event)obj.handleChildMoved(event));
        end
        
        function proxyView = createProxyView(obj, propertyPVPairs)
            % PROXYVIEW = CREATEPROXYVIEW(OBJ, PVPAIRS) This method is abstract
            % in the base class and creates the ProxyView class.
            
            % AppController is a DesignTimeParentingController so the proxyView
            % for it is constructed in the DesignTimeParentingController and
            % passed into this class via the model.  Need to overload
            % becuase it is abstract
        end
        
        function delete(obj)
            delete@appdesservices.internal.interfaces.controller.AbstractController(obj);
            delete@appdesservices.internal.interfaces.controller.AppDesignerParentingController(obj);
            
            delete(obj.ChildMovedListener);
        end
    end
    
    methods(Access = 'protected')
                  
        function handleEvent(obj, source, event)
             % No-op.. the AppDesignerController has no events to handle
        end
    
        function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
            % By default, all public properties are pushed to the view
            % Remove all of them since no properties are needed by the view 
            excludedPropertyNames = properties(obj.Model);
        end
        
        function pvPairsForView = getPropertiesForView(obj, ~)
            %  No-op
            pvPairsForView = {};
        end
        
    end
    
    methods (Access = private)
        function handleChildMoved(obj, event)
            % Process a peer node being reparented
			%
			% Note that this involves both:
			%
			% - Moving to an entirely new parent
			% - shuffling within an existing parent (ex: tab / tab group
			% reordering)
            
            % Extract the event data
            eventData = event.getData();
            
            % Extract the peer node of the component being reparented
            reparentedPeerNode = event.getSource();
            
            % TODO: The client now implements grouping, and when a subgroup
            % is created a move event is created and processing comes here.
            % Simply return for now until server-side support is added for
            % grouping
            if strcmp(reparentedPeerNode.getType(),'Group')
                return;
            end
            
            % From the app window containing the reparented component, 
            % get all the children. From all the children, we will then find 
            % the reparented component and the new parent objects.
            %
            % To gather all the children of the app window:
            %
            %   - from the reparented peer node, go up the hierarchy until
            %   we find an app model peer node 
            %
            %   - use the app model peer node to get the app model object
            %
            %   - use the app model to get the app window and all the
            %   children in that app window
            
            % Find the AppModel Peer Node containing the reparented peer
            % node
            containerPeerNode = reparentedPeerNode.getParent();
            while(~strcmp(containerPeerNode.getType(), 'AppModel'))
                containerPeerNode = containerPeerNode.getParent();
            end
            appModelPeerNode = containerPeerNode;
            
            % Find the AppModel object using the id
            appModel = byId(obj.Model.Children, appModelPeerNode.getId());
            
            % Get all children in the App Window
            componentList = appdesigner.internal.application.getDescendants(appModel.UIFigure);
            
            % Find the reparented component
            reparentedComponent = obj.findChild(componentList,reparentedPeerNode.getId());
            
            % Find the new parent component
            newParentPeerNode = eventData.get('newParent');
            newParentComponent = obj.findChild(componentList,newParentPeerNode.getId());
            
            % Find the old parent component
            oldParentPeerNode = eventData.get('oldParent');
            oldParentComponent = obj.findChild(componentList,oldParentPeerNode.getId());
			
			% Get the controller
			reparentedController = reparentedComponent.getControllerHandle();
            
            % Find the index in the new parent
			% 
			% Shift the index by 1 because JS -> ML conversion
			index = eventData.get('newIndex') + 1; 
					
			reparentedController.reparentComponent(newParentComponent, oldParentComponent, index);
        end
    end
end
