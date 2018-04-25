classdef FxpMsgServiceInterface < FuncApproxUI.AbstractFxpMsgServiceInterface
    % FXPMSGSERVICEINTERFACE is a mock message service interface
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = FxpMsgServiceInterface()
            obj = obj@FuncApproxUI.AbstractFxpMsgServiceInterface;
        end
    end
    
    methods
        function subscriptionId = subscribe(~, channel, callback)
            subscriptionId = message.subscribe(channel, callback);
        end
        
        function unsubscribe(~, subscriptionId)
            message.unsubscribe(subscriptionId);            
        end
        
        function publish(~, channel, msg)
            message.publish(channel, msg);
        end
    end
end

