classdef DropDownInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor & ...
        matlab.uiautomation.internal.interactors.mixin.TextTypable
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function actor = DropDownInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor(H, dispatcher);
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
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uiselect', 'Index', index);
        end
        
    end
    
end