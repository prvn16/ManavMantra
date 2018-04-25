classdef (Hidden) TreeController < ...
        matlab.ui.control.internal.controller.ComponentController & ...
        matlab.ui.container.internal.controller.mixin.ExpandableComponentController
    
    % Copyright 2016 The MathWorks, Inc.
    methods
        function obj = TreeController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
            obj@matlab.ui.container.internal.controller.mixin.ExpandableComponentController(varargin{:});
        end
    end
    
     methods(Access = 'public')
         
        function scroll(obj, scrollTarget)
            % SCROLL(OBJ, scrollTarget) - scroll to target which can be
            % nodeID, 'top' or 'bottom'
            
            
            obj.ProxyView.sendEventToClient(...
                    'scroll',...
                    { ...
                        'Target', scrollTarget, ...
                    } ...
                );
                       
        end
        
     end
     
    methods(Access = 'protected')
        function propertyNames = getAdditionalPropertyNamesForView(obj)
            % Get additional properties to be sent to the view
            
            propertyNames = getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);
            
            % Non - public properties that need to be sent to the view
            propertyNames = [propertyNames; {...
                'NodeId';...                
                }];    
        end
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
            % properties, given the PROPERTYNAMES
            %
            % Inputs:
            %
            %   propertyNames - list of properties that changed in the
            %                   component model.
            %
            % Outputs:
            %
            %   viewPvPairs   - list of {name, value, name, value} pairs
            %                   that should be given to the view.
            
            viewPvPairs = {};
            
            % Properties from Super
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj, propertyNames), ...
                ];
            
            if(any(strcmp('SelectedNodes', propertyNames)))
                
                newValue = [];
                % Convert Nodes to node ids
                % Use for loop because get does not return consistent
                % results for one node vs multiple nodes
                for index = 1:numel(obj.Model.SelectedNodes)
                    newValue = [newValue, get(obj.Model.SelectedNodes(index), 'NodeId')];
                end
                
                viewPvPairs = [viewPvPairs, ...
                    {'SelectedNodes', newValue}, ...
                    ];
            end
            if (any(strcmp('NodeId', propertyNames)))
               % This code is intended to be hit only at construction
               % NodeId should never change after construction
               % The view will be seeded with the information about the
               % last node existing at construction so it knows how long to
               % wait to execute cached events about expand/collapse/scroll                
               if ~isempty(obj.Model.QueuedActionToView) && ~isempty(obj.Model.Children)
                   
                    viewPvPairs = [viewPvPairs, ...
                        {'TreeEvents', obj.Model.QueuedActionToView}, ...
                    ]; 
                    obj.Model.QueuedActionToView = cell.empty;
                end
            end
        end
        
        function handleEvent(obj, src, event)
            % Handle Events coming from the client
            %
            % Note, other icon components (button)handles design time
            % events for Icon like 'PropertyEditorEdited', but
            % that is not yet implemented for the TreeNode so that does
            % not appear here for now.
            
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            
            if(any(strcmp(event.Data.Name, {'SelectionChanged'})))
                % Forwards the event to be handled by the Tree
                
                % Store the previous value
                previousValue = obj.Model.SelectedNodes;
                
                selectedNodes = event.Data.SelectedNodes;
                
                if isempty(selectedNodes)
                    newValue = [];
                else
                    newValue = obj.Model.getNodesById(event.Data.SelectedNodes);
                end
                
                % Create event data
                eventData = matlab.ui.eventdata.SelectedNodesChangedData(newValue, previousValue);
                
                % Update the model and emit an event which in turn will
                % trigger the user callback
                obj.handleUserInteraction('SelectionChanged', {'SelectionChanged', eventData, 'PrivateSelectedNodes', newValue});
            end
            
        end
    end
    methods(Access = {?matlab.ui.container.internal.controller.TreeNodeController})
        function handleDescendantEvent(obj, node, src, event)
            
            % Assemble eventdata
            % Fire Tree Callback
            eventName = event.Data.Name;
            
            switch(eventName)
                case('NodeTextChanged')
                    
                    % Store the previous value
                    previousValue = node.Text;
                    
                    newValue = event.Data.Text;
                    
                    % Create event data
                    eventData = matlab.ui.eventdata.NodeTextChangedData(node, newValue, previousValue);
                    
                    % Update the model and emit an event which in turn will
                    % trigger the user callback
                    if (~isequal(previousValue, newValue))
                        % Model updates would typically be done in the
                        % handleUserInteraction, but the update is on the
                        % node and the callback is on the tree.  
                        node.Text = newValue;
                        obj.handleUserInteraction(eventName, {eventName, eventData});
                    end
                    
                case('NodeExpanded')
                    
                    % Create event data
                    eventData = matlab.ui.eventdata.NodeExpandedData(node);
                    
                    % Update the model and emit an event which in turn will
                    % trigger the user callback
                    obj.handleUserInteraction(eventName, {eventName, eventData});
                    
                case('NodeCollapsed')
                    
                    % Create event data
                    eventData = matlab.ui.eventdata.NodeCollapsedData(node);
                    
                    % Update the model and emit an event which in turn will
                    % trigger the user callback
                    obj.handleUserInteraction(eventName, {eventName, eventData});
            end
        end
    end
end

