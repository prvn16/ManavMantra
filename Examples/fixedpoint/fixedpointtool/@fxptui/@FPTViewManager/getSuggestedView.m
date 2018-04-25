function [fptView, reason] = getSuggestedView(this)
% GETSUGGESTEDVIEW returns the desired view for the workflow.

% Copyright 2014 The MathWorks, Inc.

fptView = [];
reason = '';
workflow_mode = this.SuggestedViewName;
activeView = this.getActiveView;
switch workflow_mode
    case 'sim_view'
        if ~isempty(activeView) && strcmp(activeView.Name,fxptui.message('labelViewDataCollection'))
            fptView = activeView;
        else
            fptView = this.getView(fxptui.message('labelViewSimulation')); 
        end
        reason = fxptui.message('labelViewSimSuggestion');
        
    case 'derived_view'
        if ~isempty(activeView) && strcmp(activeView.Name,fxptui.message('labelViewDataCollection'))
            fptView = activeView;
        else
            fptView = this.getView(fxptui.message('labelViewDerivedMinMax'));
        end
        reason = fxptui.message('labelViewDeriveSuggestion');
        
    case 'data_collection'
        fptView = this.getView(fxptui.message('labelViewDataCollection')); 
        reason = fxptui.message('labelViewSimDeriveSuggestion');
        
    case 'datatyping_view_sim'
         if ~isempty(activeView) && strcmp(activeView.Name,fxptui.message('labelViewAutoscaling'))
              fptView = activeView;
         else
             fptView = this.getView(fxptui.message('labelViewAutoscalingSimMinMax')); 
         end
        reason = fxptui.message('labelViewProposeSimSuggestion');
        
    case 'datatyping_view_derived'
        if ~isempty(activeView) && strcmp(activeView.Name,fxptui.message('labelViewAutoscaling'))
            fptView = activeView;
        else
            fptView = this.getView(fxptui.message('labelViewAutoscalingDerivedMinMax')); 
        end
        reason = fxptui.message('labelViewProposeDeriveSuggestion');
        
    case 'datatyping_view_data'
        fptView = this.getView(fxptui.message('labelViewAutoscaling')); 
        reason = fxptui.message('labelViewProposeSimDeriveSuggestion');
end
