classdef PositionAdjuster < appdesigner.internal.serialization.loader.interface.DecoratorLoader
    %PositionAdjuster  A decorator class that adds a pixel to each component's
    %position

     % Copyright 2017 The MathWorks, Inc.
  
    methods
        
        function obj = PositionAdjuster(loader)
            obj@appdesigner.internal.serialization.loader.interface.DecoratorLoader(loader);
        end
        
        function appData = load(obj)
            appData = obj.Loader.load();
            obj.updatePosition(appData.components.UIFigure);
        end
        
    end
    
    methods (Access='private')
        function updatePosition(obj,component)
            
            % Handle backward compatibility to update the pixel position
            if ~isa(component, 'matlab.ui.container.Tab') && ...
                    isprop(component, 'Position')
                % 16a app uses 0-based Position, and needs to convert to
                % 1-based when 16a apps are loaded in a future release.
                % Tab's Position is read-only, and ignore it
                component.Position = [component.Position(1) + 1, component.Position(2) + 1, ...
                    component.Position(3), component.Position(4)];
            end
            
            % Recursively handle child components.  Do not want to iterate
            % over the Axes children because they are not components
            if ( isprop(component,'Children')) && ~isa( component, 'matlab.ui.control.UIAxes')
                children = allchild(component);
                for i = 1:length(children)
                    childComponent = children(i);
                    % recursively walk the children
                    obj.updatePosition(childComponent);
                end
            end
        end       
        
    end
end

