function publishCurrentBlockPath(this, blockPath)
    % PUBLISHCURRENTBLOCKPATH publishes the path of the currently selected
    % block as determined by the Function Approximation CLI
    
    % Copyright 2017 The MathWorks, Inc.
    
    channel = this.CurrentBlockPathPublishChannel;
    this.MsgServiceInterface.publish(channel, blockPath);
end

