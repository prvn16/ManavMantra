function handleBlockPathUpdate(this, data)
    % HANDLEBLOCKPATHUPDATE validates the path provided by the user and
    % publishes block information
    
    % Copyright 2017 The MathWorks, Inc.
    
    isPathValid = this.DataManager.validateBlockPath(data.path);
    if(~isPathValid)
        data.path = '';
    end
    this.publishBlockInfo(data, true);
end
