function subscriptions = getSubscriptions(this)
%% GETSUBSCRIPTIONS hidden API returns all the subscription channels in 
% fxptui.Web.VisualizerController

%   Copyright 2016 The MathWorks, Inc.

    subscriptions = {};
    subscriptions{end + 1} = this.PublishServerReadyChannel;
    subscriptions{end + 1} = this.PublishMetaDataChannel;
    subscriptions{end + 1} = this.PublishDataChannel;
    subscriptions{end + 1} = this.PublishDataDoneChannel;
    subscriptions{end + 1} = this.PublishSelectHistogramChannel;
    subscriptions{end + 1} = this.PublishClearHistogramsChannel;
end