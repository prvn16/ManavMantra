classdef SimulinkActions < fxptds.AbstractActions
    % SIMULINKACTIONS Defines the actions supported on results from Simulink in Fixed-Point Tool
    
    % Copyright 2012-2016 The MathWorks, Inc.
    
    methods
        function this = SimulinkActions(result)
            this@fxptds.AbstractActions(result);
        end
        
        function invokeMethod(this, methodName)
            this.(methodName);
        end
    end
    
    methods(Access = protected)
        function actions = getSupportedActions(this)
            if this.Result.isPlottable || this.isHistogramAvailable
                actions = this.getPlottingActions;
            else
                actions = this.getRunCompareAction;
            end
            actions = [actions this.getHiliteAction this.getUnhiliteAction];
            if hasDTGroup(this.Result)
                actions(end+1) = this.getHiliteDTGroupAction;
            end
            if isResultValid(this.Result)
                actions(end+1) = this.getOpenDialogAction;
            end
            if hasOutput(this.Result)
                actions(end+1) =  this.getOpenSignalDialogAction;
            end
        end
        
        function action = getOpenDialogAction(~)
            action = fxptds.Action('', fxptui.message('actionOPENBLOCKDIALOG'), ...
                'FPT_simulink_openblkdlg',...
                'fxptds.AbstractActions.selectAndInvoke(''openBlockDialog'')');
        end
        
        function action = getOpenSignalDialogAction(~)
            action = fxptds.Action('', fxptui.message('actionOPENSIGNALDIALOG'), ...
                'FPT_simulink_opensigprops',...
                'fxptds.AbstractActions.selectAndInvoke(''openSignalDialog'')');
        end
        
        function actions = getPlottingActions(this)
            str = fxptui.message('actionVIEWTSINFIGURESDI');
            actions = fxptds.Action(fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'plot.png'), ...
                str, 'FPT_view_tsinfigure','fxptds.AbstractActions.selectAndInvoke(''plotSignal'')');
            
            actions(end+1) = fxptds.Action(fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'plothist.png'),...
                fxptui.message('actionVIEWHISTINFIGURE'),'FPT_view_histinfigure',...
                'fxptds.AbstractActions.selectAndInvoke(''plotHistogram'')');
            
            str = fxptui.message('actionVIEWDIFFINFIGURESDI');
            actions(end+1)= fxptds.Action(fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'plotdiff.png'), ...
                str,'FPT_view_diffinfigure','fxptds.AbstractActions.selectAndInvoke(''plotDifference'')');
            
            actions(end+1) = this.getRunCompareAction;
        end
        
        function action = getRunCompareAction(~)
            str = fxptui.message('actionVIEWRUNCOMPARESDI');
            action = fxptds.Action(fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'plotcompare.png'), ...
                str,'FPT_compare_runs','fxptds.AbstractActions.selectAndInvoke(''compareRuns'')');
        end
        
        function openBlockDialog(this)
            openDialog(this.Result.getUniqueIdentifier);
        end
        
    end
    
    methods (Access=protected)
        function openSignalDialog(this)
            openSignalPropertiesDialog(this.Result.getUniqueIdentifier);
        end
        
        function plotSignal(this)
            if this.Result.isPlottable
                fxptui.Plotter.plotSignal(this.Result.getTimeSeriesID);
            else
                fxptui.showdialog('notplottable');
            end
        end
        
        function plotDifference(this)
            dp = fxptui.DiffPlot('comparesignals');
            [runNames, ~] = dp.getRunsForDiff;
            selection = this.Result;
            model = selection.getHighestLevelParent;
            fptRepository = fxptds.FPTRepository.getInstance;
            ds = fptRepository.getDatasetForSource(model);
            if isempty([runNames{:}]) || ~selection.isPlottable
                fxptui.showdialog('notplottablediff');
            elseif ~selection.hasOneChannel && ~selection.hasOnlyOneValidChannel
                dp1 = fxptui.DiffPlot('selectchannelforcomparesignals');
                hDlg = DAStudio.Dialog(dp1);
                hDlg.enableApplyButton(true);
            elseif numel(runNames) > 1
                hDlg = DAStudio.Dialog(dp);
                hDlg.enableApplyButton(true);
            else
                res2 = ds.getRun(runNames{:}).getResultByID(selection.getUniqueIdentifier);
                idx = find(selection.getTimeSeriesID ~= 0);
                fxptui.Plotter.plotDifference(selection.getTimeSeriesID, res2.getTimeSeriesID, idx); %#ok<FNDSB>
            end
        end
        
        function compareRuns(this)
            selection = this.Result;
            model = selection.getHighestLevelParent;
            fptRepository = fxptds.FPTRepository.getInstance;
            ds = fptRepository.getDatasetForSource(model);
            runName = selection.getRunName;
            runObj = ds.getRun(runName);
            runID1 = runObj.getTimeSeriesRunID;
            
            % Signal logging results are in a seperate engine. Get the RunID from that
            % instance.
            if ~selection.isPlottable
                % Is selected signal is not plottable, then see if the run contains any
                % signals that can be compared.
                res = runObj.getResults;
                hasSignals = false;
                for i = 1:numel(res)
                    if res(i).isPlottable
                        hasSignals = true;
                        break;
                    end
                end
                if ~hasSignals
                    fxptui.showdialog('notcomparablerun');
                    return;
                end
            end
            
            dp = fxptui.DiffPlot('compareruns');
            [otherRunNames, ~] = dp.getRunsForDiff(selection);
            if isempty([otherRunNames{:}])
                fxptui.showdialog('notcomparablerun');
            elseif ~selection.hasOneChannel && ~selection.hasOnlyOneValidChannel
                dp1 = fxptui.DiffPlot('selectchannelforcompareruns');
                hDlg = DAStudio.Dialog(dp1);
                hDlg.enableApplyButton(true);
            elseif numel(otherRunNames) > 1
                hDlg = DAStudio.Dialog(dp);
                hDlg.enableApplyButton(true);
            else
                runID2 = ds.getRun(otherRunNames{:}).getTimeSeriesRunID;
                selectID = [];
                if selection.isPlottable
                    selectID = selection.getTimeSeriesID;
                    selectID = selectID(selection.getTimeSeriesID ~= 0);
                end
                fxptui.Plotter.compareRuns(runID1, runID2,selectID);
            end
        end
        
    end
    
end
