classdef AppCodeTool < handle
    %APPCODETOOL Processes goto and debug events by ensuring that the app
    % is opened and ready before passing along the event to the client.
    %   
    %    Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Access = private)
        % AppDesignEnvironment instance
        AppDesignEnvironment
        
        % Listener to AppModel InstanceCreated class event
        AppModelCreatedListener
        
        % Listener to CodeModel InstanceCreated class event
        CodeModelCreatedListener
        
        % Queue of debug events that occur while app is loading
        DebugEventQueue = {};
    end
    
    methods
        function obj = AppCodeTool(appDesignEnvironment)
            obj.AppDesignEnvironment = appDesignEnvironment;
        end
        
        function processGoToLineColumn(obj, file, line, column)
        %  PROCESSGOTOLINECOLUMN Go to line/column in the app's Code
        %  View
            
            scrollToView = true;
            obj.doProcessGoToLineColumn(file, line, column, scrollToView,...
                @obj.processGoToAppReadyCallback);
        end
        
        function processDebugInfo(obj, currentMlappFilename, currentMlappLineNumber, mlappsInStack)
        %  PROCESSDEBUGMLAPP Process debug event involving MLAPPs
        %     
        %   processDebugInfo() will
        %       1) Set debug state of all apps opened in App Designer that
        %       are found in the debug call stack (mlappsInStack)
        %
        %       2) Open/Bring to front the app, if any, that is the current
        %       frame on the call stack (currentMlappFilename). 
        %       It uses doProcessGoToLineColumn to bring code view to front
        %       and place the cursor on the line where execution is stopped
        %       for debugging
        %
        %       3) Queues calls to processDebugInfo that occur while the 
        %       debugging app is loading. Once the app is done loading, the 
        %       queue is flushed and processed.
        
            if isempty(obj.AppModelCreatedListener)
                % No app is loading and so proceed with processing the data
                
                % Ensure the path file seperators are consistent
                currentMlappFilename  = fullfile(currentMlappFilename); 

                % Process mlappsInstack 
                appDesignerModel = obj.AppDesignEnvironment.AppDesignerModel;
                for idx = 1 : length(appDesignerModel.Children)
                    appModel = appDesignerModel.Children(idx);
                    if any(strcmpi(appModel.FullFileName, mlappsInStack))
                        % App is in the stack and opened

                        % Only set app's debugging state to true only if it
                        % is not already true
                        if ~appModel.IsDebugging
                            obj.setAppModelIsDebugging(appModel);
                        end
                    else
                        % App is not in the stack

                        % If it was debugging, it is not now and
                        % so set debugging state to false.
                        if appModel.IsDebugging
                            appModel.IsDebugging = false;
                            
                            aws = appdesigner.internal.service.AppManagementService.instance();
                            if aws.isAppRunInAppDesigner(appModel.FullFileName) && ...
                                isempty(aws.getRunningApp(appModel.FullFileName))
                                % dbquit has occured during app construction before
                                % the running app instance could be registered with
                                % the AppManagementService. This can result in the
                                % app's figure being left open which puts the app in
                                % a bad state and so close the figure (g1353572).
                                appFig = obj.findAppFigure(appModel.FullFileName);
                                delete(appFig);
                            end
                        end
                    end
                end

                % Process currentMlappFilename
                if ~isempty(currentMlappFilename)
                    % Since currentMlappFilename is not empty, execution is
                    % stopped in an MLAPP file for debugging. Execute
                    % goToLineColumn to open/bring to front the app in App
                    % Designer and place cursor on the line execution is
                    % stopped on.
                    column = 1;
                    scrollToView = false; % RTC handles scrolling when debugging
                    obj.doProcessGoToLineColumn(currentMlappFilename, currentMlappLineNumber, column, scrollToView,...
                        @obj.processDebugAppReadyCallback);
                end
            else
                % An app is loading and so queue the event to be processed
                % once the app is ready to handle it.
                obj.DebugEventQueue{end+1} = {currentMlappFilename, currentMlappLineNumber, mlappsInStack};
            end
        end
        
        function delete(obj)
            if ~isempty(obj.AppModelCreatedListener)
                % In case of App failed to open, to clean 'InstanceCreated'
                % class event of the AppModel
                delete(obj.AppModelCreatedListener);
                obj.AppModelCreatedListener = [];
            end
            
            if ~isempty(obj.CodeModelCreatedListener)
                % In case of App failed to open, to clean 'InstanceCreated'
                % class event of the CodeModel
                delete(obj.CodeModelCreatedListener);
                obj.CodeModelCreatedListener = [];
            end
        end
    end
    
    methods (Access = private)
        function doProcessGoToLineColumn(obj, file, line, column, scrollToView, appReadyCallback)     
        %   doProcessGoToLineColumn() will send 'goToLineColumn' event to
        %   client side through CodeModel peer node to ask to locate
        %   the code
        
            % Check if the app opened or not
            appModel = [];
            appDesignerModel = obj.AppDesignEnvironment.AppDesignerModel;
            for idx = 1 : length(appDesignerModel.Children)
                if strcmp(file, appDesignerModel.Children(idx).FullFileName) || ...
                        (ispc && strcmpi(file, appDesignerModel.Children(idx).FullFileName))
                    appModel = appDesignerModel.Children(idx);
                    break;
                end
            end
            
            if isempty(appModel)
                % App not opened and so listen to AppModel InstanceCreated
                % class event to handle it
                obj.AppModelCreatedListener = addlistener(?appdesigner.internal.model.AppModel,...
                    'InstanceCreated', ...
                    @(o,e)obj.handleAppModelCreated(e.Instance, file, line, column, scrollToView, appReadyCallback));

                % Load the app
                appdesigner(file);
            else
                % App is opened, Request client to perform goToLineColumn.
                appModel.CodeModel.sendGoToLineColumnEventToClient(line, column, scrollToView);
            end
        end
        
        function handleAppModelCreated(obj, appModel, file, line, column, scrollToView, appReadyCallback)
            % Handler for AppModel 'InstanceCreated' event. 

            % If the AppModel is the one to go to line/column, send the
            % event to the client
            if strcmp(file, appModel.FullFileName)
                delete(obj.AppModelCreatedListener);
                obj.AppModelCreatedListener = [];
                
                if isempty(appModel.CodeModel)
                    % App is opened but CodeModel is not ready yet and so 
                    % listen to CodeModel InstanceCreated class event to handle it
                    obj.CodeModelCreatedListener = addlistener(?appdesigner.internal.codegeneration.model.CodeModel,...
                        'InstanceCreated', ...
                        @(o,e)obj.handleCodeModelCreated(appModel, line, column, scrollToView, appReadyCallback));
                else
                    appReadyCallback(appModel, line, column, scrollToView);
                end
            end
        end
        
        function handleCodeModelCreated(obj, appModel, line, column, scrollToView, appReadyCallback)
            % Handler for CodeModel 'InstanceCreated' event. 
            
            delete(obj.CodeModelCreatedListener);
            obj.CodeModelCreatedListener = [];
            
            appReadyCallback(appModel, line, column, scrollToView);
        end
        
        function processGoToAppReadyCallback(obj, appModel, line, column, scrollToView)
            % Callback to be executed once app has been loaded due to a
            % goToLineColumn event and is ready to be used
            
            % App is loaded and so request client to perform goToLineColumn
            appModel.CodeModel.sendGoToLineColumnEventToClient(line, column, scrollToView);
        end
        
        function processDebugAppReadyCallback(obj, appModel, line, column, scrollToView)
            % Callback to be executed once app has been loaded due to a
            % debug event and is ready to be used
            
            % Set the app to be debugging
            obj.setAppModelIsDebugging(appModel);
            
            % Request client to perform goToLineColumn
            appModel.CodeModel.sendGoToLineColumnEventToClient(line, column, scrollToView);
            
            % Process and flush DebugEventQueue
            %
            % Use a local copy of the queue and clear out the instance's
            % queue. This is necessary because one of the queued
            % events might cause another app to load which could then
            % potentially cause events to queue again and execute this
            % function again.
            %
            % Ex: App1's startup function instantiates App2 and each app
            % has breakpoint in each constructor. From command line, user
            % instantiates App1 and execution hits breakpoint. While App1
            % is loading, user executes dbcont which causes the breakpoint
            % in App2 to be hit. The user then hit dbcont again before App1
            % has finished loading. These two dbcont events are queued and
            % aren't processed until App1 finishes loading. When the first
            % dbcont event is processed it needs to load App2 and so the
            % second dbcont event will be queued again to wait until App2
            % has finished loading. Need a local copy of the queue to 
            % handle this properly.
            localQueue = obj.DebugEventQueue;
            obj.DebugEventQueue = {};
            for i=1:length(localQueue)
                obj.processDebugInfo(localQueue{i}{:});
            end
        end
        
        function setAppModelIsDebugging(~, appModel)
            % Set the app to be debugging
            appModel.IsDebugging = true;
            
            % Attach LiveAlert listener if the running app
            % from MATLAB triggers debugging
            appModel.addErrorAlertListener();
        end
        
        % Get the running app figure using its full file name
        function appFig = findAppFigure(~, fullFileName)
            appFig = [];
            
            runningAppFigures = findall(0, 'Type', 'figure',...
                '-property', 'RunningAppInstance');
            
            for i=1:length(runningAppFigures)
                fig = runningAppFigures(i);
                appMeta = metaclass(fig.RunningAppInstance);
                whichResult = which('-all', appMeta.Name);
                
                if any(cellfun(@(x) strcmp(x,fullFileName), whichResult))
                    appFig = fig;
                end
            end
        end
    end
    
end

