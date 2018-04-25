classdef SerializationIdRemover < appdesigner.internal.serialization.loader.interface.DecoratorLoader
    %SerializationIdRemover  A decorator class that removes the SerializationId
    %property from the components, if it exists

     % Copyright 2017 The MathWorks, Inc.
  
    methods
        
        function obj = SerializationIdRemover(loader)
            obj@appdesigner.internal.serialization.loader.interface.DecoratorLoader(loader);
        end
        
        function appData = load(obj)
            appData = obj.Loader.load();
            obj.removeSerializationId(appData.components.UIFigure);
        end
        
    end
    
    methods (Access=private)
        
        function removeSerializationId(obj,component)
              
            % In 16b, the setting of SerializationID on GBT components was removed from
            % the logic as leftover technical debt.  That means that GBT components in 16a apps
            % still have this property, as well as 16b apps that originated in 16a.
            % This code removes SerializationID from any of the components  in this app....
            if ( isprop(component,'SerializationID'))
                propToDelete = findprop(component,'SerializationID');
                delete(propToDelete);
            end
            
            % Recursively handle child components.  Do not want to iterate
            % over the Axes children because they are not components
            if ( isprop(component,'Children')) && ~isa( component, 'matlab.ui.control.UIAxes')
                children = allchild(component);
                for i = 1:length(children)
                    childComponent = children(i);
                    % recursively walk the children
                    obj.removeSerializationId(childComponent);
                end
            end
        end       
        
    end
end
