classdef DialogHandlerService < handle    
   % Copyright 2017 The MathWorks, Inc.
   
   % DIALOGHANDLERSERVICE class is a generic service that displays a CEF
   % Window by instantiating the CEFHandler or signals the Client side
   % handler to display an Iframe from an IframeHandler depending on
   % whether we are in MATLAB Online or not.
   
    properties (Constant)
        messageChannel = '/datatoolsservices/DialogHandler'
    end
    
    properties
        dialogList
        dialogGroupMap % Hash containing all dialogs that belong to a group.
    end
    
    methods (Access='protected')
        % Constructor calls into show that displays the apporpriate window
        % depending on the environment.
        function this = DialogHandlerService(cefDialogHandler, IframeDialogHandler, varargin)
            this.dialogList = containers.Map;
            this.dialogGroupMap = containers.Map;
            this.show(cefDialogHandler, IframeDialogHandler, varargin{1})
        end
        
        % Show method Instantiates the cefDialogHandler if in desktop or
        % signals client to instantiate the IframeDialogHandler if in
        % MATLAB Online. In case of desktop, this method creates and displays a CEF window or
        % brings an existing CEF Window to the front. 
        function show(this, cefDialogHandler, IframeDialogHandler, varargin)
            % The number of arguments is less than 2, do nothing.
            if (nargin < 3)
                error(message('MATLAB:codetools:datatoolsservices:InsufficientArguments'));            
            elseif (nargin > 3)
                evalCmd = cefDialogHandler;
                args = varargin{1};                                
                if (~isempty(args) && (rem(length(args)-2,2)~=0))
                   error(message('MATLAB:codetools:datatoolsservices:PropertyValuePairsExpected'));
                end
                try
                    % Error check for even arguments.                    
                    if internal.matlab.datatoolsservices.DialogHandlerService.isMatlabOnline && ~isempty(IframeDialogHandler)                                
                         % MATLAB Online Workflow                            
                         channel = internal.matlab.datatoolsservices.DialogHandlerService.messageChannel;
                         messageArgs = this.getFormattedArgs(args);
                         messageArgs.dialogHandler = IframeDialogHandler;                         
                         message.publish(channel, messageArgs);
                    elseif ~isempty(cefDialogHandler)
                        % Desktop workflow
                        if ~isempty(args)                                                      
                            vals = cellfun(@(arg)['''' arg ''''], args, 'UniformOutput', false);                                                        
                            evalCmd = sprintf('%s(%s)', evalCmd, strjoin(vals,','));
                        end                        
                        % Desktop CEF Workflow                                                   
                        dialogHandler = eval(evalCmd);
                        if ~isempty(dialogHandler)
                            this.createCefDialog(dialogHandler);
                        end
                    end                
                catch exception
                    % If For some reason, Calling into the respective handlers
                    % errored out.
                    error(exception.message);
                end                    
            end 
        end                    
        
        % Creates CEF DialogWindow if createNewWindow of DialogHandler is
        % set to true or unset by default. Otherwise, Window already
        % exists and just brings this to the front.
        function createCefDialog (this, dialogHandler)
            if ((dialogHandler.createNewWindow || ~isprop(dialogHandler,'createNewWindow')) && isprop(dialogHandler, 'url'))                
                remotePort = matlab.internal.getOpenPort();
                browser = matlab.internal.webwindow(dialogHandler.url, remotePort);
                if (isprop(dialogHandler,'size')) && ~isempty(dialogHandler.size)
                    cefWidth = dialogHandler.size(1);
                    cefHeight = dialogHandler.size(2);
                    try
                        screenSize = get(0, 'ScreenSize');                                    
                        posWidth = (screenSize(3)/2)-(cefWidth/2);
                        posHeight = (screenSize(4)/2)-(cefHeight/2);
                        browser.Position = [posWidth posHeight cefWidth cefHeight];
                    catch
                        browser.Position = [100 400 cefWidth cefHeight];
                    end
                end               
                if isprop(dialogHandler, 'title') && ~isempty(dialogHandler.title)
                    browser.Title = dialogHandler.title;
                end
                browser.CustomWindowClosingCallback = @(src,evt)this.closeCefWindow(src, dialogHandler);                
                this.focusCef(browser);                
                this.dialogList(dialogHandler.ID) = browser;            
                 % If the dialogHandler has a groupId, update the
                 % dialogGroupMap
                if isprop(dialogHandler, 'groupID') && ~isempty(dialogHandler.groupID)
                    this.updateDialogGroup(dialogHandler);
                end
            else
                % CEF Window already exists.
                browser = this.dialogList(dialogHandler.ID);
                this.focusCef(browser);                                
            end
        end
        
        % Updates the dialogGroupMap with the dialogHandler entry.
        % If the group map already contains the dialogHandler's groupID, then 
        % We just add the ID to a string array containing ID's. Else we add
        % a fresh entry in dialogGroupMap. 
        function updateDialogGroup(this, dialogHandler)
            if ~isKey(this.dialogGroupMap, dialogHandler.groupID)
                this.dialogGroupMap(dialogHandler.groupID) = [string(dialogHandler.ID)];
            else
                dialogGroup = this.dialogGroupMap(dialogHandler.groupID);
                dialogGroup(end+1) = string(dialogHandler.ID);    
                this.dialogGroupMap(dialogHandler.groupID) = dialogGroup;
            end
        end
        
        % For a given CEF Window, display and bringtoFront.
        function focusCef(~, browser)
            if ~(browser.isVisible)
                browser.show();
            end
            browser.bringToFront();
        end

        % Closes the CEFWindow and also calls the dialogHandler's close
        % method. Removes the Hashed ID from existing dialogList.
        function closeCefWindow(this, src, dialogHandler)
            if (nargin > 2)
                dialogHandler.close();  
                if (isKey(this.dialogList, dialogHandler.ID))
                    remove(this.dialogList, dialogHandler.ID);
                end
                % If the dialogHandler has a groupID, remove the
                % dialogHandler entry from the dialogGroupMap.
                if isprop(dialogHandler, 'groupID') && ~isempty(dialogHandler.groupID)
                    dialogGroup = this.dialogGroupMap(dialogHandler.groupID);
                    hasDialog = dialogGroup.contains(dialogHandler.ID);
                    if (any(hasDialog))
                        dialogGroup(hasDialog) = [];
                        this.dialogGroupMap(dialogHandler.groupID) = dialogGroup;
                    end
                end
            end            
            src.close();
        end            
    
        % Formats list of name-value pairs and returns a struct containing
        % names as fields and correspondig value pairs as struct values.
        function args = getFormattedArgs(~, values)
            args = struct;
            for i=1:2:length(values)
                args.(values{i}) = values{i+1};
            end
        end
    end
    
    
    methods(Static)
        % Returns true if we are in MATLAB Online and false otherwise.
        function isMatlabOnline = isMatlabOnline()
            isMatlabOnline = (matlab.internal.environment.context.isMATLABOnline ...
                        || matlab.ui.internal.desktop.isMOTW);                                
        end   
        
        % Get an instance of the Dialog Handler Service and creates a Dialog
        % This is a sigleton class and is instantiated only once.
        % If varargin is not passed, just return the existing
        % dialogHandlerInstance. (Used for cleaning up dialog groups)
        function obj = getInstance(cefDialogHandler, iframeDialoghandler, varargin)
            mlock;  % Keep persistent variables until MATLAB exits
            persistent dialogHandlerInstance;
            if nargin > 1
                if isempty(dialogHandlerInstance) || ~isvalid(dialogHandlerInstance)
                    % Create a new Dialog Handler Service
                    dialogHandlerInstance = internal.matlab.datatoolsservices.DialogHandlerService(cefDialogHandler, iframeDialoghandler, varargin);
                else
                    dialogHandlerInstance.show(cefDialogHandler, iframeDialoghandler, varargin);
                end 
            end
            obj = dialogHandlerInstance;
        end
              
        % This function is used to close all dialogs that belong to a
        % particular dialog group. Fetch all the dialogs that belong to a
        % dialogGroup using groupID and call closeCefWindow on the dialog. 
        function closeAllDialogs(groupID)            
            this = internal.matlab.datatoolsservices.DialogHandlerService.getInstance;
            if ~isempty(this) && isKey(this.dialogGroupMap, groupID)
                dialogIDs = this.dialogGroupMap(groupID);
                for i=1:length(dialogIDs)
                    dialogID = char(dialogIDs(i));
                    if isKey(this.dialogList, dialogID)
                        this.closeCefWindow(this.dialogList(dialogID));
                        remove(this.dialogList, dialogID);
                    end
                end
                remove(this.dialogGroupMap, groupID);
            end
        end
    end
end
            
        
