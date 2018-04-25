classdef ButtonGroupInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = ButtonGroupInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uiselect(actor, option)
            import matlab.uiautomation.internal.InteractorFactory;
            import matlab.uiautomation.internal.MultiLineTextValidator;
            import matlab.uiautomation.internal.UISingleSelectionStrategy;
            
            children = actor.Component.Children;
            if isempty(children)
                chText = {}; % let the validation throw
            else
                chText = {children.Text};
            end
            
            strategy = UISingleSelectionStrategy(MultiLineTextValidator, chText);
            index = strategy.validate(option);
            
            % Get the associated handle and redispatch - no need to check
            % if it's already the SelectedObject, its Interactor will figure
            % that out
            button = children(index);
            buttonActor = InteractorFactory.getInteractorForHandle(button, actor.Dispatcher);
            uiselect(buttonActor);
        end
        
    end
    
end