function sendServerReady(this)
%% SENDSERVERREADY function sends a ready signal to visualizer client every time 
% VisualizerController gets data to publish to client. This enables the
% client to construct a visualizer panel as and when required.

%   Copyright 2016 The MathWorks, Inc.

        % Send server ready only if Visualizer feature is ON
        if slfeature('Visualizer')
            message.publish(this.PublishServerReadyChannel, 'ready');
            this.LastUsedChannel = this.PublishServerReadyChannel;
        end
end