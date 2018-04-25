function sendDataForCanvasMove(this, data)
%% SENDDATAFORCANVASMOVE function sends visualizer data for every move of canvas 
% pointer in FPT GUI

%   Copyright 2017 The MathWorks, Inc.

    this.VisualizerEngine.LastIndex = data.NewCanvasPosition - 1;
    if (this.VisualizerEngine.LastIndex < 0)
        this.VisualizerEngine.LastIndex = 0;
    end
    
    publishMetaDataFlag = false;
    this.packageDataUsingDB(publishMetaDataFlag);
    
    this.publishData(publishMetaDataFlag);
    this.LastUsedChannel = this.PublishDataChannel;
end