function [tableData, Zero, GlobalYLimit, WouldBeOverflows] = collectData(~, runName, results, resultRenderingOrder)
%% COLLECTDATA function interfaces with Visualizer Backend Engine to query for 
% results that belong to a given run name and constructs VisualizerRecords
% in the resultRenderingOrder

%   Copyright 2016-2017 The MathWorks, Inc.
    
    tableData = [];
    Zero = [];
    GlobalYLimit = [];
    WouldBeOverflows = [];
    
    if ~isempty(results)
        % Construct engine instance
        engine = DataTypeWorkflow.Visualizer.Engine(DataTypeWorkflow.Visualizer.ClientTypes.FPTClientRecordFactory);

        % Add VisualizerRecords for input results 
        engine.addSimulationData(results);

        % Generate RGB in the given input rendering order
        engine.generateRGB(runName, results);

        % For runs with no histogram data - Derived runs
        % Engine will have no RGB Generator
        if ~isempty(engine.RGBGenerator.HistogramRenderingData)
            % Get table records in the input result rendering order
            resultRenderingOrder = fxptui.Web.VisualizerController.filterResultRenderingOrder(resultRenderingOrder, results, runName);
            
            % Get table records in the input result rendering order
            tableData = engine.getRecords(resultRenderingOrder);
            
            % Calculate potential overflows
            overflowingBins = cellfun(@(x)x.OverflowBins, engine.RGBGenerator.HistogramRenderingData, 'UniformOutput', false);
            hasOverflows = tableData.HasOverflows;
            
            WouldBeOverflows = cell(numel(hasOverflows), 1);
            for idx=1:numel(hasOverflows)
                if (~hasOverflows(idx) && numel(overflowingBins{idx}) >= 1)
                    WouldBeOverflows{idx} = 1;
                end
            end
            
            % Get Zero
            Zero = engine.RGBGenerator.ZERO;

            % Get GlobalYLimit
            GlobalYLimit = engine.RGBGenerator.GlobalYLimit;
        end
    end
end
