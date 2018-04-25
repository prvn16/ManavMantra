classdef TabGroupInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = TabGroupInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uiselect(actor, option)
            import matlab.uiautomation.internal.SingleLineTextValidator;
            import matlab.uiautomation.internal.UISingleSelectionStrategy;
            
            tabgroup = actor.Component;
            children = tabgroup.Children;
            if isempty(children)
                titles = {}; % let the validation throw
            else
                titles = {children.Title};
            end
            
            strategy = UISingleSelectionStrategy(SingleLineTextValidator, titles);
            index = strategy.validate(option);
            
            if tabgroup.SelectedTab == children(index)
                return;
            end
            
            actor.Dispatcher.dispatchEventAndWait(...
                tabgroup, 'uiselect', 'Index', index);
        end
        
    end
    
end