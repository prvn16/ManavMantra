classdef MATLABVariableActions < fxptds.AbstractActions
    %MATLABVariableActions
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods
        function this = MATLABVariableActions(result)
            this@fxptds.AbstractActions(result);
        end % MATLABVariableActions
        
        function invokeMethod(this, methodName)
            this.(methodName);
        end % invokeMethod
    end % methods
    
    methods(Access = protected)
        function actions = getSupportedActions(this)
            actions = [];
            if this.isHistogramAvailable
                actions = this.getPlottingActions;
            end
            
            actions = [actions this.getHiliteAction];
            
            if hasDTGroup(this.Result)
                actions(end+1) = this.getHiliteDTGroupAction;
            end
            
            codeViewAction = this.getCodeViewAction();
            if ~isempty(codeViewAction)
                actions(end+1) = this.getCodeViewAction();
            end
        end % getSupportedActions
        
    end % methods(Access = protected)
    
    methods(Access = private)
        function action = getCodeViewAction(~)
            if fxptui.isMATLABFunctionBlockConversionEnabled() && coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled('table')
                action = fxptds.Action( ...
                    coder.internal.mlfb.gui.MlfbUtils.getCodeViewActionIcon(), ...
                    coder.internal.mlfb.gui.message('actionCodeViewShowVariable'), ...
                    'FPT_table_code_view', ...
                    'coder.internal.mlfb.gui.fxptToolShowResultInCodeView;');
            else
                action = [];
            end
        end
        
        function actions = getPlottingActions(~)
            actions = fxptds.Action(fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'plothist.png'),...
                fxptui.message('actionVIEWHISTINFIGURE'),'FPT_view_histinfigure',...
                'fxptds.AbstractActions.selectAndInvoke(''plotHistogram'')');
            
        end
    end
    
end % classdef

% LocalWords:  mlfb fxpt
