classdef UnsupportedCallbackRemover < appdesigner.internal.serialization.loader.interface.DecoratorLoader
    %UNSUPPORTEDCALLBACKREMOVER A decorator class that removes unknown callbacks from the app
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function obj = UnsupportedCallbackRemover(loader)
            obj@appdesigner.internal.serialization.loader.interface.DecoratorLoader(loader);
        end
        
        function appData = load(obj)
            appData = obj.Loader.load();
            
            if ( isfield(appData.code,'Callbacks'))
                appData.code.Callbacks = obj.removeUnsupportedComponentsFromCallbacks(appData.code.Callbacks);
                appData.code.Callbacks = obj.removeUnsupportedComponentPropsFromCallbacks(appData.components.UIFigure, appData.code.Callbacks);
            end
        end
        
    end
    
    methods (Access='private')
        
        function callbacks = removeUnsupportedComponentsFromCallbacks(~, callbacks)
            if ~isempty(callbacks)
                % get the suppported component types
                appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
                adapterMap = appDesignEvironment.getComponentAdapterMap();
                supportedTypes = adapterMap.keys;
                for i = 1:length(callbacks)
                    if ~isempty(callbacks(i).ComponentData)
                        componentTypes = {callbacks(i).ComponentData.ComponentType};
                        unsupportedidx = ~ismember(componentTypes, supportedTypes);
                        callbacks(i).ComponentData(unsupportedidx) = [];
                    end
                end
            end
        end
        
        function callbacks = removeUnsupportedComponentPropsFromCallbacks(obj, uifigure, callbacks)
            if ~isempty(callbacks)
                components = obj.getComponents(uifigure);
                codeNames = obj.getCodeNames(components);
                for i = 1:length(callbacks)
                    componentData = callbacks(i).ComponentData;
                    % iterate over
                    for j = length(componentData):-1:1
                        % get the component by its code name
                        name = componentData(j).CodeName;
                        comp = components(strcmp(name, codeNames));
                        % component can be empty if it doesn't exist in the
                        % release
                        if (isempty(comp))
                            callbacks.ComponentData(j) = [];
                        else
                            type = componentData(j).ComponentType;
                            prop = componentData(j).CallbackPropertyName;
                            supportedProps = obj.getSupportedProps(comp, type);
                            if(~any(strcmp(prop, supportedProps)) || ~strcmp(get(comp, prop), callbacks(i).Name))
                                % if an unsupported property is found remove it
                                % from the componentData array
                                callbacks(i).ComponentData(j) = [];
                            end
                        end
                    end
                end
            end
        end
        
        function components = getComponents(~, uifigure)
            components = findall(uifigure, '-property', 'DesignTimeProperties');
        end  
        
        function codeNames = getCodeNames(~, components)
            codeNames = cell(length(components), 1);
            for i = 1:length(components)
                codeNames{i} = components(i).DesignTimeProperties.CodeName;
            end
        end
        
        function supportedProps = getSupportedProps(~, comp, type)
            appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
            adapterMap = appDesignEvironment.getComponentAdapterMap();
            adapter = eval(adapterMap(type));
            supportedProps = adapter.getCodeGenPropertyNames(comp);
        end
    end
end

