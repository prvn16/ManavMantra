function initializeSubscriptions(this)
    % INITIALIZESUBSCRIPTIONS initializes all the channels subscribed to the
    % client messages
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.Subscriptions{1} = this.MsgServiceInterface.subscribe(this.LutTypeSelectSubscribeChannel,@(data)this.handleSelectedType(data));
    this.Subscriptions{2} = this.MsgServiceInterface.subscribe(this.LutFinishSubscribeChannel,@(data)this.onFinishClick(data));
    this.Subscriptions{3} = this.MsgServiceInterface.subscribe(this.LutPathUpdateSubscribeChannel,@(data)this.handleBlockPathUpdate(data));
    this.Subscriptions{4} = this.MsgServiceInterface.subscribe(this.LutDesignTypeSubscribeChannel,@(data)this.handleGetDesignTypeInfo(data));
    this.Subscriptions{5} = this.MsgServiceInterface.subscribe(this.LutDTUpdateSubscribeChannel,@(data)this.handleDesignTypeUpdate(data));
    this.Subscriptions{6} = this.MsgServiceInterface.subscribe(this.OptimizeLutSubscribeChannel,@(data)this.handleOptimize(data));
    this.Subscriptions{7} = this.MsgServiceInterface.subscribe(this.OptimizeParamsChangeSubscribeChannel,@(data)this.handleOptimizationParametersChange(data));
    this.Subscriptions{8} = this.MsgServiceInterface.subscribe(this.OutputTypeChangeSubscribeChannel,@(data)this.handleOutputDesignTypeChange(data));
    this.Subscriptions{9} = this.MsgServiceInterface.subscribe(this.DesignInputInfoChangeSubscribeChannel,@(data)this.handleDesignInputInfoChange(data));
end

