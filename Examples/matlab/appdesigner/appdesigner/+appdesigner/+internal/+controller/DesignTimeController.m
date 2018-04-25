classdef DesignTimeController < appdesservices.internal.interfaces.controller.AbstractControllerMixin
    %DESIGNTIMECONTROLLER This is a class that handles
    % AppDesigner specific actions such as generating code, CodeName or grouping.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    % Controller properties
    properties (Access = 'private')
        % This is the component model that will be updated in response to
        % design time events.
        DesignTimeModel
        
        % Component specific adapter instance.  This adapter will be of
        % class 'VisualComponentAdapter.
        ComponentAdapter    
        
        % Listeners for GUIEVENT coming from the proxyview
        GuiEventListener
    end
    
     methods (Abstract, Access = 'protected')
       % HANDLEDESIGNTIMEPROPERTIESCHANGED - Delegates the logic of 
       % handling the event to the runtime controllers via the
       % handlePropertiesChanged method       
       handleDesignTimePropertiesChanged(obj, src, valuesStruct);
       
       % HANDLEDESIGNTIMEEVENT - Delegates the logic of 
       % handling the peerEvent to the runtime controllers via the
       % handleEvent method
       handleDesignTimeEvent(obj, src, event);
     end
     
    properties (Constant)        
        % Class responsible for using the adapter to create code for a
        % component.  This object will be shared by all components.
        ComponentCodeGenerator = appdesigner.internal.codegeneration.ComponentCodeGenerator();
    end
    
	
    methods
        
        function obj = DesignTimeController(model, proxyView)
            
            %
            % Inputs:
            %
            %   model             The model being controlled by this
            %                     controller
            %
            %
            %   proxyView         Used when  the ProxyView is already
            %                     created.  When passed in, instead of
            %                     creating a new ProxyView, this ProxyView
            %                     is used instead.
            %
            %                     Should be [ ] when a view does not
            %                     exist.
            %
            %   codeGenerator     Object that knows how to generate code
            %                     using the component and the adapter.
            narginchk(2,3)
            
            obj.DesignTimeModel = model;
            
            % Add dynamic design time property to the model
            obj.addDesignTimeProperties();
            
            % ProxyView will be empty when controller is created in the
            % context of getting the design time defaults.  This may happen
            % in the method getComponentDesignTimeDefaults in the adapters
            % The controller class listens to GuiEvent of ProxyView so that
            % it can respond to events from the view.
            
            if ~isempty(proxyView)
                % Set ComponentAdapter of Model
                obj.ComponentAdapter = proxyView.Adapter;
                
                % Listen for GuiEvent from ProxyView
                obj.GuiEventListener = addlistener(proxyView, 'GuiEvent',...
                    @(src,event)handleGUIEvent(obj, src, event));
                
                if ~isempty(proxyView.PeerNode)
                    % When loading an app, no peer node associated to the
                    % proxyview.
                    % otherwise need to update code gen, CodeName, and
                    % GroupId design time properties                   
                    obj.updateDesignTimePropertiesFromProxyView(model, proxyView.Adapter, proxyView);
                    obj.updateComponentCode(model, proxyView.Adapter, proxyView);                    
                end

            end
        end
        
         % Determines the order that children are stored
        %
        % If true...
        %
        %   Then Children property is stored as [child 3, child 2, child 1]
        %
        %   where child 1 was added first, child 2 second, and child 3 last
        %
        %   Applies to majority of HG containers
        %
        % If false...
        %
        %   Then Children property is stored as [child 1, child 2, child 3]
        %
        %   where child 1 was added first, child 2 second, and child 3 last
        %
        %  Applies to order-based components like TabGroup and Menus
        
        % This needs to be a method instead of a property because child peerNode 
        % processing starts even before the parent controller finishes intialization.         
        % This is done in processProxyView() in DesignTimeParentingController
        % This is because childAdded events on peerNode are never triggered
        % because JavaScript being single threaded - the event handlers 
        % block access to the peer model        
        
        function isChildOrderReversed = isChildOrderReversed(obj)
           isChildOrderReversed = true; 
        end
        
        function delete(obj)
            % Clean up listeners
            delete(obj.GuiEventListener);
		end
		
		function updateGeneratedCode(obj)
			% Refreshes the generated code for this controller's component
			
			% CodeGen update for client and server-side property updates
			obj.updateComponentCode(obj.DesignTimeModel, obj.ComponentAdapter, obj.ProxyView);
		end
		
        function arrangeChildren = adjustChildOrder(obj, parentController, child, newIndex)
            % Returns an updated child list based on the new index 
            % the specified child needs to be at in its parent
            % 
            % This method is used by 
            % 1. reparentComponent() i.e. when components are
            % reparented/re-positioned
            % into a different index within the same parent
            % Eg: Reorder Tabs in Tabgroups
            % and
            % 2. processClientCreatedPeerNode() i.e. when components are
            % placed in specific indexes on creation
            % Eg: Menus are maintained at the bottom of Figure
            % hierarchy            
            
            % Get all children regardless of HandleVisibility value
            children = parentController.getAllChildren(parentController.Model);
            numberOfChildren = length(children);
            
            % Remove the newly added child from the Children list
            % to add it back later at the right index
            children(child == children) = [];
            
            if(parentController.isChildOrderReversed())
                % Imagine the view has said "insert child at index 3 in an
                % children array of length 10"
                %
                % For components that store children in opposite order of
                % insertion (panels, figure, etc...) then inserting at
                % index 3 really means "3 from the end"
                newIndex = numberOfChildren - (newIndex - 1);
            end
            
            arrangeChildren =  [...
                children(1 : newIndex - 1); ...
                child; ...
                children(newIndex : end)...
                ];
        end
        
		 function reparentComponent(obj, newParent, oldParent, newIndex)			
			 % Re-parents this controller's model
			 %
			 % When this method is called, it is assumed that the
			 % component's Peer Node is already moved, and this will ensure
			 % the controller and HG Model is upddated
			 %
			 % newParent - new HG parent
			 % oldParent - old HG parent
			 % newIndex - 1 based index where the component should be in
			 %            newParent			 						           					
			
			reparentedComponent = obj.Model;
			
			% Tell the moved component it has a new parent
			%
			% This has the side effect of removing the component from the
			% old parent's Children
			reparentedComponent.Parent = newParent;
			
			% Additionally, need to make sure that the component is in the
			% right order in the parent			
			
			newParentController = newParent.getControllerHandle();
                
            arrangeChildren = obj.adjustChildOrder(newParentController, reparentedComponent, newIndex);            
			
			newParent.Children = arrangeChildren;
						
			% reset this controller's parent controller to the new parent's
			% controller
			obj.ParentController = newParentController;
			
			% Let the old parent controller handle the fact that a peer
			% node has been removed because of a reparenting
			handlePeerNodeReparentedFrom(oldParent.getControllerHandle(), obj.ProxyView.PeerNode);
			
			% Let the new parent controller handle the fact that a peer
			% node has been added because of a reparenting
			handlePeerNodeReparentedTo(newParent.getControllerHandle(), obj.ProxyView.PeerNode);				    			
		end
	end		
    
    methods(Access = 'private')
        
        
        
         function updateDesignTimePropertiesFromProxyView(obj, model, adapter, proxyView)  
            % Update CodeName and groupId
            obj.DesignTimeModel.DesignTimeProperties.CodeName = proxyView.getProperty('CodeName');
            obj.DesignTimeModel.DesignTimeProperties.GroupId = proxyView.getProperty('GroupId');
        end
        
        function updateComponentCode(obj, model, adapter, proxyView)            
            code = proxyView.getProperty('ComponentCode');
            if (~isempty(code))
                obj.DesignTimeModel.DesignTimeProperties.ComponentCode = cell(code);                
            end
            
            % Generate component code using the code generator class
            obj.DesignTimeModel.DesignTimeProperties.ComponentCode = obj.ComponentCodeGenerator.getComponentGenerationCode(model, adapter);
            
            hashMap = appdesservices.internal.peermodel.convertPvPairsToJavaMap({'ComponentCode', obj.DesignTimeModel.DesignTimeProperties.ComponentCode});
            proxyView.PeerNode.setProperties(hashMap);
        end         
        
        function handleGUIEvent(obj, src, event)
            % HANDLEGUIEVENT - This method filters design time events and
            % passes them to their controller to handle as they will.
         
            if(strcmp(event.Data.Name, 'PropertiesChanged'))
                % GUIEvent which is fired by 'propertiesSet' event from the
                % PeerNode
                %
                % We are only handling property sets from the client. Events
                % from the client have a non-empty originator.                
                valuesStruct = event.Data.Values;
                isClientEvent = appdesservices.internal.peermodel.isEventFromClient(event);
                
                filteredValuesStruct = obj.handleComponentDynamicDesignTimeProperties(valuesStruct, isClientEvent);
                
                if ~isempty(filteredValuesStruct)
                    % Excluding dynamic design time properties, e.g,
                    % CodeName, GroupId, there are still other component's
                    % own properties changed
                    if isClientEvent
                        % Update the model if the properties set happened
                        % from the client
                        obj.handlePeerNodePropertiesSet(src, filteredValuesStruct);                        
                    end
                end
            else
                % GUIEvent which is fired by 'peerEvent' event from the
                % PeerNode
                obj.handlePeerNodePeerEvent(src, event);
            end
            
           updateGeneratedCode(obj);
        end
        
        function handlePeerNodePropertiesSet(obj, src, valuesStruct)
            % Handle Property Change events explicitly
            
            % By default delegate to the abstract method which will be
            % implemented by the sub class to handle it
            obj.handleDesignTimePropertiesChanged(src, valuesStruct);            
        end
        
        function handlePeerNodePeerEvent(obj, src, event)
            % Handler for 'peerEvent' from the Peer Node
            
            % Delegate to the abstract method which will be implemented by
            % the subclass
            obj.handleDesignTimeEvent(src, event);
        end
        
        function unhandledPropertyValuesStruct = handleComponentDynamicDesignTimeProperties(obj, valuesStruct, isClientEvent)
            % HANDLECOMPONENTDYNAMICDESIGNTIMEPROPERTIES - Filter app designer specific
            % properties that do not need to be handled by the component
            % controllers.
            % It is assumed that valuesStruct has two fields, 'newValues'
            % and 'oldValues'
            
            % These are properties that are appdesigner specific, these do
            % not need to be processed by the component controllers. After
            % processing them, remove form valuesStruct
            designTimePropertiesToHandle = {'CodeName', 'GroupId'};
            
            % Initialize struct
            unhandledPropertyValuesStruct = valuesStruct;
            
            for index = 1: numel(designTimePropertiesToHandle)
                % Verify that property is in the newValues field, and
                % update to the model's dynamic property before trying to
                % remove
                propertyName = designTimePropertiesToHandle{index};
                if isfield(valuesStruct, designTimePropertiesToHandle{index})
                    if isClientEvent
                        % Update the properties if the properties set happened
                        % from the client
                        obj.DesignTimeModel.DesignTimeProperties.(propertyName) = valuesStruct.(propertyName);
                    end
                    
                    unhandledPropertyValuesStruct = rmfield(unhandledPropertyValuesStruct, propertyName);                    
                end
            end
            
            
            if(isClientEvent)              
                if(isfield(valuesStruct, 'ComponentCode'))
                    unhandledPropertyValuesStruct = rmfield(unhandledPropertyValuesStruct, 'ComponentCode');
                end
            end
            
            % If there are no longer any property updates after filtering,
            % return empty.
            if isempty(fields(unhandledPropertyValuesStruct))
                unhandledPropertyValuesStruct = [];
            end
            
        end
        
        function addDesignTimeProperties(obj)
            
            % Dynamic design time properties for the model
            % In the loading case, the property is already in the model
            if ~isprop(obj.DesignTimeModel, 'DesignTimeProperties')
                prop = addprop(obj.DesignTimeModel, 'DesignTimeProperties');
                
                % create a structure of DesignTime properties
                obj.DesignTimeModel.DesignTimeProperties = struct();
                obj.DesignTimeModel.DesignTimeProperties.CodeName = '';
                obj.DesignTimeModel.DesignTimeProperties.GroupId = '';
                obj.DesignTimeModel.DesignTimeProperties.ComponentCode = {};
            end
        end
	end    
end