function handleDesignTypeUpdate(this, designTypeInfo)
    % HANDLEDESIGNTYPEUPDATE creates a new problem with the design type
    % information provided by the client and publishes the new design type
    % information to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    try
        designTypeInfo = this.DataManager.updateDesignTypeInfo(designTypeInfo);        
        data = this.DataManager.getPreOptimizeData();
        this.publish(this.LutDesignTypePublishChannel, designTypeInfo);
        this.publish(this.OptimizationParamsPublishChannel, data);
    catch e
        FuncApproxUI.Utils.showDialog('invalidDesignType', e);
    end
end

