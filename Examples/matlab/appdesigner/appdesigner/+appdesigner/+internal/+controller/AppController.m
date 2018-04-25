classdef AppController < ...
        appdesservices.internal.interfaces.controller.AbstractController & ...
        appdesservices.internal.interfaces.controller.AppDesignerParentingController & ...
        appdesigner.internal.appalert.AppAlertController
    
    % AppController is the controller for an App.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Constant)
        CURRENT  = 'CURRENT';
    end
    
    methods
        function obj = AppController(varargin)
            obj = obj@appdesservices.internal.interfaces.controller.AbstractController(varargin{:});
            
            % construct the DesignTimeParentingController with the factory to
            % create model child objects
            factory = appdesigner.internal.model.AppChildModelFactory;
            obj = obj@appdesservices.internal.interfaces.controller.AppDesignerParentingController(factory);
        end
        
        function proxyView = createProxyView(~, ~)
            % PROXYVIEW = CREATEPROXYVIEW(OBJ, PVPAIRS) This method is abstract
            % in the base class and creates the ProxyView class.
            
            % AppController is a DesignTimeParentingController so the proxyView
            % for it is constructed in the DesignTimeParentingController and
            % passed into this class via the model.  Need to overload
            % becuase it is abstract
        end
    end
    
    methods(Access = 'protected')
        
        function propertyNames = getAdditionalPropertyNamesForView(~)
            % Additional properties needed by the App Controller
            propertyNames = {'Name', 'FullFileName', 'IsLaunching', 'IsDebugging', 'Metadata', 'ScreenshotPath'};
        end
        
        function pvPairsForView = getPropertiesForView(~, ~)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAMES) gets the properties that
            % will be needed by the view when properties change.
            %
            % Inputs:
            %
            %  propertyNames - a cell array of strings containing the names
            %                  of the property names
            
            % Right now, there are no App-related properties that need
            % specific conversion
            pvPairsForView = {};
        end
        
        function handleEvent(obj, ~, event)
            % HANDLEEVENT(OBJ, SOURCE, EVENT) This method receives event from
            % ProxyView class each time a user interacts with the visual
            % representation through mouse or keyboard. The controller sets
            % appropriate properties of the model each time it receives
            % these events.
            %
            % Inputs:
            %
            %   source  - object generating event, i.e ProxyView class object.
            %
            %   event   - the event data that is sent from the ProxyView. The
            %             data is translated to property value of the model.
            
            % right now, there are no App related events
            
            
            switch ( event.Data.Name )
                
                case 'AppModelClosed'
                    % when an App is closed at the client, the client sends this event
                    % so the server-side MCOS figure  object
                    % can be deleted immediately.
                    delete(obj.Model.CodeModel);
                    delete(obj.Model.UIFigure);
                    
                case 'saveApp'
                    obj.handleSaveApp(event);
                    
                case 'copyApp'
                    obj.handleCopyApp(event);
                    
                case 'runApp'
                    obj.handleRunApp(event);
                    
                case 'openPackageApp'
                    fullFileName = event.Data.FullFileName;
                    callbackId = event.Data.CallbackId;
                    obj.handleOpenPackageApp(fullFileName, callbackId);
                    
                case 'ping'
                    obj.handlePing(event);
            end
            
        end
        
        function handlePing(obj, event)
            % HANDLEPING(obj, event) send result back to the client
            
            % Send response to client side of the result
            obj.ProxyView.sendEventToClient('pingResult', { ...
                'CallbackId', event.Data.CallbackId, ...
                });
        end
        
        function handleSaveApp(obj, event)
            % HANDLESAVEAPP(obj, event) save app and send result back to
            % the client
            
            % Initialize the status output
            status = 'success';
            message = '';
            currentFullFileName = obj.Model.FullFileName;
            destinationFullFileName = event.Data.FullFileName;
            try
                if ~strcmp(currentFullFileName, destinationFullFileName) &&...
                   ~isempty(currentFullFileName)
                    % Performing SaveAs because filenames are different
                    
                    % Copy the app file and then perform the save on top of
                    % the copied file to preserve state of the app that is
                    % not in memory such as the app's screenshot
                    % (g1650481).
                    copyAppFile(obj.Model, destinationFullFileName)
                end
   
                save(obj.Model, destinationFullFileName);
                
                % get the FullFileName assigned to App after saving
                destinationFullFileName = obj.Model.FullFileName;
            catch me
                % Return the Status and Message to be used in the error
                % dialog
                status = 'error';
                message = me.message;
            end
            
            % Send response to client side of the result
            obj.ProxyView.sendEventToClient('saveAppResult', {
                'Status', status, ...
                'FullFileName', destinationFullFileName, ...
                'CallbackId', event.Data.CallbackId, ...
                'Message', message});
        end
        
        function handleCopyApp(obj, event)
            % HANDLECOPYAPP(obj, event) create a copy of the app and send result back to
            % the client
            
            % Initialize the status output
            status = 'success';
            message = '';
            copyToFullFileName = event.Data.CopyFullFileName;
            destinationRelease = event.Data.DestinationRelease;
            updatedCode = event.Data.UpdatedCode;

            try
                if ~isempty(obj.Model.FullFileName)
                    % Copy the app file and then perform the save on
                    % top of the copied file to preserve state of the
                    % app that is not in memory such as the app's
                    % screenshot (g1650481).
                    copyAppFile(obj.Model, copyToFullFileName);
                end
                
                if strcmp(destinationRelease, appdesigner.internal.controller.AppController.CURRENT)
                    copy(obj.Model, copyToFullFileName, updatedCode);
                else
                    copyToMLAPPVersion1(obj.Model, copyToFullFileName, destinationRelease, updatedCode);
                end
                
            catch me
                % Return the Status and Message to be used in the error
                % dialog
                status = 'error';
                message = me.message;
            end
            
            obj.ProxyView.sendEventToClient('copyAppResult', {
                'Status', status, ...
                'CopyFullFileName', copyToFullFileName, ...
                'CallbackId', event.Data.CallbackId, ...
                'Message', message});            
        end
        
        function handleRunApp(obj, event)
            % HANDLERUNAPP(obj, event) run app and send result back to
            % the client
            
            fullFileName = event.Data.FullFileName;
            
            % Check if the client request to change the current working
            % folder before running the app. It happens when there's a name
            % shadowing from the MATLAB's current workding directory to the
            % app to run, and then the user chooses "Change Folder" to run
            % again.
            if isfield(event.Data, 'Action') && ...
                    strcmp(event.Data.Action, 'CHANGE_FOLDER')
                fileFolder = fileparts(fullFileName);
                cd(fileFolder);
            end
            
            appArguments = '';
            if isfield(event.Data, 'AppArgumentValues')
                appArguments = event.Data.AppArgumentValues;
            end
            
            try
                runApp(obj.Model, fullFileName, appArguments);
            catch me
                status = 'error';
                reason = me.identifier;
                message = me.message;
                % Becuase of 1)name shadowing, App Designer can't pick the
                % correct app to run,
                % 2) saving failure, and so send response to client side
                % of the result
                obj.ProxyView.sendEventToClient('runAppResult', {
                    'Status', status, ...
                    'Reason', reason, ...
                    'FullFileName', fullFileName, ...
                    'CallbackId', event.Data.CallbackId, ...
                    'Message', message});
            end
        end
        
        function handleOpenPackageApp(obj, fullFileName, callbackId)
            % HANDLEOPENPACKAGEAPP(obj, fullFileName, callbackId) package
            % app and send result back to the client
            
            % Initialize the status output
            status = 'success';
            errorMessage = '';            
            try
                % package the AppModel for the app saved in fullFileName
                openPackageApp(obj.Model, fullFileName);
            catch me
                % Return the Status, Message and MessageTitle to be used in
                % the error dialog. The MessageTitle is used for the title
                % of the dialog window.
                status = 'error';
                errorMessage = me.message;               
            end
            
            % Send response to client side of the result
            obj.ProxyView.sendEventToClient('openPackageAppResult', {
                'Status', status, ...
                'FullFileName', fullFileName, ...
                'CallbackId', callbackId, ...
                'Message', errorMessage});
        end
        
        function doSendErrorAlertToClient(obj, appException)
            % DOSENDERRORALERTTOCLIENT(obj, appException) sends app
            % startup/run-time error information to the client.
            %
            % Inputs:
            %
            % appException - a decorated MException with a truncated stack
            
            message = appException.getReport('extended', 'hyperlinks','off');
            line = appException.ErrorLineInApp;
            obj.ProxyView.sendEventToClient('runningAppCallbackError',...
                {'line', line, 'message', message, 'type', class(appException)});
        end
    end
end
