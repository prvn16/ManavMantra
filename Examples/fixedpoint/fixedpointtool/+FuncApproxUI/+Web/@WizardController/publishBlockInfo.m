function publishBlockInfo(this, data, update)
    % PUBLISHBLOCKINFO publishes the block path info to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    if(~isempty(data.path))
        this.DataManager.setPath(data.path);
        this.publish(this.LutPathPublishChannel, data.path);
    else
        this.publish(this.LutPathPublishChannel, 'invalid');
        if update
            FuncApproxUI.Utils.showDialog('invalidBlockPath');
        end
    end
end


