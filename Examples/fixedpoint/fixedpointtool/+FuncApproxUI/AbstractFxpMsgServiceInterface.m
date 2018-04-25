classdef AbstractFxpMsgServiceInterface < handle
    % ABSTRACTFXPMSGSERVICEINTERFACE is an abstract interface that will be
    % implemented by all the mock message service interfaces
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = AbstractFxpMsgServiceInterface()
        end
    end
    
    methods (Abstract)
        subscriptionId = subscribe(obj, channel, callback);
        unsubscribe(obj, subscriptionId);
        publish(obj, channel, msg);
    end
end

