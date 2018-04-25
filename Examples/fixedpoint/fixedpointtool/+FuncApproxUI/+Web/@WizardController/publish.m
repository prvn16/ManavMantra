function publish(this, channel, data)
    % PUBLISHBLOCKPATH publishes the path of the block after validation
    
    % Copyright 2017 The MathWorks, Inc.   
    
    this.MsgServiceInterface.publish(channel, data);
end

