function addIdToChannels(this, uniqueID)
    % ADDIDTOCHANNELS adds the unique ID to all the publish and subscribe
    % channels
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.LutFinishSubscribeChannel = sprintf('%s/%s',this.LutFinishSubscribeChannel,uniqueID);
    this.LutTypeSelectSubscribeChannel = sprintf('%s/%s',this.LutTypeSelectSubscribeChannel,uniqueID);
    this.LutPathUpdateSubscribeChannel = sprintf('%s/%s',this.LutPathUpdateSubscribeChannel, uniqueID);
    this.LutDesignTypeSubscribeChannel = sprintf('%s/%s',this.LutDesignTypeSubscribeChannel, uniqueID);
    this.LutDTUpdateSubscribeChannel = sprintf('%s/%s',this.LutDTUpdateSubscribeChannel, uniqueID);
    this.OptimizeLutSubscribeChannel = sprintf('%s/%s',this.OptimizeLutSubscribeChannel, uniqueID);
    this.OptimizeParamsChangeSubscribeChannel = sprintf('%s/%s',this.OptimizeParamsChangeSubscribeChannel, uniqueID);
    this.OutputTypeChangeSubscribeChannel = sprintf('%s/%s',this.OutputTypeChangeSubscribeChannel, uniqueID);
    this.DesignInputInfoChangeSubscribeChannel = sprintf('%s/%s',this.DesignInputInfoChangeSubscribeChannel, uniqueID);
    
    this.LutDesignTypePublishChannel = sprintf('%s/%s',this.LutDesignTypePublishChannel, uniqueID);
    this.LutPathPublishChannel = sprintf('%s/%s',this.LutPathPublishChannel, uniqueID);
    this.OptimizationParamsPublishChannel = sprintf('%s/%s',this.OptimizationParamsPublishChannel, uniqueID);
    this.OptimizedLutInfoPublishChannel = sprintf('%s/%s',this.OptimizedLutInfoPublishChannel, uniqueID);
    this.CurrentBlockPathPublishChannel = sprintf('%s/%s',this.CurrentBlockPathPublishChannel, uniqueID);
    this.OptimizationParamsValidityPublishChannel = sprintf('%s/%s',this.OptimizationParamsValidityPublishChannel, uniqueID);
    this.DesignTypesValidityPublishChannel = sprintf('%s/%s',this.DesignTypesValidityPublishChannel, uniqueID);
    this.DesignInputInfoValidityPublishChannel = sprintf('%s/%s',this.DesignInputInfoValidityPublishChannel, uniqueID);
end

