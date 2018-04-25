classdef (Hidden) TreeNodeController < ...
        matlab.ui.control.internal.controller.ComponentController & ...
        matlab.ui.control.internal.controller.mixin.IconableComponentController & ...
        matlab.ui.container.internal.controller.mixin.ExpandableComponentController
    
    
    
    % Copyright 2016 The MathWorks, Inc.
    methods
        function obj = TreeNodeController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
            obj@matlab.ui.container.internal.controller.mixin.ExpandableComponentController(varargin{:});
            
            % This will have the controller attempt to convert NodeData to
            % a number when possible
            %
            % If not a number, then the value will still be forwarded to
            % the component model (and work for things like strings)
            obj.NumericProperties{end+1} = 'NodeData';
        end
        
        function viewPvPairs = getPositionPropertiesForView(obj, propertyNames)
            % Gets all properties for view based related to Size,
            % Location, etc...
            % TreeNode has no position properties.
            viewPvPairs = {};
        end
        
        function additionalProperties = getAdditonalPositionPropertyNamesForView(obj)
            
            % These are non - public properties that need to be explicitly
            % added
            additionalProperties = {};
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
            
            % Icon Specific
            viewPvPairs = [viewPvPairs, ...
                getIconPropertiesForView(obj, propertyNames);
                ];
            
        end
        
        
        function handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handles properties changed from client
            
            unHandledProperties = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, changedPropertiesStruct);
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, unHandledProperties);
        end
        
        function handleEvent(obj, src, event)
            % Handle Events coming from the client
            %
            % Note, other icon components (button)handles design time
            % events for Icon like 'PropertyEditorEdited', but
            % that is not yet implemented for the TreeNode so that does
            % not appear here for now.
            
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, src, event);
            
            % already handled PropertyEditorEdited for Icon
            if ~(strcmp(event.Data.Name, 'PropertyEditorEdited') && strcmp(event.Data.PropertyName, 'Icon'))
                handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            end
            
            if(any(strcmp(event.Data.Name, {'NodeTextChanged', 'NodeExpanded', 'NodeCollapsed'})))
                % Forwards the event to be handled by the Tree
                
                % Forward the information up the hierarchy so it can be
                % handled by the tree.
                node = obj.Model;
                obj.handleDescendantEvent(node, src, event);
            end
        end
        
        function handleDescendantEvent(obj, node, src, event)
            % Forward treenode events up the hierarchy to be eventually
            % handled by the Tree.
            if ~isempty(obj.ParentController)
                obj.ParentController.handleDescendantEvent(node, src, event);
            end
        end
    end
end