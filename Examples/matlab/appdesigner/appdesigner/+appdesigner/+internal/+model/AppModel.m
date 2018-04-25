classdef AppModel < ...
        appdesigner.internal.model.AbstractAppDesignerModel & ...
        appdesservices.internal.interfaces.model.ParentingModel
    
    % The "Model" class of the App
    %
    % This class is responsible for managing the state of the App and
    % holding onto the App Figure Window.
    %
    %
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties
        % A handle to the figure, by default this is empty
        UIFigure = matlab.ui.Figure.empty();
        
        % Name of the AppModel, corresponds to the file name
        Name;
        
        % File location of the AppModel file
        FullFileName;
        
        CodeModel;
        
        % Current running app, if value is empty, there is no running App
        RunningApp;
        
        % When App is in the process of launching, IsLaunching will be true
        % This is true from when the user initates the run to when the
        % UIFigure frame appears
        IsLaunching
        
        % App's debugging state. It will be true if the App's full filename
        % is found anywhere in the debug call stack.
        IsDebugging = false;

        % Struct containing metadata for the app (Name, Summary,
        % Description, and ScreenshotMode) 
        Metadata;

        % Fullfile path to screenshot image. This property only
        % has a value when the user manually chooses an app screenshot on
        % the client and then needs to be saved into the MLAPP file. Once
        % it is saved, this property is set empty again because we don't
        % need to save it on every save. The screenshot is retrieved from
        % file only on demand and not every time an app is loaded.     
        ScreenshotPath;
    end
    
    properties(Access = 'private')
        % appdesigner.internal.model.AppDesignerModel
        %
        % This AppDesignerModel is the owner of this AppModel
        %
        % This property is analogous to 'Parent'
        AppDesignerModel;
        
        % Store the running app's UIFigure CodeName. If the user changes 
        % the UIFigure CodeName while the app is running, we will close
        % the running app when the user saves the app since the MCOS object
        % of the UIFigure is no longer valid
        RunningUIFigureCodeName;
        
        % Store the listener to running app's BeingDestroyed event
        RunningAppBeingDestroyedListener;
        
        % Loaded component data for the app
        CodeNameComponentMap;
		
		% Inspector Workspace
		InspectorWorkspace@appdesigner.internal.application.InspectorWorkspace;
    end
    
    methods
        function obj = AppModel(appDesignerModel, proxyView, uiFigure)
            % Constructor for AppModel
            %
            % Inputs:
            %
            %   appDesignerModel - The appdesigner.internal.model.AppDesignerModel
            %                      that will edit this App Model
            
            % Error Checking
            narginchk(2, 3);
            
            validateattributes(appDesignerModel, ...
                {'appdesigner.internal.model.AppDesignerModel'}, ...
                {});
            
            validateattributes(proxyView, ...
                {'appdesservices.internal.peermodel.PeerNodeProxyView'}, ...
                {});
            
            % Store the AppDesignerModel and ProxyView
            obj.AppDesignerModel = appDesignerModel;
            
            % set the model's name properties
            fullFileName = proxyView.getProperty('FullFileName');
            if ~isempty(fullFileName)
                obj.FullFileName = fullFileName;
                [~, obj.Name, ~] = fileparts(fullFileName);
            else
                obj.FullFileName = '';
                obj.Name = proxyView.getProperty('Name');
            end
            
            % Store loaded uifigure for later using during creating
            % component models
            % Do this before controller creation because it will call
            % processClientCreatedPeerNode() from
            % DesignTimeParentingController's processProxyView(), which
            % will try to create children objects
            if nargin == 3 && ~isempty(uiFigure)
                obj.storeLoadedUIFigure(uiFigure);
            end
            
            % create the controller
            obj.createController(obj.AppDesignerModel.Controller, proxyView);
            
            % add this model as a child
            obj.AppDesignerModel.addChild(obj);
        end
        
        function delete(obj)
            % Delete figure if deleting AppModel instance
            % directly from server side, which happens in test or
            % development workflow
            % In App Designer, it will be deleted through the
            % AppController
            if ~isempty(obj.UIFigure) && isvalid(obj.UIFigure)
                delete(obj.UIFigure);
            end
            
            if ~isempty(obj.RunningAppBeingDestroyedListener)
                delete(obj.RunningAppBeingDestroyedListener);
            end
        end
        
        function set.UIFigure(obj, newUIFigure)
            % Error Checking
            validateattributes(newUIFigure, ...
                {'matlab.ui.Figure'}, ...
                {});
            
            % Storage
            obj.UIFigure = newUIFigure;
            
            controller = obj.getController;
			
			% Create a workspace around the figure			
			%
			% Workspace's key will be made unique by using the App Model's
			% ID			
			workspaceKey = ['/appdesigner/inspectorworkspace/' controller.getId()];
			
			% Disabled due to g1467954
			obj.InspectorWorkspace = appdesigner.internal.application.InspectorWorkspace(newUIFigure, workspaceKey);
        end
        
        function set.CodeModel(obj, codeModel)
            
            validateattributes(codeModel, ...
                {'appdesigner.internal.codegeneration.model.CodeModel'}, ...
                {});
            
            % Storage
            obj.CodeModel = codeModel;
        end
        
        function set.Name(obj, newName)
            
            if ~isvarname(newName)
                error(message('MATLAB:appdesigner:appdesigner:FileNameFailsIsVarName', newName));
            else
                obj.Name = newName;
                markPropertiesDirty(obj, 'Name');
            end
        end
        
        function set.IsLaunching(obj, status)
            
            obj.IsLaunching = status;
            markPropertiesDirty(obj, 'IsLaunching');
        end
        
        function set.IsDebugging(obj, status)
            obj.IsDebugging = status;
            markPropertiesDirty(obj, 'IsDebugging');
        end
        
        function set.ScreenshotPath(obj, uri)
            obj.ScreenshotPath = uri;
            markPropertiesDirty(obj, 'ScreenshotPath');
        end

        function set.FullFileName(obj, newFileName)
            obj.FullFileName = newFileName;
            markPropertiesDirty(obj, 'FullFileName');
        end
        
        function adapterClassName = getAdapterClassName(obj, adapterType)
            % return the adapter class name for the given adapter type
            adapterMap = obj.AppDesignerModel.ComponentAdapterMap;
            if ( isKey(adapterMap,adapterType) )
                adapterClassName = adapterMap(adapterType);
            else
                % if  the adapter is not found then return []
                adapterClassName = [];
            end
        end
        
        function adapterMap = getAdapterMap(obj)
            % return the adapter map
            adapterMap = obj.AppDesignerModel.ComponentAdapterMap;
        end
        
        function save(obj, fileName)
            % SAVE - fileName is the full file name with path information
            % where the item is to be saved.
            
            if nargin == 1
                fileName = obj.FullFileName;
            end
            
            [~, appName] = fileparts(fileName);
            
            % If the app is running and either the UIFigure CodeName
            % changed or the current app code contains a parsing error,
            % close the running app.
            %
            % A parsing error will prevent the MCOS auto-update to occur
            % and so if the user tries to interact with the app such as
            % executing a callback, it will not work properly and no live
            % error alert will display because the app is broken (g1249971).
            % Closing the running app will prevent the user from
            % interacting with a broken app.
            if ~isempty(obj.RunningApp)
                uiFigureCodeName = obj.getUIFigureCodeName();
                
                % Determine if the code has a parsing error
                T = mtree(obj.CodeModel.GeneratedCode);
                
                if ~strcmp(uiFigureCodeName, obj.RunningUIFigureCodeName) || ...
                        (T.count == 1 && strcmp(T.kind(), 'ERR'))
                    
                    % Need to try/catch the delete of the running app in
                    % case there is a syntax error on a previous save that
                    % was not detected by mtree (see g1290751).
                    try
                        obj.RunningApp.delete();
                        obj.RunningApp = [];
                    catch exception
                        % Because the app can not be closed, report the
                        % error as a live error alert.
                        appController = obj.getController();
                        appController.sendErrorAlertToClient(exception, fileName);
                    end
                end
            end
            
            try
                % Let the codeModel update itself in response to a save
                % This is here to support the command line API
                obj.CodeModel.ClassName = appName;
                
                % Write the AppModel to the filename
                [fullFileName] = obj.writeAppToFile(fileName);
                
                % Update model because writeAppToFile returned no errors
                obj.Name = appName;                
                obj.FullFileName = fullFileName;
            catch me
                
                % Restore CodeModel state to the same as it was before the
                % save was attempted
                obj.CodeModel.ClassName = obj.Name;
                
                rethrow(me);
            end
        end    
        
        function copyToMLAPPVersion1(obj,destinationFilename,toMatlabRelease,updatedCode)
            % This function copies app data that is in memory to the old
            % format (MLAPP Version 1)
            
            % prepare data that is to be copied or converted to a previous release
            data = struct();
            data.UpdatedCode = updatedCode;
            data.Metadata = obj.Metadata;
            data.DestinationRelease = toMatlabRelease;
            
            % make a copy of the UIFigure to work with so the UIFigure is
            % not altered in any way for this app
            data.UIFigure = obj.copyUIFigure();
            
            % delete the copied uifigure on cleanup after "save copy as" is
            % done. The copied figure is no longer needed.
            cleanupObj = onCleanup(@()delete(data.UIFigure));
            
            % set the data to copy
            data.ScreenshotPath = obj.ScreenshotPath;
            data.StartupCallback = obj.CodeModel.StartupCallback;
            data.EditableSectionCode = obj.CodeModel.EditableSectionCode;
            data.InputParameters = obj.CodeModel.InputParameters;
            data.Callbacks = obj.CodeModel.Callbacks;
            data.Groups = obj.getGroupHierarchy();
            
            % Deliberately break up conversion so we can differentiate
            % which release the conversion is being called for
            % DO NOT CONSOLIDATE
            switch toMatlabRelease
               case 'R2017b'
                  appdesigner.internal.model.create17bAppCopy(destinationFilename,data);
               case 'R2017a'
                  appdesigner.internal.model.create17aAppCopy(destinationFilename,data);
               case 'R2016b'
                  appdesigner.internal.model.create16bAppCopy(destinationFilename,data);
            end           
        end
        
        function copy(obj, toFileName,updatedCode)
            % COPY - toFileName is the full file name with path information
            % where the app is to be saved.
            
            % make a copy of the UIFigure
            copiedUIFigure = obj.copyUIFigure();
            
            % delete the copied uifigure on cleanup after "save copy as" is
            % done. The copied figure is no longer needed.
            cleanupObj = onCleanup(@()delete(copiedUIFigure));
            
            % create the serializer
            serializer = appdesigner.internal.serialization.MLAPPSerializer(toFileName,copiedUIFigure);
            
            % set data on the Serializer to be serialized
            obj.setDataOnSerializer(serializer);
            
            % overwrite the matlabCodeText becuase its a new class name
            serializer.MatlabCodeText = updatedCode;

            % create the copy of the app
            appdesigner.internal.model.createAppCopy(serializer);
        end
        
        function [fullFileName] = writeAppToFile(obj, fileName)
            % WRITEAPPTOFILE - Validate inputs and write App to file
            [path, name, ext] = fileparts(fileName);
            
            
            if ~isvarname(name)
                error(message('MATLAB:appdesigner:appdesigner:FileNameFailsIsVarName', name));
            end
            
            if isempty(path)
                % The case of saving to the current directory
                path = cd;
            end
            
            % Check if directory exists
            [success, dirAttrib] = fileattrib(path);
            
            % Directory should exist
            if ~success
                error(message('MATLAB:appdesigner:appdesigner:NotWritableLocation', fileName))
            end
            
            % Reassemble fullFileName in case the path has changed.
            fullFileName = fullfile(path, [name, ext]);
            if dirAttrib.directory && (numel(path) < numel(dirAttrib.Name))
                % if path was a relative path, path will not be the same as
                % the Name as returned by FILEATTRIB
                fullFileName = fullfile(dirAttrib.Name, [name, ext]);
            end
                       
            % create the serializer
            serializer = appdesigner.internal.serialization.MLAPPSerializer(fullFileName,obj.UIFigure);
            
            % set data on the Serializer
            obj.setDataOnSerializer(serializer);
            
            % save the app data
            serializer.save();
            
            % Reset the ScreenshotPath to empty because we don't need to save
            % the screenshot on every save, just when it is changed
            % by the user.
            if ( ~isempty(obj.ScreenshotPath()))
                obj.ScreenshotPath = '';
            end
                       
            % Only re-sync the breakpoints when performing a save (the
            % current filename is the same as the target filename). On a
            % Save As, it is not necessary to re-sync the breakpoints and
            % it can cause breakpoints not to be cleared when the Save As
            % is used to overwrite an existing app (g1078401).
            if strcmp(obj.FullFileName, fullFileName)
                try
                    % This try-catch is necessary because it is only required
                    % if the client is up and running and the breakpoint
                    % services are running.
                    % Re-sync breakpoints upon save of file
                    bpms = com.mathworks.mde.editor.plugins.matlab.MatlabBreakpointMessageService.getInstance();
                    bpms.synchronizeBreakpoints(java.io.File(fullFileName))
                catch
                end
            end
            % Clear the class
            clear(name);
        end
        
        function setDataOnSerializer(obj,serializer)
            % Sets the data on the serializer to be serialized
            serializer.MatlabCodeText =  obj.CodeModel.GeneratedCode;
            serializer.Groups = obj.getGroupHierarchy();
            serializer.Metadata  = obj.Metadata;
            serializer.EditableSectionCode = obj.CodeModel.EditableSectionCode;
            serializer.Callbacks = obj.CodeModel.Callbacks;
            serializer.StartupCallback = obj.CodeModel.StartupCallback;
            serializer.ScreenshotPath = obj.ScreenshotPath;
            serializer.InputParameters = obj.CodeModel.InputParameters;
        end
        
       function copiedUIfigure = copyUIFigure(obj)
           tempFileLocation = [tempname, '.mat'];
           
           % The temporary file will need to be deleted after reading
           c = onCleanup(@()delete(tempFileLocation));
           figureToCopy = obj.UIFigure;
           
           % Disable save warning and capture current lastwarn state
           previousWarning = warning('off','MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality');
           
           % Suppress the SizeChangedFcnDisabledWhenAutoResizeOn warning
           % during load. The warning will be thrown if the loaded
           % container has AutoResizeChildren set to 'on' and SizeChanged
           % set to a non-empty value.
           previousWarning(end+1) = warning('off', 'MATLAB:ui:containers:SizeChangedFcnDisabledWhenAutoResizeOn');
           [lastWarnStr, lastWarnId] = lastwarn;
           
           save(tempFileLocation,'figureToCopy');
           
           % apply the figures default system to all the components
           cleanupObj = appdesigner.internal.serialization.util.listenAndConfigureUIFigure();
           
           loadedData = load(tempFileLocation);
           copiedUIfigure = loadedData.figureToCopy;
           
           % Restore previous warning state
           warning(previousWarning);
           lastwarn(lastWarnStr, lastWarnId);
       end
        
        function copyAppFile(obj, copyToFullFileName)
            % COPYAPPFILE - Creates a copy of the serialized app file. 
            % 
            % Note that this does NOT update the class name in the code for
            % the new file to match the copy to filename. It performs a
            % naive, straight copy. Also, the copy will be writable even if
            % the original is not so that a save can be performed on top of
            % the copy.
            
            fileWriter = appdesigner.internal.serialization.FileWriter(copyToFullFileName);
            fileWriter.copyAppFromFile(obj.FullFileName);
        end
               
        function runApp(obj, fullFileName, appArguments)
                   
            % Run the App as if by command line
            [~, appName, appExt] = fileparts(fullFileName);
            
            % Silently save the app if it no longer exists because the user
            % deleted or renamed it using the file system prior to running
            % the app from App Designer.            
            if exist(fullFileName, 'file') ~= 2
                try
                    save(obj, fullFileName);
                catch
                    % Saved failed
                    exception = MException(...
                        message('MATLAB:appdesigner:appdesigner:RunFailedFileNotFound', [appName appExt], fullFileName));
                    throw(exception);
                end
            end
            
            if appdesigner.internal.apprun.isSameNameAppRunning(fullFileName, obj.RunningApp)
                % First check if there's a same name app from different 
                % folder already running
                exception = MException(...
                        message('MATLAB:appdesigner:appdesigner:SameNameAppRunning', appName));
                throw(exception);
            elseif appdesigner.internal.apprun.isAppNameShadowedByCWD(fullFileName)
                % Check if there's a name shadowing from the MATLAB's 
                % current folder
                exception = MException(...
                        message('MATLAB:appdesigner:appdesigner:AppNameShadowedByCWD', which(appName)));
                throw(exception);
            end            
            
            funcHandle = @()appdesigner.internal.model.AppModel.runAppHelper(obj, appArguments);
            
            % This is being used to defer the eval call to MATLAB until
            % after the fevals produced by the synchronization effort have
            % been complete.  This bumps the eval that creates the App to
            % the bottom of the list.
            appdesigner.internal.serialization.defer(funcHandle);
        end
        
        function addErrorAlertListener(obj)
            appController = obj.getController();
            appController.addErrorAlertListener(obj);
        end
                
        function component = popComponent(obj, codeName)
            component = [];
            
            if ~isempty(obj.CodeNameComponentMap) && ...
                    obj.CodeNameComponentMap.isKey(codeName)
                component = obj.CodeNameComponentMap(codeName);
                
                % After retrieving the component, remove it from the map
                % because it has been created successfully when loading the
                % app
                obj.CodeNameComponentMap.remove(codeName);
            end
            
        end
        
        function openPackageApp(obj, fullFileName)
            
            % Launch the Package App dialog for the specified .mlapp file.
            
            % Search for .prj project files in the same directory, and which
            % specify the .mlapp file as the Main File. If multiple such
            % .prj files are found, use the most recently modified. Launch
            % the Package App dialog with the most recent matching .prj file.
            % If no matching .prj file is found, open a new Package App
            % dialog, with some fields pre-populated from the .mlapp.
            
            [filePath, fileName] = fileparts(fullFileName);
            
             fileReader = appdesigner.internal.serialization.FileReader(fullFileName);
             appMetaData = fileReader.readAppMetadata();
             imgFullFilePath = fileReader.readAppScreenshot('file');

            aps = com.mathworks.toolbox.apps.services.AppsPackagingService;
            
            mostRecentPrjFullFileName = appdesigner.internal.application.getMostRecentPackageProject(fullFileName, aps);
            
            if ~isempty(mostRecentPrjFullFileName)
                try
                    matlab.apputil.create(mostRecentPrjFullFileName); % does not do dependency checking
                catch ex
                    % Note: if .prj is in a read-only directory, user will
                    % not get an error message until an edit is made to any
                    % field in the Package App dialog. The error message
                    % will be generated by the Package App dialog.
                    if strcmp(ex.identifier, 'MATLAB:apputil:create:filenotfound')
                        error(message('MATLAB:appdesigner:appdesigner:PackageAppPackageFileNotFound', fullFileName));
                    else
                        % Unknown error using packaging API -> return generic PackageError
                        error(message('MATLAB:appdesigner:appdesigner:PackageAppFailed', fullFileName));
                    end
                end
            else
                % No .prj file found for this .mlapp file
                
                prjFilename = appMetaData.Name;
                
                prjFilename = appdesigner.internal.application.getFilteredAppName(prjFilename);
                
                % Set the .prj filename to be the same as the app's
                % filename if the filtered app name is empty
                if isempty(prjFilename)
                    prjFilename = fileName;
                end

                originalPrjFileName = prjFilename;
                foundUniquePrjName = false;
                uniqueCounter = 0;
                while ~foundUniquePrjName
                    try
                        % .createAppsProject throws exception if filename conflict encountered
                        key = aps.createAppsProject(filePath, prjFilename);
                        
                        % The packaging API will strip illegal characters out of .prj
                        % filename, so API must be queried to determine what was used.
                        actualPrjFullFileName = aps.getProjectFileLocation(key);
                        foundUniquePrjName = true;
                    catch ex
                        if (strcmp(ex.identifier,'MATLAB:Java:GenericException') && ...
                                isa(ex.ExceptionObject, 'com.mathworks.deployment.services.NameCollisionException'))
                            % Name conflict with another .prj file. Append '_<int>' to name.
                            % Loop until a unique filename is found (e.g. App1_3.prj').
                            uniqueCounter = uniqueCounter + 1;
                            prjFilename = [originalPrjFileName '_' num2str(uniqueCounter)];
                        elseif (strcmp(ex.identifier,'MATLAB:Java:GenericException') && ...
                                isa(ex.ExceptionObject, 'java.io.FileNotFoundException'))
                            error(message('MATLAB:appdesigner:appdesigner:PackageAppPackageFileNotFound', fullFileName));
                        elseif (strcmp(ex.identifier,'MATLAB:Java:GenericException') && ...
                                isa(ex.ExceptionObject, 'com.mathworks.deployment.services.ReadOnlyException'))
                            error(message('MATLAB:appdesigner:appdesigner:PackageAppFolderNotWritable', fullFileName));
                        else
                            % Unknown error using packaging API
                            error(message('MATLAB:appdesigner:appdesigner:PackageAppFailed', fullFileName));
                        end
                    end
                end
                
                % Save the .mlappinstall to the same directory as the .mlapp file.
                aps.setOutputFolder(key, filePath);
                
                
                % Specify the .mlapp as the main file
                aps.addMainFile(key, fullFileName);
                aps.setSummary(key, appMetaData.Summary);
                aps.setDescription(key, appMetaData.Description);
                if ~isempty(imgFullFilePath)
                    aps.setSplashScreen(key, imgFullFilePath);
                end
                aps.closeProject(key);
                aps.openProjectInGUIandRunAnalysis(actualPrjFullFileName); % open dialog (starts dependency checking)
            end
        end
    end
    
    methods (Access = private)
        function uiFigureCodeName = getUIFigureCodeName(obj)
            uiFigureCodeName = obj.UIFigure.DesignTimeProperties.CodeName;
        end               
        
        function onCleanupRunningAppReference(obj)
            % Listen to the running app being destroyed, then clear the 
            % reference to the running app instance from AppModel, 
            % otherwise there would be a timing issue during updating 
            % the app's breakpoints information since the reference
            % to a deleted instance exists. See g1604996            
            function cleanRunningAppReference(appModel)
                appModel.RunningApp = [];
            end
            obj.RunningAppBeingDestroyedListener = ...
                addlistener(obj.RunningApp, 'ObjectBeingDestroyed', @(src, e)cleanRunningAppReference(obj));
        end
        
        function mostRecentPrjFullFileName = getMostRecentPackageProject(obj, mlappFullFileName)
            % Find most recent .prj file in the same directory as the .mlapp file,
            % which has the Main File field set to the specified mlapp file.
            
            [filePath, mlappFile, ext] = fileparts(mlappFullFileName);
            
            % Find all .prj files in the same directory as the .mlapp file
            % Returns struct array with name and datenum (double) fields
            
            prjFiles = dir(fullfile(filePath, '*.prj'));
            
            aps = com.mathworks.toolbox.apps.services.AppsPackagingService;
            
            mostRecentPrjFullFileName = [];
            mostRecentPrjFileDatenum = 0;
            for file = prjFiles'
                if file.isdir
                    continue;
                end
                try
                    prjFullFileName = fullfile(filePath, file.name);
                    if aps.doesProjectContainMainFile(prjFullFileName, mlappFullFileName)
                        if file.datenum > mostRecentPrjFileDatenum
                            mostRecentPrjFullFileName = fullfile(filePath, file.name);
                            mostRecentPrjFileDatenum = file.datenum;
                        end
                    end
                catch ex
                    % Unknown error using packaging API -> return generic PackageError
                    error(message('MATLAB:appdesigner:appdesigner:PackageAppFailed', mlappFullFileName));
                end
            end
        end
    end
    
    methods (Static)
        
        function runAppHelper(currentAppModel, appArguments)
            
            appFullFileName = currentAppModel.FullFileName;
            
            % Guarentee IsLaunching is set to false and restoring current
            % folder
            isLaunchingCleanup = onCleanup(@()set(currentAppModel, 'IsLaunching', false));
            
            % Delete existing instance of the current app.
            % This IF statement has been moved from the runApp method to
            % this defered method to resolve an issue with the Run button
            % being disabled when the code has a syntax error and the
            % RunningApp instance is deleted (see g1098581).
            if(~isempty(currentAppModel.RunningApp))
                try
                    % The deletion of the previously running app could
                    % throw an exception if the running app's code was
                    % updated and fails when parsed.
                    % Destroying the last running app instance will trigger 
                    % listener in onCleanupRunningAppReference() to set
                    % RunningApp to empty
                    currentAppModel.RunningApp.delete();
                catch
                    % Allow the exception to pass through because it will
                    % also fail when we attempt to eval the app in the code
                    % below. Reporting the eval failure is more relevant
                    % and useful than reporting the delete failure.
                end
            end
            
            % Save the current UIFigure CodeName for next saving
            % to decide if needed to close the running app or not by
            % comparing the old and new CodeName
            currentAppModel.RunningUIFigureCodeName = currentAppModel.getUIFigureCodeName();
            
            % Listen for run time errors that occur in the running
            % app's callbacks
            currentAppModel.addErrorAlertListener();
            
            try
                % Store newly generated app in the obj.RunningApp. This
                % line could throw an exception if the app's code fails
                % in parsing or an error occurs in the app's constructor.
                ams = appdesigner.internal.service.AppManagementService.instance();
                currentAppModel.RunningApp = ...
                    ams.runDesktopApp(appFullFileName, appArguments);
            catch exception
                if isa(exception, 'appdesigner.internal.appalert.CallbackException')
                    % Exception in startup function from app's constructor,
                    % but app already created
                    currentAppModel.RunningApp = exception.App;
                end
                rethrow(exception);
            end
            
            % When the running app is closed, clear the reference to the
            % running app instance from AppModel
            currentAppModel.onCleanupRunningAppReference();
            
            % Auto-capture screenshot of running app unless the
            % screenshotMode is manual which means the user has specified
            % a custom screenshot image.
            screenshotMode = currentAppModel.Metadata.ScreenshotMode;
            if strcmp(screenshotMode, 'auto')
                % Make sure app is fully rendered and startup function has 
                % completed before capturing screenshot.
                drawnow;
                
                % Capture and serialize the app screenshot
                try
                    appFigure = appdesigner.internal.service.AppManagementService.getFigure(currentAppModel.RunningApp);
                    
                    appdesigner.internal.application.AppScreenshot.capture(...
                      appFigure, appFullFileName);
                catch
                    % Don't throw error if for some rare reason the capture
                    % fails as the cature should be unnoticed by the user.
                end
            end
        end
    end
    
    methods(Access = 'private')

         function groupHierarchy = getGroupHierarchy(obj)
            groupHierarchy = {};
            
            % This group meta data is neede on Save only
            % Get group manager peer node
            groupManager = [];
            peerNodeChildren = obj.Controller.ProxyView.PeerNode.getChildren();
            peerNodes = peerNodeChildren.toArray();
            for index = 1:numel(peerNodes)
                if strcmp('GroupsManager', char(peerNodes(index).getType()))
                    groupManager = peerNodes(index);
                    break;
                end
            end
            
            if ~isempty(groupManager)
                % There are groups in the app
                groupChildren = groupManager.getChildren();
                groups = groupChildren.toArray();
                
                for index = 1:numel(groups)
                    group = groups(index);
                    groupHierarchy{end+1} = struct('Id', char(group.getId()), ...
                        'ParentGroupId', char(group.getProperty('GroupId')));
                end
            end
         end      
        
        function storeLoadedUIFigure(obj, uiFigure)
            % Store the loaded uifigure
            
            % Flat all components to store as a map with CodeName as key
            % for quick retrieving when creating design time comopnent
            % models
            %childrenList = appdesigner.internal.application.getDescendants(uiFigure);
            childrenList = findall(uiFigure, '-property', 'DesignTimeProperties');
            % Loaded component data for the app
            obj.CodeNameComponentMap = containers.Map();
            
            for ix = 1:numel(childrenList)
                codeName = childrenList(ix).DesignTimeProperties.CodeName;
                obj.CodeNameComponentMap(codeName) = childrenList(ix);
            end
        end
    end
    
    methods(Access = 'public')
        
        function controller = createController(obj, parentController, proxyView)
            % Creates the controller for this Model
            controller = appdesigner.internal.controller.AppController(obj, parentController, proxyView);
        end
    end
    
end
