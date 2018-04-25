classdef StateflowActions < fxptds.SimulinkActions
% STATEFLOWACTIONS class that defines the actions for Stateflow based results in Fixed-Point Tool.

% Copyright 2013 MathWorks, Inc


    methods
        function this = StateflowActions(result)
            this@fxptds.SimulinkActions(result);
        end
    end
    
    methods(Access=protected)
        function actions = getSupportedActions(this) 
            if isStateflowChart(this.Result.getUniqueIdentifier)
                actions = getSupportedActions@fxptds.SimulinkActions(this);
            else
                if this.Result.isPlottable
                    actions = this.getPlottingActions;
                else
                    actions = this.getRunCompareAction;
                end
                if hasDTGroup(this.Result)
                    actions = [actions this.getHiliteDTGroupAction];
                    actions = [actions this.getUnhiliteAction];
                end
                
                if isResultValid(this.Result)
                    actions = [actions this.getOpenDialogAction];
                end
            end
        end
    end
end
