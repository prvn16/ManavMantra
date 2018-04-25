classdef Node < matlab.mixin.Heterogeneous & handle
    % Base class for managing MCOS toolstrip component hierarchy.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %%
    properties (Hidden, Dependent, GetAccess = public, SetAccess = protected)
        % Parent of the node (matlab.ui.internal.toolstrip.base.node, default = matlab.ui.internal.toolstrip.base.node.empty)
        Parent
        % Children of the node (matlab.ui.internal.toolstrip.base.node array, default = matlab.ui.internal.toolstrip.base.node.empty)
        Children
    end
    
    %%
    properties (Access = private)
        % Parent of the node (matlab.ui.internal.toolstrip.base.node, default = matlab.ui.internal.toolstrip.base.node.empty)
        Parent_
        % Children of the node (matlab.ui.internal.toolstrip.base.node array, default = matlab.ui.internal.toolstrip.base.node.empty)
        Children_
    end
    
    %%
    methods
        
        %% Parent: Get/Set
        function value = get.Parent(this)
            % GET function for the Parent property.
            value = this.Parent_;
            if isempty(value)
                value = matlab.ui.internal.toolstrip.base.Node.empty; % default
            end
        end
        function set.Parent(this, value)
            % SET function for the Parent property.
            if isempty(value)
                value = [];
            end
            this.Parent_ = value;
        end
        
        %% Children: Get/Set
        function value = get.Children(this)
            % GET function for Children property.
            value = this.Children_;
            if isempty(value)
                value = matlab.ui.internal.toolstrip.base.Node.empty; % default
            end
        end
        function set.Children(this, value)
            % SET function for Children property.
            if isempty(value)
                value = [];
            end
            this.Children_ = value;
        end
        
    end
    
    % ----------------------------------------------------------------------------
    % Protected methods
    methods (Hidden, Access = protected)
        
        function tree_add(parent, node)
            %% Append the node as the last children of the parent
            % obtain the current parent of the node
            p = node.Parent;
            if p == parent
                % Quick return if node already parented to this parent.
                return
            end
            % Remove node from the current parent if any.
            if ~isempty(p)
                tree_remove(p, node)
            end
            % set new parent
            node.Parent = parent;
            % append the node as the last children of the parent
            parent.Children(end+1) = node;
        end
        
        function tree_insert(parent, node, idx)
            %% Insert the node as a child of parent at a desired position
            % obtain the current parent of the node
            p = node.Parent;
            if isequal(p,parent) || ~(idx>=1 && idx<=length(parent.Children)+1)
                % Quick return if node already parented to this parent or idx is invalid.
                return
            end
            % Remove node from the current parent if any.
            if ~isempty(p)
                tree_remove(p, node)
            end
            % set new parent
            node.Parent = parent;
            % insert the node as a child of parent at a desired position
            parent.Children = [parent.Children(1:idx-1) node parent.Children(idx:end)];
        end
        
        function tree_remove(parent, node)
            %% Remove the node from the children of the parent node
            % find the node in the children list.
            siblings = parent.Children;
            k = length(siblings);
            while (k > 0) && (siblings(k) ~= node)
                k = k-1;
            end
            % remove node reference from the parent
            if k > 0
                parent.Children(k) = [];
            end
            % obtain the current parent of the node
            p = node.Parent;
            % remove the parent reference from the node
            if p == parent
                node.Parent = [];
            end
        end
    
        function tree_move(parent, srcidx, dstidx)
            %% Moves child component at location SRCIDX to destination DSTIDX in original list.
            if srcidx>=1 && srcidx<=length(parent.Children) && dstidx>=1 && dstidx<=length(parent.Children)
                node = parent.Children(srcidx);
                parent.Children(srcidx) = [];
                parent.Children = [parent.Children(1:dstidx-1) node parent.Children(dstidx:end)];
            end
        end
        
        function obj = tree_flat_search(parent, arg)
            %% Return the first component with the specified tag or index if it is among the direct children.  Return [] if no such component is found.
            children = parent.Children;
            obj = [];
            arg = matlab.ui.internal.toolstrip.base.Utility.hString2Char(arg);
            if ischar(arg)
                for k = 1:length(children)
                    if strcmp(children(k).Tag, arg)
                        obj = children(k);
                        break;
                    end
                end
            else
                obj = children(arg);
            end
        end
        
        function objs = tree_flat_search_all(parent, arg)
            %% Return all the components with the specified tag if they are among the direct children.  Return [] if no such component is found.
            children = parent.Children;
            objs = [];
            for k = 1:length(children)
                if strcmp(children(k).Tag, arg)
                    objs = [objs; children(k)]; %#ok<*AGROW>
                end
            end
        end
        
        function obj = tree_deep_search(parent, tag)
            %% Return the first component with the specified tag if it is in the hierarchy.  Return [] if no such component is found.
            obj = tree_flat_search(parent, tag);
            if isempty(obj)
                children = parent.Children;
                for k = 1:length(children)
                    obj = tree_deep_search(children(k), tag);
                    if ~isempty(obj)
                        break;
                    end
                end
            end
        end
        
        function objs = tree_deep_search_all(parent, tag)
            %% Return all the components with the specified tag if they are in the hierarchy.  Return [] if no such component is found.
            objs = tree_flat_search_all(parent, tag);
            children = parent.Children;
            for k = 1:length(children)
                objs = [objs; tree_deep_search_all(children(k), tag)];
            end
        end
    end

end