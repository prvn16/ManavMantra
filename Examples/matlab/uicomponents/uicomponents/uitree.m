function [treeComponent, varargout] = uitree(varargin)
%UITREE Create tree component 
%   t = UITREE creates a tree in a new figure and returns the Tree object.
%   MATLAB calls the uifigure function to create the figure.
%
%   t = UITREE(Name,Value) specifies Tree property values using one or more
%   Name,Value pair arguments.
%
%   t = UITREE(parent) creates a tree in the specified parent container.
%   The parent container can be a Figure created using the uifigure
%   function, or one of its child containers: Tab, Panel, or ButtonGroup.
%
%   t = UITREE(parent,Name,Value) creates the tree in the specified
%   container and sets one or more Tree property values.
%
%   Tree supported functions:
%      collapse           - Collapse tree node
%      expand             - Expand tree node
%      scroll             - Scroll to location within tree
%
%   Example: Tree with Nested Nodes
%      f = uifigure;
%      tree = uitree(f);
%
%      % Assign Tree callback in response to node selection
%      tree.SelectionChangedFcn = @(src, event)display(event);
%
%      % First level nodes
%      category1 = uitreenode(tree,'Text','Runners','NodeData',[]);
%      category2 = uitreenode(tree,'Text','Cyclists','NodeData',[]);
%
%      % Second level nodes.
%      % Node data is age (y), height (m), weight (kg)
%      p1 = uitreenode(category1,'Text','Joe','NodeData',[40 1.67 58] );
%      p2 = uitreenode(category1,'Text','Linda','NodeData',[49 1.83 90]);
%      p3 = uitreenode(category2,'Text','Rajeev','NodeData',[25 1.47 53]);
%      p4 = uitreenode(category2,'Text','Anne','NodeData',[88 1.92 100]);
%      
%      % Expand tree to see all nodes
%      expand(tree, 'all');
%
%   See also UIFIGURE, UITREENODE

%   Copyright 2017 The MathWorks, Inc.


% If using the 'v0' switch, use the undocumented uitree
if (usev0tree(varargin{:}))
    [treeComponent, container] = matlab.ui.internal.uitree_deprecated(varargin{2:end});
    varargout = {container};
    
else
    
    className = 'matlab.ui.container.Tree';
    
    messageCatalogID = 'uitree';
    
    try
        treeComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
            className, ...
            messageCatalogID,...
            varargin{:});
    catch ex
        error('MATLAB:ui:Tree:unknownInput', ...
            ex.message);
    end
end
end

function result = usev0tree(varargin)

if (isempty(varargin))
    result = false;
else
    if ((ischar(varargin{1}) || isstring(varargin{1})) && (strcmpi(varargin{1}, 'v0')))
        result = true;
    else
        result = false;
    end
end
end