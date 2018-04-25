classdef ButtonInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = ButtonInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uipress(actor, varargin)
            
            narginchk(1, 1);
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uipress', varargin{:});
        end
        
    end
    
end