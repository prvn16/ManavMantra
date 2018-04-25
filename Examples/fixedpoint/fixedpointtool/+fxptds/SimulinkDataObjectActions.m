classdef SimulinkDataObjectActions < fxptds.SimulinkActions
    
    %   Copyright 2017 The MathWorks, Inc.
    methods
        function this = SimulinkDataObjectActions(result)
            this@fxptds.SimulinkActions(result);
        end        

        function invokeMethod(this, methodName)
            this.(methodName);
        end
    end
    
    methods(Access=protected)        
        function actions = getSupportedActions(this)
            actions = fxptds.Action.empty;
            actions = addRunCompareAction(this, actions);
            actions = addHiliteClient(this, actions);
            actions = addHiliteDTGroupAction(this, actions);
            actions = addUnhiliteAction(this, actions);
        end
        
        function actions = addRunCompareAction(this, actions)
            actions(end+1) = this.getRunCompareAction;
        end
        
        function actions = addHiliteClient(~, actions)
            actions(end+1) = fxptds.Action('', fxptui.message('actionHILITEDataObjectClients'), ...
                'FPT_simulink_hiliteDataObject',...
                'fxptds.AbstractActions.selectAndInvoke(''hiliteClientBlocks'')');
        end  
        
        function actions = addHiliteDTGroupAction(this, actions)
            if hasDTGroup(this.Result)
                actions(end+1) = this.getHiliteDTGroupAction;
            end
        end
        
        function actions = addUnhiliteAction(this, actions)
            actions(end+1) = this.getUnhiliteAction;
        end
        
        function unhilite(~)
            SimulinkFixedPoint.AutoscalerUtils.unhiliteAll;
        end
    end
    
    methods(Access=protected)
        function hiliteClientBlocks(this)
            % Unhilight everything
            this.unhilite;
            
            % Get client blocks
            blockList = this.Result.getClientBlocks;
            
            % hilite_system will open the containing system before hiliting the block
            for iBlock = 1:numel(blockList)
                this.hiliteImmediateOwners(blockList{iBlock});
            end
        end
    end
end