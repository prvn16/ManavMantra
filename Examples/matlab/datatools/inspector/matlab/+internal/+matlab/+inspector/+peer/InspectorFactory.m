classdef InspectorFactory < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class is the peer Inspector Factory for the Property Inspector
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Constant)
        % PeerModelChannel
        PeerModelChannel = '/InspectorPropertyManager';
        
        % Force New Instance
        % Used to force creation of a new instance for testing purposes
        ForceNewInstance = 'force_new_instance';
        
        % Default Cache Path
        CachePath = fullfile(matlabroot,'toolbox','matlab','datatools','inspector','registration');
        
        % Default Cache File Name
        CacheFileName = 'inspectorProxyViewMapCache.mat';
        
        PrefdirPath = fullfile(prefdir, internal.matlab.inspector.peer.InspectorFactory.CacheFileName)

        % Default Proxy View Mapping File Cache
        DefaultProxyViewMapCacheFile = fullfile(...
            internal.matlab.inspector.peer.InspectorFactory.CachePath,...
            internal.matlab.inspector.peer.InspectorFactory.CacheFileName);
    end
    
    properties (SetAccess = protected)
        % Peer Manager and Channel for the Property Inspector
        PeerManager;
        Channel;
        
        % Peer Event Listener
        PeerEventListener;
        
        % Property Event Listener
        PropertySetListener;
        
        % Temp Inspector
        TempInspector;

        % Proxy View Mapping File Cache
        ProxyViewMapCacheFile = internal.matlab.inspector.peer.InspectorFactory.DefaultProxyViewMapCacheFile;
    end
    
    % ProxyViewMap
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=true)
        % ProxyViewMap Property
        ProxyViewMap@containers.Map;

        % ProxyViewMapJSON Property
        ProxyViewMapJSON@containers.Map;
    end %properties
    
    events
        InspectorFocusGained;  % Sent from the factory when a manager gains focus
        InspectorFocusLost;  % Sent from the factory when manager loses focus
    end
    
    methods (Access = protected)
        function this = InspectorFactory()			
			
			% Defaults
			this.Channel = internal.matlab.inspector.peer.InspectorFactory.PeerModelChannel;
			this.ProxyViewMap = containers.Map;
			this.ProxyViewMapJSON = containers.Map;
			
            this.loadCacheFile(this.ProxyViewMapCacheFile);

            % Create a temporary inspector           
            this.TempInspector = internal.matlab.inspector.peer.InspectorFactory.createTempInspector();
            this.TempInspector.UseTimerForHandleObjects = false;

            % Creates a new InspectorFactory instance
            Root = ...
                [internal.matlab.inspector.peer.InspectorFactory.PeerModelChannel ...
                '_Root'];
            % Create new Peer Manager
            this.PeerManager = ...
                internal.matlab.variableeditor.peer.PeerManager(...
                internal.matlab.inspector.peer.InspectorFactory.PeerModelChannel, ...
                Root, true);
            
            % Add peer event listener
            this.PeerEventListener = ...
                event.listener(this.PeerManager.PeerModelServer.getRoot, ...
                'PeerEvent', @this.handlePeerEvent);
            
            % Add Property Set Listener
            this.PropertySetListener = event.listener(...
                this.PeerManager.PeerModelServer.getRoot, 'PropertySet', ...
                @this.handlePropertySet);
          
            
            % Set initialized property on the PeerManager
            this.PeerManager.setProperty('Initialized', true);
            
            % Send the maps to the client
            this.sendProxyViewMapToClient();

            % Send event for the factory ready
            internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(...
                this.PeerManager.getRoot(), 'FactoryInitialized');
        end
        
        function loadCacheFile(this, filePath)
            % Creates the proxyview map
            this.ProxyViewMap = containers.Map;
            this.ProxyViewMapJSON = containers.Map;
            
            % if the cache file exist in prefdir, and is newer than the
            % installed cache file, we use that. if not, we load the cache file
            % from the installation and add help information into it and save it
            % to prefdir
            prefdirPath = internal.matlab.inspector.peer.InspectorFactory.PrefdirPath;
            loadDefaultCache = false;
            if internal.matlab.inspector.peer.InspectorFactory.usePrefDirCacheFile(...
                    internal.matlab.inspector.peer.InspectorFactory.PrefdirPath, ...
                    internal.matlab.inspector.peer.InspectorFactory.DefaultProxyViewMapCacheFile)
                try
                    s = load(prefdirPath);
                    this.ProxyViewMap = s.ProxyViewMap;
                    this.ProxyViewMapJSON = s.ProxyViewMapJSON;
                    % go back to use the original file if this fails
                catch
                    loadDefaultCache = true;
                end
            else
                loadDefaultCache = true;
            end
            
            if loadDefaultCache && exist(this.ProxyViewMapCacheFile, 'file')
                this.loadAddHelpAndSaveCache(filePath, prefdirPath);
            end
        end
        
        function loadAddHelpAndSaveCache(this, filePath, prefdirPath)
            s = load(filePath);
            this.ProxyViewMap = s.ProxyViewMap;
            this.ProxyViewMapJSON = s.ProxyViewMapJSON;
            this.addHelpAndTranslatedGroupsToCache(s.ProxyViewMapJSON);
            s.ProxyViewMapJSON = this.ProxyViewMapJSON;
            save(prefdirPath, '-struct', 's');
        end
        
        function saveProxyViewMapCacheFile(this)
            ProxyViewMap = this.ProxyViewMap; %#ok<NASGU,PROP>
            ProxyViewMapJSON = this.ProxyViewMapJSON; %#ok<NASGU,PROP>
            save(this.ProxyViewMapCacheFile,...
                'ProxyViewMap','ProxyViewMapJSON');

            % Send the maps to the client
            this.sendProxyViewMapToClient();
        end
    
        function sendProxyViewMapToClient(this)
            % Generate the JSON Array of all proxy view mappings
            appKeys = keys(this.ProxyViewMapJSON);
            jsonStr = '[';
            for i=1:length(appKeys)
                app = appKeys{i};
                map = this.ProxyViewMapJSON(app);
                classKeys = keys(map);
                for j=1:length(classKeys)
                    class = classKeys{j};
                    classJSON = map(class);
                    
                    % Only send the class data if it contains the defaults for
                    % the class.  (Some objects which could not be accessed at
                    % build time may not have the default data, and so would be
                    % of no use by the client).
                    if contains(classJSON, 'defaults')
                        if length(jsonStr)>1
                            jsonStr = [jsonStr ',']; %#ok<AGROW>
                        end
                        jsonStr = [jsonStr classJSON]; %#ok<AGROW>
                    end
                end
            end
            jsonStr = [jsonStr ']'];
            this.PeerManager.setProperty('ProxyViewMap', ...
                jsonStr);
        end
        
        function updateProxyClassMapping(this, className, application, proxyClass, proxyJSON)
            if ~isKey(this.ProxyViewMap, application)
                this.ProxyViewMap(application) = containers.Map;
                this.ProxyViewMapJSON(application) = containers.Map;
            end
            
            if nargin<4 || isempty(proxyClass)
                proxyClass = [];
            end
            
            if nargin<5 || isempty(proxyJSON)
                proxyJSON = '';
            end

            % Get the class name maps
            map = this.ProxyViewMap(application);
            jsonMap = this.ProxyViewMapJSON(application);
            
            % Update classname maps
            map(className) = proxyClass;
            jsonMap(className) = proxyJSON;

            % Store changes back
            this.ProxyViewMap(application) = map;
            this.ProxyViewMapJSON(application) = jsonMap;

            this.saveProxyViewMapCacheFile();
        end
    end
    
    methods
        % Handles all peer events from the client
        function handlePeerEvent(this, ~, ed)
            if isfield(ed.EventData,'source') && ...
                    strcmp('server',ed.EventData.source)
                % Ignore events generated by the server
                return;
            end
            
            if isfield(ed.EventData,'type')
                try
                    switch ed.EventData.type
                        case 'CreateInspector'
                            % Fired to start a server peer manager for an
                            % inspector
                            this.logDebug('InspectorFactory', ...
                                'handlePeerEvent', 'CreateInspector');
                            this.createInspector(ed.EventData.application, ...
                                ed.EventData.channel);
                            
                        case 'DeleteInspector'
                            % Fired to delete a server peer manager
                            % inspector
                            this.logDebug('InspectorFactory', ...
                                'handlePeerEvent', 'DeleteInspector');
                            % Get the manager instance and delete it
                            if this.getInspectorInstances.isKey(...
                                    ed.EventData.channel)
                                % Get the Property Inspector which is
                                % referenced by the key
                                manager = this.createInspector(...
                                    ed.EventData.application, ...
                                    ed.EventData.channel);
                                
                                % Delete the Property Inspector
                                delete(manager);
                            end
                            
                        case 'RegisterInspectorView'
                            % Fired to start a server peer manager for an
                            % inspector
                            this.logDebug('InspectorFactory', ...
                                'handlePeerEvent', 'RegisterInspectorView');
                            if isfield(ed.EventData,'defaultObj')
                                obj = ed.EventData.defaultObj;
                            else
                                obj = '';
                            end
                            this.registerInspectorView(...
                                ed.EventData.className,...
                                ed.EventData.application,...
                                ed.EventData.proxyViewClass,...
                                obj);
                    end
                catch e
                    % Send the error message back to the client
                    this.sendErrorMessage(e.message);
                end
            end
        end
        
        function status = handlePropertySet(~, ~, ed)
            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success, an
            % error message otherwise.
            status = '';
            
            if ~isa(ed.EventData.newValue, 'java.util.HashMap')
                return;
            end
            
            if ed.EventData.newValue.containsKey('Source') && ...
                    strcmp('server',ed.EventData.newValue.get('Source'))
                % Ignore events generated by the server
                return;
            end
            
        end
        
        function logDebug(this, class, method, message, varargin)
            % Logs debug information using PeerUtils
            rootNode = this.PeerManager.getRoot();
            internal.matlab.variableeditor.peer.PeerUtils.logDebug(...
                rootNode, class, method, message, varargin{:});
        end
        
        function sendErrorMessage(this, message)
            % Sends an error message to the client
            this.PeerManager.getRoot.dispatchEvent(struct(...
                'type', 'error', ...
                'message', message, ...
                'source','server'));
        end
        
        %load help information into the cacheMap
        function addHelpAndTranslatedGroupsToCache(~, viewMap)
            import internal.matlab.inspector.peer.InspectorFactory;
            import internal.matlab.inspector.Utils;
            
            for applicationKey = keys(viewMap)
                if ~strcmp(applicationKey, 'default')
                    applicationMap = viewMap(char(applicationKey));
                    hasHelp = Utils.hasHelpInfo(applicationMap);
                    
                    for objectKey = keys(applicationMap)
                        % objectString will be something like:
                        % [{\"name\":\"GraphicsSmoothing\",\"displayName\":\"GraphicsSmoothing\",\"tooltip\":\"\",\"dataType\":\"char\",
                        %\"className\":\"matlab.graphics.datatype.on_off\",\"renderer\":\"variableeditor/views/editors/CheckBoxEditor\",
                        %\"inPlaceEditor\":\"variableeditor/views/editors/CheckBoxEditor\",\"editor\":\"\",\"editable\":true}]
                        objectString = string(applicationMap(char(objectKey)));

                        if ~hasHelp                           
                            tooltipProp = Utils.getObjectProperties(objectKey);
                            
                            for index = 1:size(tooltipProp, 2)
                                propertyName = tooltipProp(index).property;
                                tooltip = strcat(tooltipProp(index).description, '||', tooltipProp(index).inputs);
                                
                                propertyNameInJSON = '"name\":\"'+ string(propertyName)+ '\",\"displayName\":';
                                if objectString.contains(propertyNameInJSON)
                                    tooltipindex = strfind(objectString.extractAfter(propertyNameInJSON),'tooltip');
                                    insertindex = strfind(objectString, propertyNameInJSON)+ strlength(propertyNameInJSON) + tooltipindex(1:1) + 11;
                                    for i = 1:size(insertindex)
                                        objectString = insertBefore(objectString, insertindex(i), tooltip);
                                    end
                                end
                            end
                        end

                        % Replace group name tags with translated group names
                        objectString = InspectorFactory.replaceTagsWithXlatedGroupNames(objectString);
                        applicationMap(char(objectKey)) = char(objectString);
                    end
                end
            end
        end
    end
    
    methods (Static, Access = protected)
        function runRegistrator(className)
            fprintf('Registering Inspector Components: %s\n', className);
            instance = eval(className);
            instance.registerInspectorComponents;
        end
        
        function runRegistratorsInPath(startPath)
            if (nargin < 1) || isempty(startPath)
                startPath = {'internal'};
            end
            
            % There can be multiple start paths based on the parameters
            % passed to the buildRegistration. Make sure all the
            % registrators in the start paths are built
            for numPaths=1:length(startPath)
                mClasses = internal.findSubClasses(startPath{numPaths},...
                    'internal.matlab.inspector.peer.InspectorRegistrator', true);
                
                for i=1:length(mClasses)
                    className = mClasses{i}.Name;
                    internal.matlab.inspector.peer.InspectorFactory.runRegistrator(className);
                end
            end
        end
    end
    
    methods(Static)
        % getInstance - returns an instance of the Inspector Factory
        function obj = getInstance(varargin)
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance) || ~isvalid(managerInstance) || ...
                    (nargin>0 && ...
                    strcmpi(varargin{1}, ...
                    internal.matlab.workspace.peer.PeerManager.ForceNewInstance))
                
                % Create a new Inspector Factory
                managerInstance = ...
                    internal.matlab.inspector.peer.InspectorFactory;
            end
            obj = managerInstance;
        end
        
        function obj = getInspectorInstances(newInspectorInstances)
            % Returns the list of inspector instances that have been
            % created.
            mlock; % Keep persistent variables until MATLAB exits
            persistent InspectorInstances;
            
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;
            
            if nargin > 0
                % Set the new inspector instances
                InspectorInstances = newInspectorInstances;
                factoryInstance.logDebug('InspectorFactory', ...
                    'getInspectorInstances', 'set');
                keys = InspectorInstances.keys();
                managerJSON = ['[' sprintf('"%s",',keys{:})];
                managerJSON(end) = ']';
                
                factoryInstance.PeerManager.setProperty('Managers', ...
                    managerJSON);
                
            elseif isempty(InspectorInstances)
                % Create the inspectorInstances map for the first time
                factoryInstance.logDebug('InspectorFactory', ...
                    'getInspectorInstances', 'initial creation');
                InspectorInstances = containers.Map();
                
            else
                factoryInstance.logDebug('InspectorFactory', ...
                    'getInspectorInstances', 'get');
            end
            
            % Return the inspector instances map
            obj = InspectorInstances;
        end
        
        function varargout = createInspector(Application, Channel)
            % Creates a Property Inspector
            mlock; % Keep persistent variables until MATLAB exits
            persistent inspectorCounter;
            persistent deleteListeners;
            
            if isempty(inspectorCounter)
                inspectorCounter = 0;
            end
            
            if nargin<1 || isempty(Application)
                % Setup a default application if it wasn't provided
                Application = 'default';
            end
            
            % Update the counter
            inspectorCounter = inspectorCounter + 1;
            
            if nargin<2 || isempty(Channel)
                % Setup a default channel if it wasn't provided
                Channel = ['/Inspector_' num2str(inspectorCounter)];
            end
            
            % Get the factory instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;
            factoryInstance.logDebug('InspectorFactory', 'createManager', ...
                '', 'Application', Application, 'Channel', Channel);
            
            % Get the list of inspector instances
            InspectorInstances = ...
                internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances;
            if isempty(deleteListeners)
                deleteListeners = containers.Map();
            end
            
            if ~isKey(InspectorInstances, Channel)
                % Create a new Peer Inspector Manager instance
                managerInstance = ...
                    internal.matlab.inspector.peer.PeerInspectorManager(...
                    Application, Channel);
                InspectorInstances(Channel) = managerInstance;
                
                % Add a listener for when it is destroyed
                deleteListeners(Channel) = event.listener(managerInstance,...
                    'ObjectBeingDestroyed',...
                    @(es,ed) (internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances(...
                    InspectorInstances.remove(Channel))));
                
                internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances(InspectorInstances);
            end
            
            % Return the new manager instances
            obj = InspectorInstances(Channel);
            
            % Send event for the manager creation
            internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(...
                factoryInstance.PeerManager.getRoot(), 'InspectorCreated', ...
                'Application', obj.Application, 'Channel', Channel);
            
            if nargout == 1
                % Return the inspector instance if an argument is expected
                varargout = {obj};
            end
        end
        
        function destroyInspector(objOrKey)
            % Deletes the specified inspector.  objOrKey can be the
            % Inspector object, or it can be a key (the channel ID)
            inspectorInstances = ...
                internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances;
            if ischar(objOrKey)
                % This is a key, look for it in the list of instances
                if isKey(inspectorInstances, objOrKey)
                    % delete this instance
                    delete(inspectorInstances(objOrKey));
                end
            else
                % This is an inspector instance, find it in the map and
                % delete it
                allKeys = keys(inspectorInstances);
                for i = 1:length(allKeys)
                    key = allKeys{i};
                    if isequal(inspectorInstances(key), objOrKey)
                        delete(objOrKey);
                        break;
                    end
                end
            end
        end
        
        function registerEditor(className, clientEditorPath)
            % Register an editor for a given class name
            wr = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance;
            wr.registerEditor(...
                'internal.matlab.inspector.peer.PeerInspectorViewModel',...
                className, clientEditorPath);
        end
        
        function registerInPlaceEditor(className, clientEditorPath)
            % Register an in-place editor for a given class name
            wr = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance;
            wr.registerInPlaceEditor(...
                'internal.matlab.inspector.peer.PeerInspectorViewModel',...
                className, clientEditorPath);
        end
        
        function registerRenderer(className, clientRendererPath)
            % Register a renderer for a given class name
            wr = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance;
            wr.registerCellRenderer(...
                'internal.matlab.inspector.peer.PeerInspectorViewModel',...
                className, clientRendererPath);
        end
        
        function registerEditorConverter(variableClass, converter)
            % Register a renderer for a given class name
            wr = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance;
            wr.registerEditorConverter('internal.matlab.inspector.peer.PeerInspectorViewModel',...
                variableClass,...
                converter);
        end
        
        function registerInspectorView(className, application, propertySheet, defaultObj)
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            if nargin<2 || isempty(application)
                application = 'default';
            end
            if nargin<1 || isempty(className)
                className = 'default';
            end
            
            if ~isKey(factoryInstance.ProxyViewMap, application)
                factoryInstance.ProxyViewMap(application) = containers.Map;
                factoryInstance.ProxyViewMapJSON(application) = containers.Map;
            end

            % Get the class name maps
            map = factoryInstance.ProxyViewMap(application);
            if isKey(map, className)
                return;
            end
            
            if nargin<3 || isempty(propertySheet)
                % Get the class name maps
                map = factoryInstance.ProxyViewMap(application);
                jsonMap = factoryInstance.ProxyViewMapJSON(application);
                
                % Update classname maps
                map(className) = [];
                jsonMap(className) = '';
                
                % Store changes back
                factoryInstance.ProxyViewMap(application) = map;
                factoryInstance.ProxyViewMapJSON(application) = jsonMap;
                return;
            end

            if ~isa(propertySheet, 'internal.matlab.inspector.InspectorProxyMixin') &&...
                    ~ischar(propertySheet)
                %TODO: put this in the message catalog
                error('Property Sheet must extend internal.matlab.inspector.InspectorProxyMixin');
            end
            
            % If a default object is not passed in attempt to create an
            % instance of one of the passed in classes
            if (nargin<4 || isempty(defaultObj)) &&...
                    ~isa(propertySheet, 'internal.matlab.inspector.InspectorProxyMixin')
                defaultObj = []; 

                % try to create an instance of the class
                if ~strcmp(className, 'default')
                    try
                        defaultObj = eval([className '()']); 
                        if ismember('matlab.graphics.Graphics', superclasses(className))
                            drawnow('nocallbacks');
                        end
                    catch
                    end
                end
            end

            % Try to create an instance of the proxy object
            [jsonData, proxyObject] = internal.matlab.inspector.peer.InspectorFactory.getJSONDataForObject(...
                application, className, propertySheet, factoryInstance.TempInspector, defaultObj);
            
            % Update the client mapping
            factoryInstance.updateProxyClassMapping(className, application, class(proxyObject), jsonData);
        end
        
        function [jsonData, proxyObject] = getJSONDataForObject(application, className, propertySheet, TempInspector, defaultObj)
            s = struct('application', application, 'className', className);
            
            try
                proxyObject = propertySheet;
                if ~isa(propertySheet, 'internal.matlab.inspector.InspectorProxyMixin')
                    proxyObject = eval([propertySheet '(defaultObj)']);
                    
                    if ~isa(proxyObject, 'internal.matlab.inspector.InspectorProxyMixin')
                        %TODO: put this in the message catalog
                        error('Property Sheet must extend internal.matlab.inspector.InspectorProxyMixin');
                    end
                end
            catch
                proxyObject = [];
            end
            
            if ~isempty(defaultObj)
                % Create a temporary inspector and get the rendered data for it.
                % Don't use a try/catch here -- we want errors to break the
                % build if they occur
                TempInspector.inspect(proxyObject);
                TempInspector.Documents(1).ViewModel.DataModel.stopTimer;
                rows = TempInspector.Documents(1).ViewModel.getSize();
                rows = rows(1);
                rd = TempInspector.Documents(1).ViewModel.getRenderedData(1,rows,1,1);
                s.defaults = strcat(rd{:});
            end
            jsonData = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, s);
            
            TempInspector.closeAllVariables();
        end
        
        function proxyClass = getInspectorView(className, application)
            proxyClass = [];

            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            if nargin<2 || isempty(application)
                application = 'default';
            end
            if nargin<1 || isempty(className)
                className = 'default';
            end
            
            if ~isKey(factoryInstance.ProxyViewMap, application)
                return;
            end
            
            % Get the class name maps
            map = factoryInstance.ProxyViewMap(application);
            if ~isKey(map, className)
                return;
            end
            
            proxyClass = map(className);
        end

        function clearInspectorViewCache()
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            factoryInstance.ProxyViewMap = containers.Map;
            factoryInstance.ProxyViewMapJSON = containers.Map;
            
            factoryInstance.saveProxyViewMapCacheFile();
        end

        function buildRegistration(outputFile, varargin)
            if nargin<1 || isempty(outputFile)
                outputFile = internal.matlab.inspector.peer.InspectorFactory.CachePath;
            end

            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            currentProxyViewMap = factoryInstance.ProxyViewMap;
            currentProxyViewMapJSON = factoryInstance.ProxyViewMapJSON;

            factoryInstance.ProxyViewMap = containers.Map;
            factoryInstance.ProxyViewMapJSON = containers.Map;

            % Clear the current data
            if exist(outputFile, 'file')
                delete(outputFile);
            end

            factoryInstance.ProxyViewMapCacheFile = fullfile(outputFile);

			if nargin>1
				internal.matlab.inspector.peer.InspectorFactory.runRegistratorsInPath(varargin);
			else
				internal.matlab.inspector.peer.InspectorFactory.runRegistratorsInPath();
			end
            
            factoryInstance.ProxyViewMapCacheFile = internal.matlab.inspector.peer.InspectorFactory.DefaultProxyViewMapCacheFile;

            factoryInstance.ProxyViewMap = currentProxyViewMap;
            factoryInstance.ProxyViewMapJSON = currentProxyViewMapJSON;
        end

        function deregisterApplicationInspectorViews(application)
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            if nargin<1 || isempty(application)
                application = 'default';
            end

            % Store changes back
            factoryInstance.ProxyViewMap(application) = containers.Map;
            factoryInstance.ProxyViewMapJSON(application) = containers.Map;

            factoryInstance.saveProxyViewMapCacheFile();
        end
        
        function deregisterInspectorView(className, application)
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            if nargin<2 || isempty(application)
                application = 'default';
            end
            if nargin<1 || isempty(className)
                className = 'default';
            end
        
            % Update the client mapping
            factoryInstance.updateProxyClassMapping(className, application, [], []);
        end

        function setProxyCacheFile(filePath)
            % Factory Instance
            factoryInstance = ...
                internal.matlab.inspector.peer.InspectorFactory.getInstance;

            factoryInstance.ProxyViewMapCacheFile = filePath;

            factoryInstance.loadCacheFile(filePath);
        end
        
        function startup()
            % Makes sure the peer manager for the variable editor exists
            internal.matlab.inspector.peer.InspectorFactory.getInstance();
        end
    end
    
    methods(Static = true, Hidden = true)
        function usePrefDirFile = usePrefDirCacheFile(prefdirPath, cacheFile)
            % If the cache file in the user's preferences is newer than the
            % installed one, try to use it.  If not, this may mean that the user
            % installed a newer version of Matlab, so we should use the newer
            % version.
            usePrefDirFile = false;
            
            if exist(prefdirPath, 'file')
                prefFileInfo = dir(prefdirPath);
                prefDate = datetime(prefFileInfo.datenum, 'ConvertFrom', 'datenum');
                
                pkgFileInfo = dir(cacheFile);
                pkgDate = datetime(pkgFileInfo.datenum, 'ConvertFrom', 'datenum');
                
                if pkgDate < prefDate
                    usePrefDirFile = true;
                end
            end
        end
        
        function tempInspector = createTempInspector()
            % Create a temporary inspector for use internally, using a unique
            % channel name generated from the tempname filename
            [~, n, ~] = fileparts(tempname);
            tempInspector = ...
                internal.matlab.inspector.peer.PeerInspectorManager(n, ['/' n]);
        end
        
        function objectString = replaceTagsWithXlatedGroupNames(objectString)
            % Called to replace group names which are tags with the translated
            % text.  The objectString is the JSON string which contains an
            % application's property info, group info, and default values.
            
            if contains(objectString, '\"group\",\"name\":\"')
                % First, split to find the groups.  This is the groupData variable
                % contents, which looks something like:
                % "MATLAB:ui:propertygroups:AppearanceGroup\",\"displayName\":\"Appearance\",\"tooltip\":\"\",\"expanded\":true,\"items\...
                % "MATLAB:ui:propertygroups:PlottingGroup\",\"displayName\":\"Plotting\",\"tooltip\":\"\",\"expanded\":true,\"items\...
                % "MATLAB:ui:propertygroups:CallbackExecutionControlGroup\",\"displayName\":\"Callback Execution Control\",\"tooltip\":\"\",\"expanded\":false,\"items\... (other JSON data)
                s2 = split(string(objectString), '\"group\",\"name\":\"');
                groupData = s2(2:end);
                
                % Extract only the group names, and run through the Utils function
                % to see if a translation exists for them.  groupNames will be
                % something like:
                % "MATLAB:ui:propertygroups:AppearanceGroup"
                % "MATLAB:ui:propertygroups:PlottingGroup"
                % "MATLAB:ui:propertygroups:CallbackExecutionControlGroup"
                groupNames = extractBefore(groupData, '\"');
                xlatedGroupNames = string(arrayfun(@internal.matlab.inspector.Utils.getPossibleMessageCatalogString, ...
                    groupNames, 'UniformOutput', false));
                
                % Store all of the remaining text to piece it together afterwards.
                % It will be something like:
                % "\"\",\"expanded\":true,\"items\":[{\"type\":\"property\",\"name\":\"Name\"},{\"type\":\"property\",\"name\":\"Color\"}]},{\"type\":"
                % "\"\",\"expanded\":true,\"items\":[{\"type\":\"property\",\"name\":\"Colormap\"}]},{\"type\":"
                % "\"\",\"expanded\":false,\"items\":[{\"type\":\"property\",\"name\":\"BusyAction\"},{\"type\":\"property\",\"name\":\"Interruptible\"}]}\t\t]},\t\"objects\"...
                remaining = extractAfter(groupData, '\"tooltip\":');
                
                % Begin to reconstruct the original text for the groups (this
                % essentially gets it back to the s2 variable, but with translated
                % group names)
                arr = [s2(1); xlatedGroupNames + '\",\"displayName\":\"' + ...
                    xlatedGroupNames + '\",\"tooltip\":' + remaining];
                
                % join the array back to the original string, but with translated
                % group names.
                objectString = join(arr, '\"group\",\"name\":\"');
            end
        end
    end
end
