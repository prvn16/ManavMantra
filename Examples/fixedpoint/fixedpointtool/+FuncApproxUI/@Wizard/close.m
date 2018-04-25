function close(this)
    % CLOSE Closes the LUT Wizard and cleans up references.
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.deleteControllers;
    delete(this.WebWindow);
    this.WebWindow = [];
    for i = 1:numel(this.Subscriptions)
        this.MsgServiceInterface.unsubscribe(this.Subscriptions{i});
    end
    this.Subscriptions = [];
    if ~isempty(this.MsgServiceInterface) 
        delete(this.MsgServiceInterface);
        this.MsgServiceInterface = [];
    end
    this.AppUniqueID = '';
    this.AppReady = false;
end
