classdef (Hidden) ExpandableComponentController < handle & ...
        appdesservices.internal.interfaces.controller.AbstractControllerMixin & ...
        matlab.ui.internal.componentframework.services.optional.ControllerInterface
    
    % ExpandableComponentController provides the functionality to 
    % expand or collapse TreeNodes
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function obj = ExpandableComponentController(varargin)
        end
        
    end
    
    methods(Access = 'public')
        function expand(obj, model, flag)
            % EXPAND(OBJ, flag) - expand nodes specified in
            % treeNodes.
            %
            % model - matlab.ui.container.TreeNode object or
            % matlab.ui.container.Tree
            %
            % flag - optional input, when value is 'all', all descendents
            % of the specified nodes will be expanded.
            
            obj.ProxyView.sendEventToClient(...
                        'expand',...
                        { ...
                    'NodeId', model.NodeId, ...
                    'Flag', flag, ...
                    } ...
                    );
                       
        end
        
        function collapse(obj, model, flag)
            % COLLAPSE(OBJ, flag) - collapse nodes specified in
            % treeNodes.
            %
            % model - matlab.ui.container.TreeNode objects
            %
            % flag - optional input, when value is 'all', all descendents
            % of the specified nodes will be expanded.
            
            obj.ProxyView.sendEventToClient(...
                        'collapse',...
                        { ...
                    'NodeId', model.NodeId, ...
                    'Flag', flag, ...
                    } ...
                    );
        end
    end
end


