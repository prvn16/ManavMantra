classdef WebAppRunner < handle
    % WEBAPPRUNNER Provide API to run an app in web
    %  
    %    The WEBAPPRUNNER interface exposes one static method to run a web
    %    app - runWebApp(appName, appRunCallback, appErrorCallback), which
    %    returns the running app object.
    %
    %    Example:
    %       % Define callback functions
    %       funciton appRunCallback(e)
    %           disp(e.FigureURL);
    %       end
    %
    %       function appErrorCallback(e)
    %           disp(e.getReport());
    %       end
    %
    %       % call runWebApp() method
    %       appObject = appdesigner.internal.service.WebAppRunner.runWebApp('AppToRun', ...
    %                  @appRunCallback, @appErrorCallback);
    
    % Copyright 2016 - 2017 The MathWorks, Inc.
    
    methods(Static)
        function appObject = runWebApp(appName, appRunCallback, appErrorCallback)
            % RUNWEBAPP Run an app as a webapp. 
            %
            % appObject = RUNWEBAPP(appName, appRunCallback, appErrorCallback)
            %
            % Returns:
            % appObject - handle of the running app
            %
            % Inputs:
            % appName - Name of the app to run
            % appRunCallback - Function handle to be called when the app
            % createComponents() execution is completed. The event data has
            % the properties: 
            %      Figure - figure object
            %      FigureURL - figure URL
            %      App - app object
            % appErrorCallback - Function handle to be called when any
            % error or exception happens in the running app. The event data
            % is an exception object of appdesigner.internal.appalert.TrimmedException.
            %
            % This function can throw exception.
            
            appObject = [];
            appManagementService = appdesigner.internal.service.AppManagementService.instance();            
            
            listenerToAppCreateComponentsDone = [];
            listenerToCallbackError = [];
                        
            function handleAppCreateComponentsDone(~, e)
                % Run callback with even data
                appRunCallback(e);
                
                % An app can create components only once, and delete the
                % listener to avoid listening to next app running
                delete(listenerToAppCreateComponentsDone);                
                addlistener(e.Figure, 'ObjectBeingDestroyed', @(src, e)delete(listenerToCallbackError));
            end
            
            function handleCallbackErrored(~, e)                
                exception = appdesigner.internal.appalert.TrimmedException(...
                    e.Exception);
                appErrorCallback(exception);
            end
            
            % Listen to AppCreateComponentsExecutionCompleted to call
            % appRunCallback to notify app layout creation completed
            listenerToAppCreateComponentsDone = addlistener(... 
                appManagementService, 'AppCreateComponentsExecutionCompleted',...
                    @handleAppCreateComponentsDone);
            
            % Listen CallbackErrored event to call appErrorCallback to
            % provide error/exception from the app to caller
            if nargin == 3 
                listenerToCallbackError = addlistener(...
                    appManagementService, 'CallbackErrored',...
                    @handleCallbackErrored);
            end
            try
                appObject = appManagementService.runAppWithTryCatch(appName);
            catch mException
                if  ~isa(mException, 'appdesigner.internal.appalert.CallbackException')
                    % App fails to run. When it's not a CallbackException, 
                    % it means a non-syntax error in startup function, or
                    % app is closed manually when stopping for breakpoint
                    % being hit
                    delete(listenerToAppCreateComponentsDone);
                    delete(listenerToCallbackError);
                end
                rethrow(mException);
            end
        end
    end
    
end

