function computeMetaData(this)
%% COMPUTEMETADATA function computes the fields required for rendering visualization
% in Visualizer widget 

%   Copyright 2017 The MathWorks, Inc.

    if ~isempty(this.VisualizerEngine)
        if ~isempty(this.VisualizerEngine.TableData) && ~isempty(this.VisualizerEngine.NumRecordsToPublish)
            numTransactions = ceil(size(this.VisualizerEngine.TableData, 1)/this.VisualizerEngine.NumRecordsToPublish);
        else
            numTransactions = 0;
        end
        
        RGBMetaData = struct('ZERO', this.VisualizerEngine.RGBGenerator.ZERO, 'RunName', this.VisualizerEngine.RunName, 'Canvas', this.VisualizerEngine.CanvasData, 'NumRecords', size(this.VisualizerEngine.TableData, 1), 'NumTransactions', numTransactions );
        this.MetaData = struct('MetaData', RGBMetaData);   
    end
end