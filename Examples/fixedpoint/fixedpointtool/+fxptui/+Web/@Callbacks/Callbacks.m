classdef Callbacks < handle
    % CALLBACKS class to handle workflow actions from the web client
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods(Static)
        function b = isLoggingEnabled(mdlObj)
            if ~strcmpi(get_param(mdlObj.getFullName,'MinMaxOverflowLogging'),'UseLocalSettings') && ~strcmpi(get_param(mdlObj.getFullName,'MinMaxOverflowLogging'),'ForceOff')
                b = true;
                return;
            else
                % Find all subsystems under the root model
                ch = find(mdlObj,'-isa','Simulink.SubSystem');
                b = ~isempty(ch.find({'MinMaxOverflowLogging','MinMaxAndOverflow'},'-or',{'MinMaxOverflowLogging','Overflow'}));
            end
        end
        
        function CompareRuns(run1, run2)
            fpt = fxptui.FixedPointTool.getExistingInstance;
            rep = fxptds.FPTRepository.getInstance;
            if ~isempty(fpt)
                ds = rep.getDatasetForSource(fpt.getModel);
                runObj1 = ds.getRun(run1);
                runObj2 = ds.getRun(run2);
                if runObj1.hasResults && runObj2.hasResults
                    sdiRunID1 = runObj1.getTimeSeriesRunID;
                    sdiRunID2 = runObj2.getTimeSeriesRunID;
                    fxptui.Plotter.compareRuns(sdiRunID1, sdiRunID2, 1);
                end
            end
        end
        
        function LaunchFPA
            b = fxptui.checkInstall;
            if ~b
                fxptui.showdialog('nofixptlicensefpa');
                return;
            end
            
            fpt = fxptui.FixedPointTool.getExistingInstance;
            if ~isempty(fpt)
                % re-populate the referenced models if they were previously closed
                success = fpt.loadReferencedModels;
                if ~success
                    return; 
                end
                sud = fpt.getSystemForConversion;
                try
                    fpcadvisor(sud);
                catch fpa_exception
                    % showdialog can throw an error in testing mode. catch this error, restore
                    % the UI and then rethrow the error.
                    fxptui.showdialog('launchfpafailed',fpa_exception);
                end
            end
        end
        
        Simulate(command)
        SimulateIdealized(clientData)
        SimulateEmbedded(clientData)
        Derive(clientData)
        SelectRunForPropose(clientData, proposalEditFieldChanges);
        SelectRunForApply(clientData);
        CreateBAExplorer(clientData);
        HighlightBlock;
        HighlightMLResult(selection);
        ValidateProposedDT(clientData);
        LaunchHelp(clientData);
        OpenSettingsEditor(varargin);
    end
    
    methods(Static, Hidden)
        Propose
        Apply
        UpdateOnDataChanged(clientDataChanged);
        data = fetchSpreadsheetData(clientMessage);
        changeRunNameAndRestoreDirty(model, runName);
    end
    
    
end

% LocalWords:  nofixptlicensepropose launchfpafailed nofixptlicensefpa
