function treeNodeComponent = uitreenode(varargin)
%UITREENODE Create tree node component 
%   node = UITREENODE creates a tree node inside a tree within a new figure
%   window and returns the TreeNode object. MATLAB calls the uifigure
%   function to create the figure.
%
%   node = UITREENODE(parent) creates a tree node in the specified parent
%   container. The parent container can be a Tree or TreeNode object.
%
%   node = UITREENODE(parent,sibling) creates a tree node in the specified
%   parent container, after the specified sibling node.
%
%   node = UITREENODE(parent,sibling,location) creates a tree node and 
%   places it before or after the sibling node. Specify location as 'before'
%   or 'after'.
%
%   node = UITREENODE( ___ ,Name,Value) specifies TreeNode property values
%   using one or more Name,Value pair arguments. Specify Name,Value as the
%   last set of arguments when you use any of the previous syntaxes.
%
%   TreeNode supported functions:
%      collapse           - Collapse tree node
%      expand             - Expand tree node
%      move               - Move tree node
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
%   See also UIFIGURE, UITREE

%   Copyright 2017 The MathWorks, Inc.

% If using the 'v0' switch, use the undocumented uitree
if (usev0tree(varargin{:}))
    [treeNodeComponent] = matlab.ui.internal.uitreenode_deprecated(varargin{2:end});
    
else
    
    % Parse custom uitreenode inputs
    componentCreationArgs = varargin;
    
    p = inputParser;
    p.KeepUnmatched = true;
    
    addOptional(p, 'Parent', [], @(x)isa(x, 'matlab.ui.container.TreeNode')||isa(x, 'matlab.ui.container.Tree'));
    addOptional(p, 'Target', [], @(x)isa(x, 'matlab.ui.container.TreeNode'));
    addOptional(p, 'Direction', 'after', @(x)strcmp(x, 'before')||strcmp(x, 'after'));
    
    targetNode = [];
    moveMethod = [];
    messageObj = [];
    
    try
        % This code handles the following scenarios:
        % uitreenode(parent, targetNode)
        % uitreenode(parent, targetNode, 'after|before')
        parse(p, componentCreationArgs{:})
        
        if ~any(strcmp(p.UsingDefaults, 'Parent'))
            componentCreationArgs = {p.Results.Parent};
            
            if ~any(strcmp(p.UsingDefaults, 'Target'))
                
                targetNode = p.Results.Target;
                
                % Perform deeper validation here (and not in the parser) in
                % order to have the control over informative error messages
                if ~isscalar(targetNode)
                    % throw error
                    messageObj =  message('MATLAB:ui:components:requiresScalarTargetTreeNode');
                
                elseif ~isequal(p.Results.Parent, p.Results.Target.Parent)
                    % The parent must be the same as the parent of the target
                    messageObj = message('MATLAB:ui:components:targetParentConflictsWithConstructionTarget');
                    
                end
                
                
                if isequal(p.Results.Direction, 'after')
                    
                    children = allchild(targetNode.Parent);
                    if targetNode ~= children(end)
                        % Only specify a moveMethod if the targetNode and
                        % direction are different than the default behavior
                        
                        moveMethod = @move;
                    end
                else
                    moveMethod = @(node, target)move(node, target, 'before');
                end
                
            end
            
        end
        componentCreationArgs = [componentCreationArgs, {p.Unmatched}];
    catch
        
    end
    
    if ~isempty(messageObj)
        error('MATLAB:ui:TreeNode:unknownInput', messageObj.getString());
        
    end
    % Classic component creation
    className = 'matlab.ui.container.TreeNode';
    
    messageCatalogID = 'uitreenode';
    
    try
        treeNodeComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
            className, ...
            messageCatalogID,...
            componentCreationArgs{:});
    catch ex
        
        % Customize invalid parent message because treenode has restricted
        % parenting; the shared message is not accurate
        if strcmp(ex.identifier, 'MATLAB:ui:uitreenode:invalidParent')
            messageObj = message('MATLAB:ui:components:invalidTreeNodeParent', ...
                'Parent');
            
            % Use string from object
            messageText = getString(messageObj);
            
        else
            messageText = ex.message;
            
        end
        
        error('MATLAB:ui:TreeNode:unknownInput', ...
            messageText);
    end
    
    
    % If a target was specified, move the newly created node
    if ~isempty(targetNode) && ~isempty(moveMethod)
        moveMethod(treeNodeComponent, targetNode);
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