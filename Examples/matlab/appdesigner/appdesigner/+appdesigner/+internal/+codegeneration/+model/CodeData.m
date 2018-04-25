classdef CodeData < handle...
        & appdesigner.internal.model.AbstractAppDesignerModel
    %CodeData code model data from the client

    % Copyright 2015-2017 The MathWorks, Inc.
    properties
        % the class name of the App
        GeneratedClassName;

        % an array of callbacks of type
        % 'appdesigner.internal.codegeneration.model.AppCallback'
        Callbacks;

        % the startup function object that can be modified of type
        % 'appdesigner.internal.codegeneration.model.AppCallback'
        ConfigurableStartupFcn;

        % the editable section created by the user...  properties and
        % functions.  It is an object of type 'appdesigner.internal.codegeneration.model.CodeSection'
        EditableSection;

        % the input parameters to the app.
        InputParameters;
    end

    properties
        % properties maintained for forward and backward compatibility

        % the startup function object of type
        % 'appdesigner.internal.codegeneration.model.AppCallback'
        % introduced in R2016a to hold the startup function for Apps
        % this is replaced by ConfigurableStartupFcn in R2016b
        StartupFcn;
    end

    properties(Transient)
        % an property to access the generated code
        GeneratedCode
    end

    methods
        %------------------------------------------------------------------

        function obj = CodeData(appModel, proxyView)
            % constructor

            import appdesigner.internal.codegeneration.model.AppCallback;
            import appdesigner.internal.codegeneration.model.CodeSection;

            % create an empty array for the callback and code data
            obj.Callbacks = AppCallback.empty;

            % create the startup function callback
            obj.ConfigurableStartupFcn = AppCallback;

            obj.EditableSection = CodeSection('EditableSection', '');

            if (nargin > 0)
                % assign this object to the App Model handle
                appModel.CodeData = obj;

                % instantiate a controller
                obj.createController(proxyView);
            end
        end
        %------------------------------------------------------------------

        function set.GeneratedClassName(obj, name)
            % set the generated class name for the App
            obj.GeneratedClassName = name;
        end
        %------------------------------------------------------------------

        function set.InputParameters(obj, params)
            % set the input parameters for the app
            obj.InputParameters = params;
        end
        %------------------------------------------------------------------

        function sendGoToLineColumnEventToClient(obj, line, column, scrollToView)
            % send gotoLineColumn peerEvent to CodeModel on client side
            % TODO: this function needs to be refactored/moved. It is
            % necessary for code realted functionality but is not related
            % to code data
            obj.Controller.ProxyView.sendEventToClient('goToLineColumn', ...
                {'Line', line, 'Column', column, 'ScrollToView', scrollToView});
        end
        %------------------------------------------------------------------

        function data = getCodeDataForLoad(obj)
            % returns a struct to be sent to the client after
            % deserialization

            import appdesigner.internal.codegeneration.model.CodeData;

            data = struct('GeneratedClassName', obj.GeneratedClassName, ...
                'EditableSection', CodeData.convertObjectToStruct(obj.EditableSection) , ...
                'Callbacks',  CodeData.convertObjectToStruct(obj.Callbacks), ...
                'InputParameters', obj.InputParameters, ...
                'StartupFcn', CodeData.convertObjectToStruct(obj.ConfigurableStartupFcn));

        end
        %------------------------------------------------------------------
    end

    methods(Access=private, Static)
        %------------------------------------------------------------------

        function codeStruct = convertObjectToStruct(objectArray)
            import appdesigner.internal.codegeneration.model.CodeData;
            % helper method to convert MCOS objects contained in this class
            % into structs
            codeStruct = struct();
            codeDataProps = properties(objectArray);
            versionProperties = properties(appdesigner.internal.serialization.app.AppVersion);
            for i = 1:length(objectArray)
                for j = 1:length(codeDataProps)
                    % remove properties inherted from AppVersion  for code
                    % Data objects
                    if (~ismember(codeDataProps{j}, versionProperties))
                        prop = objectArray(i).(codeDataProps{j});
                        if(isobject(prop))
                            codeStruct(i).(codeDataProps{j}) =  CodeData.convertObjectToStruct(prop);
                        else
                            codeStruct(i).(codeDataProps{j}) = prop;
                        end
                    end
                end
            end
        end
        %------------------------------------------------------------------
    end

    methods(Hidden)
        %------------------------------------------------------------------
        function handleUnsupportedComponentCallbackProps(obj, appFigure)
            % strips componentData from callbacks if unsupported Component
            % properties are identified. Uses the adapter's
            % getCodeGenPropertyNames method to identify unsupported
            % properties. Some properties may be present but not supported
            % by App Designer
            if (~isempty(obj.Callbacks))

                appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
                adapterMap = appDesignEvironment.getComponentAdapterMap();
                components = findobj(appFigure, '-property', 'DesignTimeProperties');
                codeNames = cell(length(components), 1);
                for i = 1:length(components)
                    codeNames{i} = components(i).DesignTimeProperties.CodeName;
                end
                
                for i = 1:length(obj.Callbacks)
                    componentData = obj.Callbacks(i).ComponentData;
                    % iterate over
                    for j = length(componentData):-1:1

                       name = componentData(j).CodeName;
                       type = componentData(j).ComponentType;
                       prop = componentData(j).CallbackPropertyName;
                       
                       % get the component by its code name
                       comp = components(strcmp(name, codeNames));
                       if (isempty(comp))
                           obj.Callbacks(i).ComponentData(j) = [];
                       else
                          adapter = eval(adapterMap(type));
                          supportedProps = adapter.getCodeGenPropertyNames(comp);                      
                          if(~any(strcmp(prop, supportedProps)) || ~strcmp(get(comp, prop), obj.Callbacks(i).Name))
                              % if an unsupported property is found remove it
                              % from the componentData array
                              obj.Callbacks(i).ComponentData(j) = [];
                          end                          
                      end
                    end
                end
            end
        end
       %------------------------------------------------------------------
    end

    methods(Access = public)
        %------------------------------------------------------------------

        function controller = createController(obj,  proxyView)
          % Creates the controller for this Model
          controller = appdesigner.internal.codegeneration.controller.CodeDataController(obj, proxyView);
        end
        %------------------------------------------------------------------
    end

    methods(Static, Hidden)

        %------------------------------------------------------------------

        function obj = loadobj(loadedObj)
            % handles loading the CodeData Object from a MAT file. This is
            % used for maintaining backward compatibilty between releases
            % of App Designer. loadobj is a point when unserializing App
            % Designer data to modify the loaded object to make it
            % compatibile to the current release of App Designer

            import appdesigner.internal.codegeneration.model.*;

            % update the returned obj to have the same data as loadedObj
            if isstruct(loadedObj)
                % MCOS will pass a struct into loadobj() when load() can't
                % create the object directly, e.g. class definition
                % changes.
                % In this case, 16a AppCallback inherits from AppVersion,
                % but removed in 16b (g1398205). So when loading an 16a app
                % into 16b, the loadedObj would be a struct
                obj = appdesigner.internal.codegeneration.model.CodeData();

                fieldNames = fieldnames(loadedObj);
                for i = 1:length(fieldNames)
                    propName = fieldNames{i};
                    if isprop(obj, propName)
                        obj.(propName) = loadedObj.(propName);
                    end
                end
            else
                % Otherwise class definition is compatible with the
                % serialized object, and MCOS load() can instantiate the
                % object, and loadedObj would be a regular object
                obj = loadedObj;
            end

            % if the loaded object is from a version earlier than the
            % current:
            % 1) copy the startupFcn data to the configurable
            % startupFcn
            % 2) convert callback.ComponentData.ComponentType from
            % 'matlab.ui.control.AppWindow' to 'matlab.ui.Figure'
            % 3) remove any unsupported component types from the callbacks
            % componentData
            CodeData.handleReleaseComaptibilty(loadedObj, obj);
        end
        %------------------------------------------------------------------

        function handleReleaseComaptibilty(loadedObj, compatibleObj)
            % handles compatibility for loading codeData

            import appdesigner.internal.codegeneration.model.CodeData;

            % remove any unsupported component types from associated
            % callbacks
            CodeData.handleUnsupportedComponents(loadedObj);

            % if CodeData is loaded before the Configurable Startup
            % function exists and there is code on the Startup Function
            % transfer its data to the ConfigurableStartupFcn. Otherwise,
            % its assumed that the user deleted the Startup function and it
            % is empty
            if (isstruct(loadedObj) || isempty(loadedObj.ConfigurableStartupFcn)) && ...
                    ~isempty(loadedObj.StartupFcn.Code)
                % copy the serialized StartupFcn data to ConfigurableStatipFcn
                compatibleObj.ConfigurableStartupFcn = loadedObj.StartupFcn;
            end
        end
        %------------------------------------------------------------------

        function handleUnsupportedComponents(loadedObj)
            % removes any unsupported components from the loaded callbacks

            % handle both Objects and Structs since structs will be passed
            % in if the implementation of this class may have changed since
            % previous releases
            if (isprop(loadedObj, 'Callbacks') || isfield(loadedObj, 'Callbacks'))
                % get a list of supported component types
                appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
                adapterMap = appDesignEvironment.getComponentAdapterMap();
                supportedTypes = adapterMap.keys;

                for i = 1:length(loadedObj.Callbacks)
                    callbacks = loadedObj.Callbacks(i);
                    if (~isempty(callbacks.ComponentData))
                        % From 16a, the UIFigure's callback data will store
                        % ComponentType as 'matlab.ui.control.AppWindow', and in order
                        % to load into 16b or later, need to change to
                        % 'matlab.ui.Figure'
                        %
                        % Shared callback has multiple ComponentData, and strcmp
                        % requires one string
                        componentTypes = {callbacks.ComponentData.ComponentType};
                        appWindowIdx = strcmp('matlab.ui.control.AppWindow', componentTypes);
                        if any(appWindowIdx)
                            callbacks.ComponentData(appWindowIdx).ComponentType = 'matlab.ui.Figure';
                        end

                        % get a list of which callbacks are assocuated with
                        % unknown components not found in supportedTypes
                        componentTypes = {callbacks.ComponentData.ComponentType};
                        unsupportedidx = ~ismember(componentTypes, supportedTypes);
                        callbacks.ComponentData(unsupportedidx) = [];
                    end
                end
            end
        end
        %------------------------------------------------------------------
    end

    methods(Hidden)
        %------------------------------------------------------------------
        function savedObj = saveobj(obj)
            % handles saving the CodeData object to MAT file. This function
            % is used for maintaining forward compatibility in that the
            % saved app can be modified before serialzation to a MAT file.

            % update the returned obj to have the same data as obj
            savedObj = obj;
            savedObj = obj.handleSaveStartupFcnForCompatibility(savedObj);

        end
        %------------------------------------------------------------------

        function savedObj = handleSaveStartupFcnForCompatibility(obj, savedObj)
            % save the StartupFcn for forward compatibility reasons,
            % earlier releases (16a) used this property for the startup
            % function.
            % this data is hard-coded to be reflective of the default
            % startup callback in prior releases.

            import appdesigner.internal.codegeneration.model.*;

            startupFcn = AppCallback();
            startupFcn.Name = 'startupFcn';
            startupFcn.Comment = getString(message('MATLAB:appdesigner:codegeneration:RunStartupFcnComment'));
            startupFcn.Args = {'app'};
            startupFcn.ReturnArgs = [];
            startupFcn.Type = 'AppStartupFunction';
            startupFcn.ComponentData  = CallbackComponentData.empty;
            startupFcn.CallbackId  = [];

            if (~isempty(obj.ConfigurableStartupFcn))
                startupFcn.Code = obj.ConfigurableStartupFcn.Code;
            else
                startupFcn.Code = [];
            end

            savedObj.StartupFcn = startupFcn;
        end
        %------------------------------------------------------------------
    end


end
