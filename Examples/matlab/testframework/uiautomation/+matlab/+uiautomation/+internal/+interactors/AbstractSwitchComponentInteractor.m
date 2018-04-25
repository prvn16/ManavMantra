classdef (Abstract) AbstractSwitchComponentInteractor < matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = AbstractSwitchComponentInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor(H, dispatcher);
        end
        
        function uipress(actor, varargin)
            
            narginchk(1, 1);
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uipress', varargin{:});
        end
        
        function uiselect(actor, option)
            
            import matlab.uiautomation.internal.SingleLineTextValidator;
            import matlab.uiautomation.internal.UISingleSelectionStrategy;
            
            narginchk(2,2)
            
            component = actor.Component;
            
            strategy = UISingleSelectionStrategy(SingleLineTextValidator, component.Items);
            index = strategy.validate(option);
            
            if component.SelectedIndex == index
                return;
            end
            
            actor.uipress();
            
        end
        
    end
    
end