classdef AbstractActions < handle
    % ABSTRACTACTIONS Class definition for actions on a result in the Fixed-Point Tool.

    % Copyright 2012-2017 The MathWorks, Inc.

    properties(SetAccess=private, GetAccess=protected)
        Actions
        Result
    end

    methods

        function this = AbstractActions(result)
            this.Result = result;
        end

        function actions = getActions(this)
            this.deleteActions;
            actions = this.createActions;
        end

        function delete(this)
            deleteActions(this);
            this.Actions = [];
        end

        invokeMethod(this, methodName)
        
        function dataAvailable = isHistogramAvailable(this)
           dataAvailable = ~isempty(this.Result.HistogramData) && ~isempty(this.Result.HistogramData.BinData);
        end
    end

    methods (Access = private)
        function actions = createActions(this)
            defaultActions = this.getDefaultActions;
            childActions = this.getSupportedActions;
            actions = [defaultActions childActions];
            this.Actions = actions;
        end

        function actions = getDefaultActions(~)
            clearAction = fxptds.Action('', fxptui.message('actionRESULTSCLEARSELRUN'), ...
                'FPT_results_clearselectedrun','fxptds.AbstractActions.selectAndInvoke(''clearSelectedRun'')');

            clearAction(end+1) = fxptds.Action('', fxptui.message('actionRESULTSCLEARALLRUN'), ...
                'FPT_results_clearallruns','fxptds.AbstractActions.selectAndInvoke(''clearAllRuns'')');

            actions = clearAction;
        end

        function deleteActions(this)
            for i = 1:length(this.Actions)
                delete(this.Actions(i));
            end
        end

    end

    methods(Access=protected)
        function clearSelectedRun(this)
            me = fxptui.getexplorer;
            if isempty(me); return; end
            runName = this.Result.getRunName;
            me.clearresults(runName);
            me.refreshDetailsDialog;
        end

        function clearAllRuns(~)
            me = fxptui.getexplorer;
            if isempty(me); return; end
            me.clearresults;
            me.refreshDetailsDialog;
        end

        function hiliteInEditor(this)
            hiliteInEditor(this.Result.getUniqueIdentifier);
        end

        function unhilite(this)
            unhilite(this.Result.getUniqueIdentifier);
        end
        function actions = getHiliteAction(~)
            actions = fxptds.Action('', fxptui.message('actionHILITESYSTEM'), ...
                'FPT_Hilite_Element','fxptds.AbstractActions.selectAndInvoke(''hiliteInEditor'')');
        end

        function actions = getUnhiliteAction(~)
            actions = fxptds.Action('', fxptui.message('actionHILITECLEAR'), ...
                'FPT_Hiliteclear_Element','fxptds.AbstractActions.selectAndInvoke(''unhilite'')');
        end

        function action = getHiliteDTGroupAction(~)
            action =  fxptds.Action('', fxptui.message('actionHILITEDTGROUP'), ...
                'FPT_simulink_hilitedtgroup',...
                'fxptds.AbstractActions.selectAndInvoke(''hiliteDTGroup'')');
        end

        function hiliteSystem(this, resultList)
            % hiliteSystem will open the containing system before hiliting the block
            for i = 1:numel(resultList)
                result = resultList{i};
                if isa(result,'fxptds.MATLABVariableResult')
                    % MATLAB variables can be hilited only in the editor
                    result.getUniqueIdentifier.hiliteInEditor;
                else
                    owner = result.getUniqueIdentifier.getObject;
                    this.hiliteImmediateOwners(owner);
                end
            end
        end

        function plotHistogram(this)
            if this.Result.IsPlottable || this.isHistogramAvailable
                this.Result.plotHistogramInFigure;
            else
                fxptui.showdialog('histnotplottable');
            end
        end

    end

    methods (Abstract, Access = protected)
        actions = getSupportedActions(this);
    end

    methods(Access = protected)
        function hiliteImmediateOwners(~,owners)
            % hiliteImmediateOwners gets the owner from the result and highlights it if
            % possible.
            %
            % Cannot get rid of the try catch as there is no easy way to tell what can and
            % cannot be highlighted. Need an API for this!
            for iOwner = 1:numel(owners)
                owner = owners(iOwner);
                try
                    if isa(owner, 'Stateflow.Data')
                        % Highlight the owning chart instead.
                        fxptds.highlightChartWithStateflowData(owner);
                    else
                        % Highlight the block
                        owner.hilite;
                    end
                catch
                    % The object cannot be highlighted
                end
            end
        end

        function nonObjectSimulinkResults = getHiliteableResults(~,results)
            % getHiliteableResults filters out AbstractSimulinkObjectResult from a list of
            % results. AbstractSimulinkObjectResult cannot be highlighted.
            indexNonObjectSimulinkResults = ...
                cellfun(@(x) ~isa(x,'fxptds.AbstractSimulinkObjectResult') , ...
                results);

            nonObjectSimulinkResults = results(indexNonObjectSimulinkResults);
        end
    
        function hiliteDTGroup(this)
            % turn off highlighting off all currently opened models
            SimulinkFixedPoint.AutoscalerUtils.unhiliteAll();
            
            model = this.Result.getHighestLevelParent;
            if ~isempty(model)
                
                % open the model that the result is in
                open_system(model, 'force');
                
                % hilight owning block first
                this.highlightOwningBlock(this.Result);
                
                % highlight all group results
                this.highlightGroupResults(this.Result, model);
                
            end
            
        end
        
        function highlightGroupResults(this, result, model)
            fptRepository = fxptds.FPTRepository.getInstance;
            dataset = fptRepository.getDatasetForSource(model);
            runObj = dataset.getRun(result.getRunName);
            if ~isempty(runObj)
                % get the group for the result
                group = runObj.dataTypeGroupInterface.getGroupForResult(result);
                
                % get the group members
                results = group.getGroupMembers();
                
                % Filtering out results that cannot be highlighted in Simulink
                % diagram
                nonObjectSimulinkResults = this.getHiliteableResults(results);
                
                % Highlighting the results
                this.hiliteSystem(nonObjectSimulinkResults);
            end
        end
        
        function highlightOwningBlock(this, result)
            owner = result.getUniqueIdentifier.getObject;
            this.hiliteImmediateOwners(owner)
        end
        
    end

    methods (Static)
        function selectAndInvoke(methodName, varargin)
            me = fxptui.getexplorer;
            if isempty(me)
                if nargin > 1 && isa(varargin{1},'fxptds.AbstractResult')
                    varargin{1}.getActionHandler.invokeMethod(methodName);
                else
                    return;
                end
            elseif nargin > 1 && isa(varargin{1},'fxptds.AbstractResult')
                varargin{1}.getActionHandler.invokeMethod(methodName);
            else
                selection = me.getSelectedListNodes;
                if isempty(selection)
                    fxptui.showdialog('generalnoselection');
                else
                    selection.getActionHandler.invokeMethod(methodName);
                end
            end
        end
    end
end
