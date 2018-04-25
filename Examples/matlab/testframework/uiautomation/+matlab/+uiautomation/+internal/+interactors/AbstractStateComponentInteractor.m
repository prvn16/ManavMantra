classdef (Abstract) AbstractStateComponentInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractComponentInteractor & ...
        ... access to "SelectedIndex" property
        appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = AbstractStateComponentInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
    end
    
end