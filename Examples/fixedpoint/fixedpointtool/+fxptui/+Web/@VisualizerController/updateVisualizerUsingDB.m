function updateVisualizerUsingDB(this, dataForVisualizer)
%% UPDATEVISUALIZER function updates visualizer with histograms from latest run

%   Copyright 2017 The MathWorks, Inc.

    % If Visualizer is featured on
    if slfeature('Visualizer') 
        if dataForVisualizer.total > 0
            % Clear previously cached data and metadata
            this.Data = [];
            this.MetaData = [];
            
            % Set Publish metaData to true
            publishMetaDataFlag = true;
            
            % Create engine instance 
            this.VisualizerEngine =  DataTypeWorkflow.Visualizer.Engine(DataTypeWorkflow.Visualizer.ClientTypes.FPTClientRecordFactory);

            % Add data for table records and inscope information
            this.VisualizerEngine.TableData = dataForVisualizer.rows;
            this.VisualizerEngine.InScopeData = dataForVisualizer.inScopeIds;
            this.VisualizerEngine.RunName = dataForVisualizer.RunName;
            
            % Seive records with histogram data
            this.VisualizerEngine.filterRecordsWithHistogramData();

            % Compute canvas data 
            this.VisualizerEngine.generateCanvasData();

            % FilterRecordsWithHistogramData could have removed all histograms
            if ~isempty(this.VisualizerEngine.TableData)
                this.VisualizerEngine.init();
                
                this.packageDataUsingDB(publishMetaDataFlag);

                this.VisualizerEngine.LastIndex = this.VisualizerEngine.EndIndex + 1;
            end
            % Publish Data
            this.publishData(publishMetaDataFlag);
            
        end
    end
end