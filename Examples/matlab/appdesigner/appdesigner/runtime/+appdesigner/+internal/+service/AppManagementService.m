classdef AppManagementService < handle
    % APPMANAGEMENTSERVICE Singleton object to manage running apps
    %
    %
    
    % Copyright 2016 - 2017 The MathWorks, Inc.
    
    properties (Access = private)
        % A map to maintain the mapping relationship between full file
        % name of the app and the running app instance for App Designer
        % design time LiveAlert error handling
        FullFileNameToRunningAppMap
    end
    
    events (ListenAccess = {?appdesigner.internal.appalert.AppAlertController; ...
            ?appdesigner.internal.service.WebAppRunner})
        % This event is fired when there's an exception or error happening
        % in the app's callback or startup function
        CallbackErrored
        
        % This event is invoked when the createComponents() method of the
        % app finishes execution and before app startup is executed,
        % which can be used by clients to know when a figure, and components
        % are done creation before waiting completion of app construction
        AppCreateComponentsExecutionCompleted
    end
    
    methods(Access=private)
        % Private constructor to prevent creating object externally
        function obj = AppManagementService()
            obj.FullFileNameToRunningAppMap = containers.Map();
        end
    end
    
    methods(Static)
        % Get singleton instance of the AppManagementService
        function obj = instance()
            persistent localUniqueInstance;
            if isempty(localUniqueInstance)
                obj = appdesigner.internal.service.AppManagementService();
                localUniqueInstance = obj;
            else
                obj = localUniqueInstance;
            end
        end
        
        % Get figure handle in the running app
        function appFigure = getFigure(app)
            % Used by Compiler team now. When they can use new API, try to
            % remove it
            %
            
            appFigure = [];
            
            runningAppFigures = findall(0, 'Type', 'figure', ...
                'RunningAppInstance', app);
            if ~isempty(runningAppFigures)
                % If found, there should be only one match
                appFigure = runningAppFigures(1);
            end
        end
    end
    
    methods
        function runningApp = runDesktopApp(obj, appFullFileName, appArguments)
            % Run the App as if by command line
            % This method is only used by App Designer to run an app
            
            [appPath, appName] = fileparts(appFullFileName);
            
            % Add to the MATLAB search path to ensure callback or user
            % authored functions executed correctly. If the path already
            % in the search path, it would move it to the top
            pathWithSep = [appPath pathsep];
            if(~strncmp(pathWithSep, path, length(pathWithSep)))
                addpath(appPath);
            end
            
            % The app to be run may have different properties, and functions
            % from last time running. We have to clear the class defintion
            % so that the new properties, and functions are updated into the
            % the MCOS class definition in MATLAB.
            clear(appName);
            
            % Initialize FullFileNameToRunningAppMap
            obj.FullFileNameToRunningAppMap(appFullFileName) = [];
            
            try
                runningApp = obj.runAppWithTryCatch(appFullFileName, appArguments);
            catch exception
                if isa(exception, 'appdesigner.internal.appalert.CallbackException')
                    runningApp = exception.App;
                    obj.FullFileNameToRunningAppMap(appFullFileName) = runningApp;
                end
                
                % Rethrow exception to let caller have a chance to handle
                % it
                rethrow(exception);
            end
            
            % Run app successfully, and no exceptions being caught
            obj.FullFileNameToRunningAppMap(appFullFileName) = runningApp;
        end
        
        function runningApp = getRunningApp(obj, fullFileName)
            % Get running app using its full file name
            
            runningApp = [];
            
            if obj.FullFileNameToRunningAppMap.isKey(fullFileName)
                runningApp = obj.FullFileNameToRunningAppMap(fullFileName);
            end
        end
        
        function value = isAppRunInAppDesigner(obj, fullFileName)
            % Returns true if app is run using App Designer
            
            value = obj.FullFileNameToRunningAppMap.isKey(fullFileName);
        end
        
        function register(obj, app, uiFigure)
            % Set up listener and callback for running app
            
            validateattributes(app, ...
                {'matlab.apps.AppBase'}, ...
                {});
            
            obj.manageApp(app, uiFigure);
        end
        
        function unregister(obj, app)
            % Do cleanup when unregistering the app
            
            validateattributes(app, ...
                {'matlab.apps.AppBase'}, ...
                {});
            
            % Remove full file name and running app mapping
            appFullFileName = obj.getAppFullFileName(app);
            if (~isempty(appFullFileName))
                % Only running the app from App Designer will register the
                % full file name and app mapping, and then needs to remove
                obj.FullFileNameToRunningAppMap.remove(appFullFileName);
            end
            
            % Clear class definition to avoid name shadowing
            appClassName = class(app);
            clear(appClassName);
        end
    end
    
    methods (Access ={?appdesigner.internal.service.WebAppRunner})
        function runningApp = runAppWithTryCatch(obj, appFullFileName, appArguments)
            [~, appName] = fileparts(appFullFileName);
            
            if nargin == 2
                appArguments = '';
            end
            
            try
                runningApp = evalin('base', sprintf('%s(%s);', appName, appArguments));
            catch exception
                if ~isa(exception, 'appdesigner.internal.appalert.TrimmedException')
                    % Exception from app's constructor, and app object
                    % will not be created, for example, syntax error in the
                    % app
                    
                    if (~isempty(appArguments) && ...
                            isempty(regexp(exception.message, appName, 'once')))
                        % an exception occurred before evaluating app code -
                        % should be a argument exception. Exceptions inside the
                        % app will have the full app name and path at the top
                        % of the stack
                        trimmedException = appdesigner.internal.appalert.AppArgumentException(exception);
                    else
                        trimmedException = appdesigner.internal.appalert.TrimmedException(exception);
                    end
                    
                    obj.fireCallbackErroredEvent(trimmedException, appFullFileName);
                    
                    % Throw the exception to let caller handle it
                    throw(trimmedException);
                else
                    % An exception from app's startup function or callbacks
                    % Rethrow the exception to let caller handle it
                    % tryCallback() who throws this exception already
                    % fireCallbackErroredEvent().
                    rethrow(exception);
                end
            end
        end
    end
    
    methods (Access = private)
        function manageApp(obj, app, uiFigure)
            % 1) Make running figure have a dynamic property to point to the
            % running app instance, and a dynamic property to have the full
            % filename of the app
            appInstanceProp = addprop(uiFigure, 'RunningAppInstance');
            appInstanceProp.Transient = true;
            uiFigure.RunningAppInstance = app;
            
            [fileName, ~] = which(class(app));
            fileNameProp = addprop(uiFigure, 'RunningAppFullFileName');
            fileNameProp.Transient = true;
            fileNameProp.Hidden = true;
            uiFigure.RunningAppFullFileName = fileName;
            
            % 2) Set up listener to figure destroyed event
            addlistener(uiFigure, 'ObjectBeingDestroyed', @(src, e)delete(app));
            
            % 3) Fire AppCreateComponentsExecutionCompleted event. At this
            % point, the app's layout, including figure, components, has
            % been created
            notify(obj, 'AppCreateComponentsExecutionCompleted', ...
                appdesigner.internal.service.CreateComponentsCompletedEventData(app, uiFigure));
        end
        
        function fullFileName = getAppFullFileName(obj, app)
            fullFileName = [];
            
            appFullFileNames = obj.FullFileNameToRunningAppMap.keys();
            ix = find(cellfun(@(x)~isempty(obj.FullFileNameToRunningAppMap(x)) && ...
                eq(obj.FullFileNameToRunningAppMap(x), app), appFullFileNames),...
                1);
            
            if (ix > 0)
                % Can get the running app's full file name only when
                % running from App Designer
                fullFileName = appFullFileNames{ix};
            else
                [fileNameFromWhich, ~] = which(class(app));
                if obj.FullFileNameToRunningAppMap.isKey(fileNameFromWhich)
                    % The app is run from App Designer, and so use the full
                    % file name from which() command as app full file name.
                    % This case happens because the exception is thrown
                    % from component's callback when calling
                    % createComponents() in constructor
                    fullFileName = fileNameFromWhich;
                end
            end
        end
        
        function fireCallbackErroredEvent(obj, exception, appFullFileName)
            notify(obj, 'CallbackErrored', ...
                appdesigner.internal.appalert.CallbackErroredData(exception, appFullFileName));
        end
        
        function isException = isBadNumberOfArguments(~, app, exception)
            % determines if a given exception is a due to calling the
            % startup function from the constructor with an incorrect
            % number of arguments;
            appMetaData = metaclass(app);
            isException = false;
            % find in the stack where the this class's runAppWithTryCatch function is
            % called
            stackLevel = find(strcmp('AppManagementService.runAppWithTryCatch', {exception.stack.name}));
            % check that this call to the startupFcn is called from this
            % class and from these levels at the top of the stack: 
            % runAppWithTryCatch, constructor, runStartupFcn, tryCallback,
            % anonymousFcn
            if (~isempty(stackLevel) && stackLevel >= 5 && ...
                     ... call from anonymous
                    strncmp(exception.stack(stackLevel - 4).name, '@(app)', 6) && ...
                    ... call from startupFcn
                    strcmp(exception.stack(stackLevel - 2).name, 'AppBase.runStartupFcn') && ...
                    ... call from constructor
                    strcmp(exception.stack(stackLevel - 1).name, [appMetaData.Name '.' appMetaData.Name]) && ...
                    ... check to see if it is an exception with too many inputs at the top of the stack
                    ((any(strcmp(exception.identifier,  {'MATLAB:TooManyInputs', 'MATLAB:maxrhs'})) && (stackLevel - 5) == 0  || ...
                    ... check to see if it is an exception with too few inputs at the stop of the stack.
                    ... exceptio will have startupFcn at top of the stack
                    strcmp(exception.identifier, 'MATLAB:minrhs') && (stackLevel - 5) == 1)))
                isException = true;
            end
        end
    end
    
    methods (Access = {?matlab.apps.AppBase})
        function tryCallback(obj, app, callback, requiresEventData, event)
            try
                if requiresEventData
                    callback(app, event);
                else
                    % For callbacks that do not need events
                    callback(app);
                end
            catch exception
                % Query app's fullfilename from the map of fullfilename to
                % the running app within the service object
                appFullFileName = obj.getAppFullFileName(app);
                
                if (obj.isBadNumberOfArguments(app, exception))
                    % check if the startup function is being executed with too
                    % many or too few arguments and rethrow that error with an
                    % additional cause
                    % remove the app so the figure will not remain open
                    delete(app);
                    
                    if (strcmp(exception.identifier, 'MATLAB:minrhs'))
                        newException = MException(message('MATLAB:appdesigner:appdesigner:TooFewAppArgumentsError'));
                        newException = newException.addCause(appdesigner.internal.appalert.TrimmedException(exception));
                        callbackException = appdesigner.internal.appalert.TrimmedException(newException);
                    else
                        callbackException = appdesigner.internal.appalert.AppArgumentException(exception);
                    end
                   
                else
                    if ~isvalid(app)
                        % If app is not valid, which is a very subtle case,
                        % that the user could put a break point on the code,
                        % and when hitting, the user closes the running
                        % app manually, and then continue debugging.
                        [appFullFileName, ~] = which(class(app));
                        
                        callbackException = appdesigner.internal.appalert.TrimmedException(exception);
                    else
                        % When startup method called in app's constructor has a
                        % non-syntax parsing error, for example, reference a
                        % undefined variable: disp(undefinedVariable), the app will
                        % still be created, but not populated, so put the app into
                        % exception to let the caller get it
                        callbackException = appdesigner.internal.appalert.CallbackException(exception, app);
                    end
                end
                
                % Fire callback errored event to notify clients
                obj.fireCallbackErroredEvent(callbackException, appFullFileName);
                
                throw(callbackException);
            end
        end
    end
end
