classdef UnsupportedComponentRemover < appdesigner.internal.serialization.loader.interface.DecoratorLoader
    %UNSUPPORTEDCOMPONENTREMOVER A decorator class that removes unknown components from the app
    
      % Copyright 2017 The MathWorks, Inc.
      
    methods
        
        function obj = UnsupportedComponentRemover(loader)
            obj@appdesigner.internal.serialization.loader.interface.DecoratorLoader(loader);
        end
        
        function appData = load(obj)
            appData = obj.Loader.load();
            obj.removeUnsupportedComponents(appData.components.UIFigure);
        end
        
    end
    
    methods (Access='private')
        
        function removeUnsupportedComponents(~, uifigure)
            % remove unsupported components unknown to the release
            
            % get the suppported component types
            appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
            adapterMap = appDesignEvironment.getComponentAdapterMap();
            supportedComponentTypes = adapterMap.keys;
            
            % retrieve all components under the UIFigure and delete them if
            % not a supported component type.  Go in reverse order so as
            % not to delete components in the middle of the array while
            % looping.  It also guarantees that components within
            % containers are listed before the container
            components = findall(uifigure, '-property', 'DesignTimeProperties');
         %   components = appdesigner.internal.application.getDescendants(uifigure);
            for idx = length(components):-1:1
                component = components(idx);
                if(~any(strcmp(class(component), supportedComponentTypes)))
                    delete(component);
                end
            end
        end
    end
end

