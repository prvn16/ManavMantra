classdef webwindow < handle
    %webwindow A webwindow using CEF (Chromium Embedded Framework)
    %component
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    % Suppressing dependent property mlint messages for this file.
    %#ok<*MCSUP>
    
    properties ( Access = public )
        
        % URL - A string specifying the URL of the web window.
        URL

        % Icon - A string specifying the icon path.
        Icon  
        
        % Position - A 4x1 array of [ x y width height ] specifying the
        % size and location of the window.
        Position
        
        % This callback is fired when the webwindow is attempted to be closed
        % by a user. If the CustomWindowClosingCallback is defined, the webwindow
        % will not be automatically closed and the responsibility of
        % actually closing the webwindow or not will be on the listener.
        CustomWindowClosingCallback
        
        % This callback is fired when the webwindow is resized by a user. 
        CustomWindowResizingCallback
        
        WindowResizing 
        
        WindowResized 
        
        FocusGained
        
        FocusLost
        
        % This callback is fired when a file is downloaded. 
        % The eventData is a structure with two string 
        % values "DownloadStatus" and "DownloadFilepath"
        % "DownloadStatus" will let user know the 
        % status i.e "downloadStarting/downloadFinished/downloadCancelled"
        % "DownloadFilepath" is the full file path of the downloaded file
        % including the file name
        DownloadCallback
        
        % This callback is fired when the url load is finished.
        PageLoadFinishedCallback
        
        % This callback is fired when MATLAB is closing. If a value is
        % specified, webwindow will veto MATLAB closing and then fire the
        % callback. It is up to the client to then decide if MATLAB exit
        % should continue and call exit if necessary
        MATLABClosingCallback
        
        % This callback is fired when the MATLABWindow process has exited
        % unexpectedly.
        MATLABWindowExitedCallback
        
        PopUpWindowCallback
        
        WindowStateCallback
        
    end
    
    properties (Access = public, Dependent=true)
        % Title - A string specifying the title of the launched window.
        Title
    end
    
    properties ( SetAccess = private, GetAccess = public, Transient )
        
        % RemoteDebuggingPort - A port that can be used for debugging. This
        % can be specified during construction, otherwise a default is
        % chosen.
        RemoteDebuggingPort = 0;
        
        % CEFVersion - Chromium Embedded Framework Version being used by
        % this webwindow.
        CEFVersion
        
        % ChromiumVersion - Chromium Version being used by this webwindow.
        ChromiumVersion
    end
    
    properties ( SetAccess = private, GetAccess = public )
        % Bool indicating if the window is valid.
        isWindowValid
        
        isDownloadingFile
        
        isModal
        
        isWindowActive
        
        isAlwaysOnTop
        
        isAllActive
        
        isResizable
        
        MaxSize
        
        MinSize
        
        windowType
        
        DownloadLocation
        
        Origin
        
        BrowserMode

    end

    methods
        function obj = webwindow( arg, varargin )
            % WEBWINDOW Create a web window that uses Chromium Embedded
            % Framework. Only the process is create. You need to call show
            % in order to make it visible.
            %
            % OBJ = WEBWINDOW(URL, REMOTEDEBUGGINGPORT)
            %
            % Inputs:
            % URL - The URL for the webwindow
            %
            % REMOTEDEBUGGINGPORT - This optional argument can be used to
            % specify the remote debugging port used when launching the
            % webwindow.
            % Setup the status flags.
            obj.isWindowValid = false;
            obj.windowType = 'Standard';
            obj.Origin = 'BottomLeft';
            obj.BrowserMode = 'ExternalProcess';
            
            windowMgr = matlab.internal.webwindowmanager.instance();

            % Get the default connector SSL certificate from the connector.
            certLoc = connector.getCertificateLocation;
            % If the certificate location returned is empty, it means the
            % connector is not running and hence the certificate should be
            % empty.
            if isempty(certLoc)
                cert = '';
            else
                % If the certificate location is not empty that means
                % connector is running and a valid self signed connector
                % certificate can be acquired.
                cert = char(fileread(certLoc));
            end
            
            % For popUpWindow Callback we send the WinID as arguments in
            % a struct.
            if isstruct(arg)
                windowURL = arg.URL;
                obj.WindowHandle = uint64(arg.WindowHandle);
                % For popUp Window pass the WinID to create a channel between
                % the MATLABWindow and MATLAB
                options.WinID = int32(arg.WinID);
            else
                % URL
                windowURL = arg;
               
                p = inputParser;
                
                if length(varargin) >= 1
                    % If second argument is numeric the arguments are non-PV pair
                    % get the debugPort
                    if nargin >= 2 && isnumeric(varargin{1})
                        narginchk(1, 4);
                        addOptional(p, 'DebugPort', 0 , ...
                                 @(x) validateattributes(x,{'numeric'}, ...
                                 {'size',[1 1]}));
                        % Check if there is Position     
                        if nargin >= 3 && isnumeric(varargin{2})
                            addOptional(p, 'Position', obj.InitialPosition, ...
                                @(x) validateattributes(x,{'numeric'}, ...
                                {'size',[1 4]}));
                        else
                            % Set default position
                            addOptional(p, 'Position', obj.InitialPosition);
                        end 
                        % Set default windowType as 'Standard'
                        addParameter(p,'WindowType','Standard');
                        
                        addParameter(p,'Origin','BottomLeft');
                        
                        addParameter(p,'BrowserMode','ExternalProcess');

                        addParameter(p,'Certificate',char(fileread(connector.getCertificateLocation)));
                    else              
                        % Parse the property value pair
                        addParameter(p,'Position',obj.InitialPosition, ...
                                @(x) validateattributes(x,{'numeric'}, ...
                                {'size',[1 4]}));
                        addParameter(p,'DebugPort',0, ...
                                 @(x) validateattributes(x,{'numeric'}, ...
                                 {'size',[1 1]}));
                        addParameter(p,'WindowType','Standard',@ischar);
                        
                        addParameter(p,'Origin','BottomLeft',@ischar);
                        
                        addParameter(p,'BrowserMode','ExternalProcess', @ischar);     
                   
                        addParameter(p,'Certificate',char(fileread(connector.getCertificateLocation)),@ischar);
                    end
                    p.parse(varargin{:});
                    obj.windowType = p.Results.WindowType;
                    obj.InitialPosition = p.Results.Position;
                    remoteDebuggingPort = p.Results.DebugPort;
                    obj.Origin = p.Results.Origin;
                    obj.BrowserMode = p.Results.BrowserMode;
                    
                    cert = p.Results.Certificate;
                end
            end
            
            validateattributes(windowURL,{'char'},{'nrows',1});
            
            % Apply connector nonce
            windowURL = connector.applyNonce(windowURL);
			
            if (nargin >= 2)
                % If browser is already running update the debug port value
                if windowMgr.isBrowserRunning(obj.BrowserMode)
                    obj.RemoteDebuggingPort = windowMgr.DebugPort('BrowserMode',obj.BrowserMode);
                else
                    if( remoteDebuggingPort > 0)
                        validateattributes(remoteDebuggingPort,{'numeric'}, ...
                            {'size',[1 1], '>=', 1024,'<=',65535});
                        % Before saving the remote debugging port, try to bind
                        % to the port, so that we can warn if it is in use.
                        try
                            ss = java.net.ServerSocket();
                            ss.setReuseAddress(true);
                            ss.bind(java.net.InetSocketAddress('localhost', remoteDebuggingPort));
                            ss.close();

                            % We were able to bind to the socket, so proceed
                            % with the remote debug port.
                            obj.RemoteDebuggingPort = int32(remoteDebuggingPort);
                            % Update the debugport in window manager
                            windowMgr.setDebugPort(obj.RemoteDebuggingPort);                            
                        catch err %#ok<NASGU>
                            warning(message('cefclient:webwindow:portInUse', remoteDebuggingPort));
                        end
                    end
                end
            end
            
            % Use matlabroot for the base plugin directory instead of toolboxdir.
            pluginDir = fullfile(matlabroot, 'bin', computer('arch'));
            
            % Initialize channel that is the source of events.
            obj.Channel = asyncio.Channel(fullfile(pluginDir, 'cefclientdevice'),...
                fullfile(pluginDir, 'cefclientmlconverter'),...
                [], [0 0]);
            
            % Register listener for timer execution.
            obj.CustomEventListener = addlistener(obj.Channel, 'Custom',...
                @(source,data) obj.onCustomEvent(data.Type,data.Data));
            
            obj.PropertyEventListener = addlistener(obj.Channel,'WindowState','PostSet',...
                @obj.onPropertyEvent);
            
            obj.newURL = windowURL;
            options.URL = obj.newURL;
            
            % Need to subtract 1 since we aren't calling setPosition yet.
            options.X = int32(obj.InitialPosition(1)) - 1;
            options.Y = int32(obj.InitialPosition(2)) - 1;
            options.Width = int32(obj.InitialPosition(3));
            options.Height = int32(obj.InitialPosition(4));
            
            options.Origin = obj.Origin;
            
            options.Certificate = char(cert);
            
            options.WindowType = obj.windowType;
            
            options.BrowserProcessMode = obj.BrowserMode;
            % Make sure to read the proxy before building startup options
            windowMgr.readProxyServer(obj.BrowserMode);
            if char(windowMgr.readProxyCredentials())
                options.ProxyAuthentication = char(windowMgr.readProxyCredentials());
            end
            
            % Append required options and default options
            startupOptions = [ windowMgr.requiredStartupOptions(obj.BrowserMode) ' ' ...
                               windowMgr.buildDefaultStartupOptions(obj.BrowserMode)
                              ];
            if char(startupOptions) 
                options.BrowserStartupOptions = char(startupOptions);
            end

            % Open channel.
            try
                obj.initialize();
                obj.Channel.WindowHandle = [];
                obj.Channel.open(options);
                if ~isempty(obj.Channel.WindowHandle)
                    obj.WindowHandle = obj.Channel.WindowHandle;
                end
            catch err
                obj.close();
                if strcmp(computer('arch'), 'glnxa64')
                    missingLibraries = matlab.internal.webwindow.findMissingLibraries();
                    if isempty(missingLibraries)
                        error(message('cefclient:webwindow:launchProcessFailed',err.message));
                    else
                        error(message('cefclient:webwindow:launcProcessMissingLibraries',sprintf('\t%s\n', missingLibraries)));
                    end
                        
                end
                error(message('cefclient:webwindow:launchProcessFailed',err.message));
            end
            
        end
        

        function show(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow();
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('show');
            
            % Delegate command to channel
            obj.Channel.execute('show');
            
        end
        
        function hide(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('hide');
            
            % Delegate command to channel
            obj.Channel.execute('hide');
        end
        
        function setResizable(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setResizable');
            
            newValue = logical(newValue);
            
            if strcmp(obj.windowType,'Standard') || strcmp(obj.windowType,'FixedSize')
                % Send command to channel
                options.isResizable = newValue;            
                obj.Channel.execute('SetResizable',options); 

                obj.isResizable = newValue;
            else
                error(message('cefclient:webwindow:UnsupportedOpForWindowType'));
            end            

        end     
        
        function setDownloadLocation(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setDownloadLocation');
            
            % Send command to channel
            options.DownloadLocation = newValue;            
            obj.Channel.execute('SetDownloadLocation',options); 

        end         
        
        function setMinSize(obj,Size)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setMinSize');
            
            validateattributes(Size,{'numeric'},{'nonnegative','size',[1 2]});
            if obj.MaxSize
                if obj.MaxSize(1) < Size(1) || obj.MaxSize(2) < Size(2)
                    error(message('cefclient:webwindow:invalidMinSize'));
                end
            end
            
            updatePosition = false;
            newPosition = obj.Position;
            if (obj.Position(3) < Size(1))
                newPosition(3) = Size(1);
                updatePosition = true;
            end
            
            if (obj.Position(4) < Size(2))
                newPosition(4) = Size(2);
                updatePosition = true;
            end
            
            if updatePosition
                obj.Position = newPosition;
                warning(message('cefclient:webwindow:updatePositionMinSize'));
            end
            
            options.MinWidth = int32(Size(1));
            options.MinHeight = int32(Size(2));
            
            obj.MinSize = Size;
            
            % Send command to channel
            obj.Channel.execute('SetMinSize',options);  
            
        end        
        
        function setMaxSize(obj,Size)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setMaxSize');
            
            validateattributes(Size,{'numeric'},{'nonnegative','size',[1 2]}); 

            if obj.MinSize
                if obj.MinSize(1) > Size(1) || obj.MinSize(2) > Size(2)
                    error(message('cefclient:webwindow:invalidMaxSize'));
                end
            end                        
            
            updatePosition = false;
            newPosition = obj.Position;
            if (obj.Position(3) > Size(1))
                newPosition(3) = Size(1);
                updatePosition = true;
            end
            
            if (obj.Position(4) > Size(2))
                newPosition(4) = Size(2);
                updatePosition = true;
            end
            
            if updatePosition
                obj.Position = newPosition;
                warning(message('cefclient:webwindow:updatePositionMaxSize'));
            end
            
            options.MaxWidth=int32(Size(1));
            options.MaxHeight=int32(Size(2));
            
            obj.MaxSize = Size;
            
            % Send command to channel
            obj.Channel.execute('SetMaxSize',options);            
        end        
        
        function minimize(obj)
			% Error if window is not valid
			obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('minimize');

            % Allow minimize for 'Standars' and 'FixedSize' Window
            % minimize only if the window is not on fullscreen mode
            if ~obj.isFullscreen && ... 
                    (strcmp(obj.windowType,'Standard') || strcmp(obj.windowType,'FixedSize'))
			    % Delegate command to channel
			    obj.Channel.execute('minimize');
            else
                error(message('cefclient:webwindow:UnsupportedOpForWindowType'));
            end
        end
        
        function maximize(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('maximize');
            
            % Don't maximize if non-resizable.
            if ~obj.isResizable
                if strcmp(obj.windowType,'Standard')
                    error(message('cefclient:webwindow:nonresizable'));
                else
                    error(message('cefclient:webwindow:UnsupportedOpForWindowType'));
                end
            end
            
            % Delegate command to channel
            obj.Channel.execute('maximize');
        end
        
        function restore(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('restore');

            if strcmp(obj.windowType,'Standard') || strcmp(obj.windowType,'FixedSize')
                % Delegate command to channel
                obj.Channel.execute('restore');
            else
                error(message('cefclient:webwindow:UnsupportedOpForWindowType'));
            end
        end   
        
        function state = isFullscreen(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow();
            state =  strcmp(obj.Channel.WindowState,'WindowFullscreen');
        end        
                
        function fullscreen(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('fullscreen');

            % This is supported for only 'Standard' window type.
            % Other window types are non-resizable and utility windows like
            % 'Dialog' or 'NoTitlebar' does not require fullscreen support
            if strcmp(obj.windowType,'Standard')
                % Delegate command to channel
                obj.Channel.execute('fullscreen');
                waitfor(obj.Channel, 'WindowState', 'WindowFullscreen');
            else
                error(message('cefclient:webwindow:UnsupportedOpForWindowType'));
            end
        end        
        
        function bringToFront(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('bringToFront');

            if strcmp( computer('arch'),{'win64'})
                options.WindowHandle = uint64(obj.WindowHandle);
                % Delegate command to channel
                obj.Channel.execute('bringToFront', options);
            else
                % Delegate command to channel
                obj.Channel.execute('bringToFront');
            end
        end
        
        function stopDownload(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('stopDownload');

            if ~obj.isDownloadingFile
                error(message('cefclient:webwindow:noDownloadInProgress'));
            end
            % Delegate command to channel
            obj.Channel.execute('stopDownload');

        end        
        
        function close(obj)
            
            if ~obj.isWindowValid
                % We don't need to close if the window has already been
                % closed.
                return;
            end
            % Unregister listeners.
            obj.MATLABClosingCallback = [];
            delete(obj.CustomEventListener);
            delete(obj.PropertyEventListener);
            windowMgr = matlab.internal.webwindowmanager.instance();
            deregisterWindow(windowMgr,obj);            
            % Close the asyncio channel.
            obj.Channel.close();
            obj.isWindowValid = false;
            if isempty(windowMgr.windowList)
                windowMgr.resetAllExtProcBrowser();
            end
        end
        
        function setActivateCurrentWindow(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setActivateCurrentWindow');
            
            % Construct arguments for sending command over on channel.
            options.isWindowActive = newValue;            
            
            % Delegate command to channel
            obj.Channel.execute('setActivateCurrentWindow', options);
            
            obj.isWindowActive = newValue;
            
        end
        
        function setAlwaysOnTop(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setAlwaysOnTop');
            
            % Construct arguments for sending command over on channel.
            options.AlwaysOnTop = newValue;            
            
            % Delegate command to channel
            obj.Channel.execute('setAlwaysOnTop', options);
            
            obj.isAlwaysOnTop = newValue;
            
        end        
        
        function value = isWindowActivated(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Get update from channel
            obj.isWindowActive = obj.Channel.isWindowActive; 
            
            value = obj.isWindowActive;
        end
        
        function enableDragAndDrop(obj)
            % Drag and Drop feature is disable for MATLABWindow by default.
            % To enable DND use this API.
            
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('enableDragAndDrop');

            obj.Channel.execute('enableDragAndDrop');
        end           
        
        function setActivateAllWindows(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setActivateAllWindows');
            
            % Construct arguments for sending command over on channel.
            options.isAllActive = newValue;            
            
            % Delegate command to channel
            obj.Channel.execute('setActivateAllWindows', options);
            
            obj.isAllActive = newValue;
            
        end  
        
        function value = allWindowActivated(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Get update from channel
            obj.isAllActive = obj.Channel.isWindowActive;    
            
            value = obj.isAllActive;
        end        
        
        function setWindowAsModal(obj,newValue)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('setWindowAsModal');
            
            % Construct arguments for sending command over on channel.
            options.isWindowModal = newValue;            
            
            % Delegate command to channel
            obj.Channel.execute('setWindowAsModal', options);
            
            obj.isModal = newValue;  
            
        end
        
        function value = isWindowModal(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Get update from channel
            obj.isModal = obj.Channel.isWindowModal;
            
            value = obj.isModal;
        end         
        
        function state = isMaximized(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            state =  strcmp(obj.Channel.WindowState,'WindowMaximized');
        end
        
        function state = isMinimized(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            state =  strcmp(obj.Channel.WindowState,'WindowMinimized');
        end
        
        function state = isVisible(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow();
            state =  strcmp(obj.Channel.WindowVisibility,'WindowVisible');
        end

        function result = executeJS(obj, jsStr, timeout)
            % Error if window is not valid
            obj.errorOnInValidWindow();
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('executeJS');

            narginchk(2,3);
            validateattributes(jsStr,{'char'},{'nonempty'}, mfilename, 'jsStr', 1);
            
            if nargin == 3
                validateattributes(timeout, {'numeric'}, {'nonempty', 'positive', 'scalar'});
            else
                timeout = inf;
            end
            
            % Clear out any old values from previous execution so that we
            % can wait on them.
            obj.Channel.JavaScriptReturnStatus = [];
            obj.Channel.JavaScriptReturnValue = [];
            options.JavaScript = jsStr;
            options.timeout = int64(timeout*1000);
            obj.Channel.execute('executeJS', options);
            drawnow;
            
            if isempty(obj.Channel.JavaScriptReturnStatus) && isempty(obj.Channel.JavaScriptReturnValue)
                error(message('cefclient:webwindow:jstimeout'));
            end
            
            if obj.Channel.JavaScriptReturnStatus
                error(message('cefclient:webwindow:jserror', obj.Channel.JavaScriptReturnValue));
            end
            
            result = obj.Channel.JavaScriptReturnValue;
                
        end
        
        function img = getScreenshot(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow();
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('getScreenshot');

            options = struct();
            obj.Channel.execute('getScreenshot', options);
            
            img = rot90(reshape(obj.Channel.ScreenshotData, obj.Channel.ScreenshotWidth, obj.Channel.ScreenshotHeight, 3));  
        end
        
    end
    
    methods

        function set.URL(obj,newValue)
            
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('set.URL');
            
            validateattributes(newValue,{'char'},{'2d'});
            
            % Apply connector nonce
            newValue = connector.applyNonce(newValue);
			
            % Construct arguments for sending command over on channel.
            options.URL = newValue;
            
            % Send command to channel
            obj.Channel.execute('SetURL',options);
            
            % Change it on webwindow
            obj.newURL = newValue;
        end        
        
        function url = get.URL(obj)
            url = obj.newURL;
        end        
        
        function title = get.Title(obj)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            
            title = obj.Channel.Title;
        end
            
        function set.Title(obj,newValue)
            
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('set.Title');
            
            validateattributes(newValue,{'char'},{'2d'});

            if isequal(obj.Title, newValue)  && ~isempty(obj.Title)
                return;
            else
                obj.Channel.Title = newValue;
            end
            
            % Construct arguments for sending command over on channel.
            options.Title = newValue;
            
            % Send command to channel
            obj.Channel.execute('SetTitle',options);
        end
        
        function set.Icon(obj,newValue)
            
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('set.Icon');
            
            validateattributes(newValue,{'char'},{'2d'});
            if exist(newValue, 'file')
                % Check for proper file format for respective platform
                [ ~, ~, extention ] = fileparts(newValue);
                arch = computer('arch');
                switch arch
                    case {'win32','win64'}
                        if ~strcmp(extention,'.ico')
                            error(message('cefclient:webwindow:useICOForWindowIcon'));
                        end
                    case {'glnx86','glnxa64'}
                        if ~strcmp(extention,'.png')
                            error(message('cefclient:webwindow:usePNGForWindowIcon'));
                        end
                    case {'maci64'}
                        %Check proper file format for maci
                end                
                    
                % Construct arguments for sending command over on channel.
                options.Icon = newValue;

                % Send command to channel
                obj.Channel.execute('SetIcon',options);

                % Change 
                obj.Icon = newValue;
            else
                error(message('cefclient:webwindow:invalidIconFile'));
            end
        end    

        function set.Position(obj,newPosition)
            % Error if window is not valid
            obj.errorOnInValidWindow()
            % Error if the channel has not yet been opened.
            obj.errorOnClosedChannel('set.Position');
            
            validateattributes(newPosition,{'numeric'},{'size',[1 4]});
            
            if ~isempty(obj.MaxSize)
                if ( (newPosition(3) > obj.MaxSize(1)) || (newPosition(4) > obj.MaxSize(2)) )
                    error(message('cefclient:webwindow:positionGreaterThanMaxSize'));
                end
            end
            
            if ~isempty(obj.MinSize)
                if ( (newPosition(3) < obj.MinSize(1)) || (newPosition(4) < obj.MinSize(2)) )
                    error(message('cefclient:webwindow:positionLessThanMinSize'));
                end
            end
            % Construct arguments for sending command over on channel.
            
            % MATLAB uses 1-based indices for position, the window manager
            % uses 0-based.
            args.X = int32(newPosition(1) - 1);
            args.Y = int32(newPosition(2) - 1);
            args.Width = int32(newPosition(3));
            args.Height = int32(newPosition(4));
            
            % Send command to channel
            obj.Channel.execute('SetPosition',args);
        end
        
        function set.CustomWindowClosingCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.CustomWindowClosingCallback = newValue;
        end
        
        
        function set.CustomWindowResizingCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.CustomWindowResizingCallback = newValue;
        end  
        
        function set.WindowResizing(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.WindowResizing = newValue;
        end          
        
        function set.WindowResized(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.WindowResized = newValue;
        end      
        
        function set.FocusGained(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.FocusGained = newValue;
        end   
        
        function set.FocusLost(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.FocusLost = newValue;
        end            
        
        function set.DownloadCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.DownloadCallback = newValue;
        end 
        
        function set.PageLoadFinishedCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.PageLoadFinishedCallback = newValue;
        end
        
        function set.PopUpWindowCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.PopUpWindowCallback = newValue;
        end 
        
        function set.WindowStateCallback(obj,newValue)
            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            obj.WindowStateCallback = newValue;
        end         
        
        function set.MATLABClosingCallback(obj, newValue)

            % If the channel has been closed, we don't need to do anything.
            if isempty(obj.Channel) || ~obj.Channel.isOpen
                return;
            end

            if(~internal.Callback.validate(newValue))
                error(message('cefclient:webwindow:invalidCallback'));
            end
            
            if isempty(newValue)
                obj.Channel.execute('removeMATLABClosingHandler');
            else
                obj.Channel.execute('addMATLABClosingHandler');
            end
            obj.MATLABClosingCallback = newValue;
        end
        
        function position = get.Position(obj)
            if (obj.InCallback || obj.isMinimized() || ~obj.Channel.isOpen)
                position = obj.CachedPosition;
                return;
            end

            % Error if window is not valid
            obj.errorOnInValidWindow()            
            obj.Channel.execute('GetPosition');
            position = double(obj.Channel.GetPosition);
            
            % Need to account for 1-based indexing in MATLAB
            position(1:2) = position(1:2) + 1;
            obj.CachedPosition = position;
        end
        
    end
    
    % Internal properties
    properties(Access = 'private', Transient)
        % A asyncio channel that  is used to handle all communication
        % between this MCOS object and cefclient C++ interface.
        Channel
        
        % Custom event listener for any custom event from asyncio channel.
        CustomEventListener
        
        PropertyEventListener
        
        InitialPosition = [ 100 100 600 400];
        
        UpdatedPosition
        
        newURL
        
        % Handle of the new window that was created.
        WindowHandle
        
        % Cached position to be used when running callbacks
        CachedPosition
        
        % Store the last event data used for a resize event so that we can
        % filter out duplicate events.
        LastResizeEvent
        
        % Indicate if we are potentially in a callback so that we don't try
        % to recurse into execute
        InCallback
    end
    
    % Event Handlers
    methods(Access='private')
        
        function initialize(obj)
            % This function is called after the object receives the new
            % window message to finish initialization. This is done so that
            % initialization happens while the event is still processing.
            
            obj.CEFVersion = obj.Channel.CEFVersion;
            obj.ChromiumVersion = obj.Channel.ChromiumVersion;
            obj.isWindowValid = true;
            obj.isDownloadingFile = false;
            obj.isModal = false;
            obj.isWindowActive=true;
            obj.isAllActive=true;
            obj.InCallback = false;
            obj.CachedPosition = obj.InitialPosition;
            obj.LastResizeEvent = [];
            
            windowMgr = matlab.internal.webwindowmanager.instance();
            registerWindow(windowMgr,obj);
            if ~windowMgr.isBrowserRunning(obj.BrowserMode)
                windowMgr.setBrowserRunStatus(obj.BrowserMode, true);

            end
            if strcmp(obj.windowType,'Standard') || strcmp(obj.windowType,'Dialog')
                obj.isResizable = true;
            else
                obj.isResizable = false;
            end
            
            lock(obj);
            
        end
               
        function lock(~)
            mlock;
        end
        
        function unlock(obj)
            openWindows = findAllWebwindows(obj);
            if isempty(openWindows)
                munlock;
            end
        end
        
        function restoreCallbackState(obj)
            if isvalid(obj)
                obj.InCallback = false;
            end
        end
        
        function onPropertyEvent(obj, eventType, eventData)
            if strcmp(eventType.Name,'WindowState') && ~isempty(obj.WindowStateCallback) 
                switch(eventData.AffectedObject.WindowState)
                    case {'WindowMaximized','WindowMinimized','WindowRestored','WindowFullscreen'}
                         internal.Callback.execute(obj.WindowStateCallback,...
                            obj,char(eventData.AffectedObject.WindowState));
                end
            end
        end
        
        function onCustomEvent(obj, eventType, eventData)
            
            obj.InCallback = true;
            oc = onCleanup(@obj.restoreCallbackState);
           
            switch(eventType)
                case 'popUpWindow'
                    % create webwindow object for the pop-up window
                    arg.URL = eventData.URL;
                    arg.WinID = eventData.WinID;
                    arg.WindowHandle = uint64(eventData.WindowHandle);
                    
                    window =  matlab.internal.webwindow(arg);
                    if ~isempty(obj.PopUpWindowCallback)
                        internal.Callback.execute(obj.PopUpWindowCallback,obj,window);
                    end
                  
                    
                case 'loadFinished'
                    if ~isempty(obj.PageLoadFinishedCallback)
                        internal.Callback.execute(obj.PageLoadFinishedCallback,obj);
                    end
                case 'windowClosing'
                    if ~isempty(obj.CustomWindowClosingCallback)
                        internal.Callback.execute(obj.CustomWindowClosingCallback,obj);
                    else
                        % Default  is to honor what the user tried doing -
                        % closing the window by default.
                        obj.close();
                    end
                case 'windowResizing'

                    % We need to make sure that the event that we are
                    % processing hasn't already been processed. On Linux
                    % there is no reliable way to send a resize done event.
                    % Additionally on some platforms, minimize generates a
                    % move event. If the position of the window hasn't
                    % changed since the last update and the last event
                    % processed was a resize end event, don't process this
                    % event. The resize end check is done because the last
                    % resizing event will have the same position as the
                    % resize end event.
                    newEvent = rmfield(eventData, 'didEndResize');
                    if isstruct(obj.LastResizeEvent)
                        oldEvent = rmfield(obj.LastResizeEvent, 'didEndResize');
                    else
                        oldEvent = [];
                    end
                    
                    if isequal(newEvent, oldEvent) && obj.LastResizeEvent.didEndResize
                        return;
                    end
                    obj.CachedPosition = [(eventData.x + 1), (eventData.y +1), eventData.width, eventData.height];
                    obj.LastResizeEvent = eventData;
                    
                    if ~isempty(obj.WindowResizing)
                        internal.Callback.execute(obj.WindowResizing,obj);
                    end
                    
                    % This "CustomWindowResizingCallback" will be deprecated once all the team start using
                    % "WindowResized"
                    if ~isempty(obj.CustomWindowResizingCallback)
                        internal.Callback.execute(obj.CustomWindowResizingCallback,obj);
                    end
                    
                    % If window has finished resizing execute the finished callback.
                    if eventData.didEndResize
                        if ~isempty(obj.WindowResized)
                            internal.Callback.execute(obj.WindowResized,obj);
                        end
                    end
                case 'downloadEvent'
                    if strcmp(eventData.DownloadStatus,'downloadStarting')
                        obj.isDownloadingFile = true;
                    end
                    if strcmp(eventData.DownloadStatus,'downloadCancelled')
                        obj.isDownloadingFile = false;
                    end
                    
                    if strcmp(eventData.DownloadStatus,'downloadFinished')
                        obj.isDownloadingFile = false;
                    end
                    
                    if strcmp(eventData.DownloadStatus,'downloadLocationUpdated')
                        obj.DownloadLocation = eventData.DownloadFilepath;
                    end                    
                    
                    if ~isempty(obj.DownloadCallback)
                        internal.Callback.execute(obj.DownloadCallback,obj,eventData);
                    end
                case 'MatlabClosing'
                    if ~isempty(obj.MATLABClosingCallback)
                        internal.Callback.execute(obj.MATLABClosingCallback,obj);
                    end
                case 'processExit'
                    close(obj);
                    if ~isempty(obj.MATLABWindowExitedCallback)
                        internal.Callback.execute(obj.MATLABWindowExitedCallback, obj);
                    end
                case 'windowFocused'
                    fm = com.mathworks.toolbox.matlab.webwindow.FocusManager.getInstance();
                    fm.setFocus(eventData.isFocused);
                    if eventData.isFocused
                        if ~isempty(obj.FocusGained)
                           internal.Callback.execute(obj.FocusGained,obj);
                        end
                    else
                        if ~isempty(obj.FocusLost)  
                            internal.Callback.execute(obj.FocusLost,obj);
                        end                    
                    end
            end            
        end
        
        function errorOnInValidWindow(obj)
            if ~obj.isWindowValid
                error(message('cefclient:webwindow:invalidWindow'));
            end
        end
        
        function errorOnClosedChannel(obj, methodname)
            % Error if the channel is not open. The most common cause of
            % this would be when in the debugger during object
            % construction.
            
            if isempty(obj.Channel) || ~obj.Channel.isOpen
                error(message('cefclient:webwindow:ClosedChannel', methodname));
            end
        end
    end
    
    methods
        function delete(obj)
            close(obj);
            unlock(obj);
            delete(obj.Channel);            
        end
        
        function list = findAllWebwindows(~)
            list= matlab.internal.webwindowmanager.instance.windowList;
        end
        
    end
    
    methods (Static)
        function missingLibraries = findMissingLibraries()
            missingLibraries = string.empty;
            
            binaryPath = fullfile(matlabroot, 'bin', computer('arch'), 'MATLABWindow');
            [status, result] = system(['ldd ' binaryPath]);
            
            % If ldd didn't work for some reason, just return. There is
            % nothing else that we can do.
            if status ~= 0
                return;
            end
            
            % Convert the result of ldd into an array of strings, one line
            % per string.
            result = string(strsplit(result, '\n'));
            
            % Search for libraries that do not have a load address specified.
            % If a library is found it will be printed with the address at
            % which it was loaded. If the library was not found, a string
            % will be printed (this string is "not found" in English).
            tokens = regexp(result, '^\s+(\w.*?) => .*?\w$', 'tokens', 'lineanchors');
            
            for currentToken = 1:length(tokens)
                currentResult = tokens{currentToken};
                if isempty(currentResult)
                    continue
                end
                missingLibraries(end+1) = currentResult{1};                
            end
        end
    end
end
