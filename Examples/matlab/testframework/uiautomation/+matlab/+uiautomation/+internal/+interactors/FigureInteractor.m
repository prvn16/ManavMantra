classdef FigureInteractor < ...
        matlab.uiautomation.internal.interactors.AbstractComponentInteractor
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function actor = FigureInteractor(H, dispatcher)
            actor@matlab.uiautomation.internal.interactors.AbstractComponentInteractor(H, dispatcher);
        end
        
        function uilock(actor, bool)
            
            if strcmp(actor.Component.Visible, 'off')
                queueLockForInvisibleFigure(actor, bool)
                return;
            end
            
            actor.Dispatcher.dispatchEventAndWait(...
                actor.Component, 'uilock', 'Value', bool);
        end
        
    end
    
    methods (Access = private)
        
        function queueLockForInvisibleFigure(actor, bool)
            
            fig = actor.Component;
            
            cls = ?matlab.ui.Figure;
            prop = findobj(cls.PropertyList, 'Name', 'Visible');
            L = event.proplistener(fig, prop, 'PostSet', ...
                @(o,e)actor.doLockAndDeleteListener(bool));
            setappdata(fig, 'uilockListener', L);
        end
        
        function doLockAndDeleteListener(actor, bool)
            
            fig = actor.Component;
            rmappdata(fig, 'uilockListener');
            actor.uilock(bool)
        end
        
    end
    
end
