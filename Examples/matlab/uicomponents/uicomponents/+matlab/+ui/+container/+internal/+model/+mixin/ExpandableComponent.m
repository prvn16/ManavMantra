classdef (Hidden) ExpandableComponent < handle & appdesservices.internal.interfaces.model.AbstractModelMixin
    
    % ExpandableComponent provides the functionality to expand or collapse
    % TreeNodes
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function obj = ExpandableComponent(varargin)
            
        end
        
    end
    
    methods(Access = 'public')
        function expand(obj, varargin)
            % EXPAND(OBJ, flag) - expand nodes specified in obj
            %
            % obj - matlab.ui.container.TreeNode object or
            % matlab.ui.container.Tree
            %
            % flag - optional second input, when value is 'all', all descendents
            % descendents of the specified nodes will be expanded.
            
            validateattributes(obj,...
                {'matlab.ui.container.internal.model.mixin.ExpandableComponent'}, {});
            narginchk(1, 2);
            
            
            obj.processExpandableMethod('expand', @expand, varargin{:})
            
        end
        
        function collapse(obj, varargin)
            % COLLAPSE(OBJ, flag) - collapse nodes specified in
            % treeNodes.
            %
            % obj - matlab.ui.container.TreeNode object or
            % matlab.ui.container.Tree
            %
            % flag - optional second input, when value is 'all', all descendents
            % descendents of the specified nodes will be expanded.
            
            validateattributes(obj,...
                {'matlab.ui.container.internal.model.mixin.ExpandableComponent'}, {});
            narginchk(1, 2);
            
            obj.processExpandableMethod('collapse', @collapse, varargin{:})
            
        end
    end
    
    methods (Access = private)
        
        function nodes = getExpandableNodes(obj, flag)
            % Return all nodes with children to be expanded/collapsed.
            if isa(obj, 'matlab.ui.container.Tree')
                nodes = allchild(obj);
            else
                nodes = obj;
            end
            
            if strcmp(flag, 'all')
                % Search all descendents that do not currently have
                % children (implied here is that the view would have
                % an expansionhandle)
                nodes = findall(nodes, '-not', 'Children', matlab.graphics.GraphicsPlaceholder.empty());
            else
                % Search only the nodes array for noddes that do not
                % currently have children (implied here is that the view
                % would have an expansion handle)
                nodes = findobj(nodes, 'flat', '-not', 'Children', matlab.graphics.GraphicsPlaceholder.empty());
            end
        end
        
        function processExpandableMethod(obj, eventName, eventHandle, flag)
            % Shared function for expand and collapse
            % eventName = 'expand' or 'collapse'
            % eventHandle = @expand, @collapse
            % flag, 'all', or nothing
            
            if nargin == 4
                validString = validatestring(flag, {'all'});
            else
                validString = 'single';
            end
            
            if isempty(obj.getController)
                if ~isempty(allchild(obj))
                    % View has not been created, cache any instructions
                    
                    nodes = obj.getExpandableNodes(validString);
                    
                    if ~isempty(nodes)
                        eventData = {eventName,...
                            [nodes.NodeId]};
                        handleNodeEvent(obj, eventData);
                    end
                end
            else
                eventHandle(obj.getController(), obj, validString);
            end
            
        end
    end
    methods (Abstract, Access = {?matlab.ui.container.internal.model.ContainerModel, ...
            ?matlab.ui.container.internal.model.mixin.ExpandableComponent})
        
        handleNodeEvent(obj, eventData)
        
    end
end


