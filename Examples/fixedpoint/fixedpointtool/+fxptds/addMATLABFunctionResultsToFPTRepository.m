function addMATLABFunctionResultsToFPTRepository(blkSID) % ModelName
%addMATLABFunctionResultsToFPTRepository Add MATLAB Function Block results to Fixed-Point Tool repository.

%   Copyright 2013-2015 The MathWorks, Inc.

% Check for Designer license. If not available, do not continue to report
% instrumentation information. 
    if ~hasFixedPointDesigner()
        return;
    end

    try
        blkSID = blkSID(2:end);
        if isempty(blkSID)
            % Nothing was logged
            return
        end
        mdl = Simulink.ID.getModel(blkSID);
        
        % Create or get the application data that manages the lifecycle of
        % the dataset.
        appData = SimulinkFixedPoint.getApplicationData(mdl);
        fptDataset = appData.dataset; % get the dataset instance
        runName = get_param(mdl,'FPTRunName');
        runObj = fptDataset.getRun(runName);
        blk = get_param(blkSID,'Object');
        emlChart = fxptds.getSFChartObject(blk);
        chartId = emlChart.Id;
        blockH = get_param(emlChart.Path,'handle');
        
        % Figure out the src directory
        MATLABFunctionBlockSpecializationCheckSum = sf('SFunctionSpecialization',chartId,blockH);
        [~, mainInfoName, ~, ~] = sfprivate('get_report_path', pwd, MATLABFunctionBlockSpecializationCheckSum, false);
        
        if ~exist(mainInfoName, 'file')
            % If the mat-file is not present in the current directory, then
            % look in the directory where the model is.
            % See matlab/toolbox/stateflow/stateflow/private/eml_report_manager.m
            modeldir = fileparts(emlChart.Machine.FullFileName);
            reportDir = fullfile(sfprivate('get_sf_proj', modeldir), ...
                                 'EMLReport');
            mainInfoName = fullfile(reportDir, ...
                                    [MATLABFunctionBlockSpecializationCheckSum, '.mat']); 
        end
        
        % Create a uniqueFileKey for this file for use by the master inference
        % report. This is based on both file name and time stamp because
        % the same file name can exist with different contents.
        fileInfo = dir(mainInfoName);
        uniqueFileKey = sprintf('%s %s',  mainInfoName, fileInfo.date);
                
        % pullLog to get raw log
        logKey = [ '#' blkSID];
        result = fixed.internal.pullLog(logKey);
        
        % For logged MATLAB Function blocks
        if ~isempty(result)
            
            % pullLog on MATLAB Function block key does not have CompilationReport field
            % load from .mat file to get CompilationReport
            load(mainInfoName,'report');
            result.CompilationReport = report;
            
            [CompilationReport, loggedVariablesData] = ...
                fixed.internal.processInstrumentedMxInfoLocations(result);
            loggedVariablesData.SID = blkSID;
            
            if fxptui.isMATLABFunctionBlockConversionEnabled()
                errState = coder.internal.MLFcnBlock.F2FDriver.addMATLABFunctionResults(blkSID, CompilationReport, loggedVariablesData, runObj);
                
                % errState of Float2Fixed so far. the value incdicates one
                % of the following conditions:
                %   [] - default. No errors / warnings / display messages
                %           so far
                %   coder.internal.lib.Message.ERR - There are error
                %   messages for user to see
                %   coder.internal.lib.Message.WARN - There are warning
                %   messages for user to see
                %   coder.internal.lib.Message.DISP - There are display
                %   messages for user to see
                loggedVariablesData.F2FErrorState = errState;
            end
            
            fxptds.putMATLABFunctionBlockDataIntoRunObject(...
                runObj, CompilationReport, loggedVariablesData, uniqueFileKey);
        end
    catch ex
        % If it errors, catch the exception and consume it instead of throwing
        % it or hard-erroring to prevent the mex simulation from giving
        % nondescript message. 
        coder.internal.gui.asyncDebugPrint(ex);
    end
end
