classdef SpinnerInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractComponentInteractor & ...
        matlab.uiautomation.internal.interactors.mixin.NumericTypable
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = SpinnerInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uipress(actor, updown)
            
            narginchk(2, 2);
            
            updown = validatestring(updown, {'up', 'down'});
            
            actor.Dispatcher.dispatchEventAndWait( ...
                actor.Component, 'uipress', 'Direction', updown);
        end
        
    end
    
end