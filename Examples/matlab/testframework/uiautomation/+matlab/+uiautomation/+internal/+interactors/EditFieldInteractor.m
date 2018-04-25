classdef EditFieldInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractComponentInteractor & ...
        matlab.uiautomation.internal.interactors.mixin.TextTypable
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = EditFieldInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
    end
    
end