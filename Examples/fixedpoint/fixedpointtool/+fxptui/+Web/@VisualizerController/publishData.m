function publishData(this, doPublishMetaDataFlag)
%% PUBLISHDATA function publishes visualization data for input results of 
% input runName in the input resultRenderingOrder

%   Copyright 2016-2017 The MathWorks, Inc.
    
    if(doPublishMetaDataFlag)
        % Publish Metadata 
        message.publish(this.PublishMetaDataChannel, this.MetaData);
    end

    % Publish Data
    message.publish(this.PublishDataChannel,this.Data);

    % Publish Data Done
    message.publish(this.PublishDataDoneChannel,'done');
    this.LastUsedChannel = this.PublishDataDoneChannel;

end