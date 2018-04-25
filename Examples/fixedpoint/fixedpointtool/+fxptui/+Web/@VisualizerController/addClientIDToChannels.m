function addClientIDToChannels(this, clientID)
%% ADDCLIENTIDTOCHANNELS function adds clientId to Visualizer channels

%   Copyright 2016 The MathWorks, Inc.

    this.PublishServerReadyChannel = sprintf('%s/%s',this.PublishServerReadyChannel, clientID);
    this.PublishMetaDataChannel = sprintf('%s/%s',this.PublishMetaDataChannel, clientID);
    this.PublishDataChannel = sprintf('%s/%s',this.PublishDataChannel, clientID);
    this.PublishDataDoneChannel = sprintf('%s/%s',this.PublishDataDoneChannel, clientID);
    this.PublishSelectHistogramChannel = sprintf('%s/%s',this.PublishSelectHistogramChannel, clientID);
    this.PublishClearHistogramsChannel = sprintf('%s/%s',this.PublishClearHistogramsChannel, clientID);
end