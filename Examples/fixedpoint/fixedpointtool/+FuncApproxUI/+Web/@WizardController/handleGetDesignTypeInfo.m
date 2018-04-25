function handleGetDesignTypeInfo(this, allowUpdateDiagram)
    % HANDLEGETDESIGNTYPEINFO creates a new problem and publishes the
    % design type information to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.DataManager.setAllowUpdateDiagram(allowUpdateDiagram);
    try
        designTypeInfo = this.DataManager.getDesignTypeInfo();
        this.publish(this.LutDesignTypePublishChannel, designTypeInfo);
    catch e
        FuncApproxUI.Utils.showDialog('invalidDesignType', e);
    end
end

