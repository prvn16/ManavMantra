classdef (Abstract) AbstractInteractiveTickComponentInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = AbstractInteractiveTickComponentInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uiselect(actor, value)
            
            narginchk(2, 2);
            
            validateattributes(value, {'numeric'}, {'scalar'});
            
            component = actor.Component;
            p = value2percentage(component, value);
            
            if component.Value == value
                return;
            end
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uiselect', 'Percentage', p);
        end
        
        function uidrag(actor, from, to)
            
            narginchk(3, 3);
            
            component = actor.Component;
            pFrom = value2percentage(component, from);
            pTo   = value2percentage(component, to);
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uidrag', 'Percentage', [pFrom pTo]);
        end
        
    end
    
end


function perc = value2percentage(component, value)

validateattributes(value,{'numeric'},{'scalar'});

lim = component.Limits;
if value < lim(1) || lim(2) < value
    error( message('MATLAB:uiautomation:Driver:ValueOutsideLimits') )
end

perc = (value - lim(1)) / (lim(2)-lim(1));
end