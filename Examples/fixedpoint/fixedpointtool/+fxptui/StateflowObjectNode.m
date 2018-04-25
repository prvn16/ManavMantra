classdef StateflowObjectNode < fxptui.SubsystemNode
% STATEFLOWOBJECTNODE Class definition for the tree node representing a stateflow object
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    methods
        function this = StateflowObjectNode(blkObj)
            if nargin  == 0
                argList = {};
            else
                argList = {blkObj};
            end
            this@fxptui.SubsystemNode(argList{:});
        end
    end
    
    methods(Hidden)
        
        function setLogging(this, state, scope, depth)
            if(strcmp(scope, 'All')) || strcmp(scope, 'NAMED') || strcmp(scope, 'UNNAMED')
                hch = this.getHierarchicalChildren;
                for k = 1:length(hch)
                    if isa(hch(k).DAObject,'Simulink.SubSystem')
                        % Turn on all signals in that system and then all signals under
                        hch(k).setLogging(state,scope,1);
                        hch(k).setLogging(state,scope,depth);
                    end
                end
            end
        end
        
        function b = hasSubsystemInHierarchy(this)
            % Get the SF object that the node points to.
            ch = this.DAObject.getHierarchicalChildren;
            if isempty(ch); 
                b = false;
                return;
            end
            b = ~isempty(find(ch,'-isa','Simulink.SubSystem'));
        end
        
        function b = isNodeSupported(~)
            b = false;
        end
        
        function [selection, list] = getDTO(~)
            selection = fxptui.message('labelDisabledDatatypeOverride');
            list = {selection};
        end
        
        function [selection,  list] = getDTOAppliesTo(~)
            %get the list of valid settings from the underlying object
            list = { ...
                fxptui.message('labelAllNumericTypes'), ...
                fxptui.message('labelFloatingPoint'), ...
                fxptui.message('labelFixedPoint')};
            selection = list{1};
        end
        
        function [selection, list] = getMMO(~)
            %GETMMO   Get the text for fixed-point instrumentation.
            selection = fxptui.message('labelNoControl');
            list = {selection};
        end
    end
    
    methods(Access=protected)
        function addListeners(this)
            this.SLListeners = handle.listener(this.DAObject, 'NameChangeEvent', @(s,e)fireHierarchyChanged(this));
        end
        
        function key = getKeyAsDoubleType(this)
        % returns the handle to the Simulink object as a double to be used as a key on the maps.
            key = double(this.DAObject.Id);
        end
        
        function createActionHandler(this)
            this.ActionHandler = fxptui.StateflowObjectNodeActions(this);
        end
    end
end
