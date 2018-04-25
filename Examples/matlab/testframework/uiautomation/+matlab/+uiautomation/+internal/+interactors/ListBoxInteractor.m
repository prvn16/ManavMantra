classdef ListBoxInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = ListBoxInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractStateComponentInteractor(H, dispatcher);
        end
        
        function uiselect(actor, option)
            
            import matlab.uiautomation.internal.Modifiers;
            import matlab.uiautomation.internal.SingleLineTextValidator;
            import matlab.uiautomation.internal.UIMultiSelectionStrategy;
            
            narginchk(2,2)
            
            component = actor.Component;
            
            strategy = UIMultiSelectionStrategy(SingleLineTextValidator, component.Items);
            index = strategy.validate(option);
            
            if isempty(index)
                % made it here if [] was the input
                error( message('MATLAB:uiautomation:Driver:NoOptionMatch') );
            end
            index = unique(index, 'stable');
            
            if isequal(component.SelectedIndex, index)
                return;
            end
            
            if length(index)>1 && strcmpi(component.Multiselect,'off')
                error( message('MATLAB:uiautomation:Driver:ComponentNotMultiSelectable') );
            end
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uiselect', 'Index', index(1));
            
            options = Modifiers.CTRL;
            for k=2:length(index)
                % each subsequent selection needs the CTRL key to multi-select
                actor.Dispatcher.dispatchEventAndWait(...
                    actor.Component, 'uiselect', 'Index', index(k), 'Options', options);
            end
        end
        
    end
    
end