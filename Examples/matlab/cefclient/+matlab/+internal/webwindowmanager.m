classdef webwindowmanager < handle
%webwindowmanager keeps track of number of webwindows created using 
%CEF (Chromium Embedded Framework)component

%Copyright 2014-2017 The MathWorks, Inc.    
    
   methods(Access=private)
      function newObj = webwindowmanager()
          newObj.BrowserRunningInProc = false;
          newObj.BrowserRunningExtProc = false;
          newObj.DebugPortExtProc = 0;
          newObj.DebugPortInProc = 0;
          newObj.ProxyServer = [];
          newObj.ProxyCredentials = [];
          newObj.StartupOptions = [];
          newObj.CurrentBrowserStartupOptions = [];
      end
      
   end
   
   methods(Static)
      function obj = instance()
         persistent uniqueInstance;
         if isempty(uniqueInstance)
            obj = matlab.internal.webwindowmanager();
            uniqueInstance = obj;
         else
            obj = uniqueInstance;
         end
      end
   end
   
   properties( SetAccess = private, GetAccess = public )
       
       windowList= matlab.internal.webwindow.empty();
       
       windowListInProc= matlab.internal.webwindow.empty();
       
       % "StartupOptions" displays what options that user has passed to the browser process.
       % User can pass various startup options to the browser. 
       % All the options that can be passed are in this link http://peter.sh/experiments/chromium-command-line-switches/
       % This property does not get cleared when the browser is closed. It retains
       % the value for the current MATLAB session. User can manually
       % overwrite it or clear it. To view all the browser options on a currently running
       % browser use getCurrentStartupOptions() method.
       StartupOptions  
       
   end
   
   properties( SetAccess = private, GetAccess = private )

       BrowserRunningExtProc
       
       BrowserRunningInProc
       
       DebugPortExtProc
       
       DebugPortInProc       
       
       % "ProxyServer" is internal and the value is obtained from 
       % the evnironment variable MATLAB_WEBWINDOW_PROXY first else from 
       % the "StartupOptions" property and if both are empty then the proxy
       % settings from MATLAB Preference->Web settings is used.
       % The proxy value should have the format of '--proxy-server=host:port'.
       ProxyServer
       
       % The stores the credentials for authenticated proxy server.
       % User can set the credentials using setProxyCredentials() method
       % before the first webwindow is launched.
       % The format of ProxyCredentials should be in username:password
       ProxyCredentials   
       
       % This property stores all the options passed to the browser process
       CurrentBrowserStartupOptions
      
   end
   
   
   methods(Hidden=true)
       
        function requiredOptions = requiredStartupOptions(obj, mode)
            requiredOptions = [];
            if ~obj.isBrowserRunning(mode)
                % Get locale
                locInfo = feature('locale');
                lang = strtok(locInfo.messages, '.'); 
                
                requiredOptions = [ '-from-webwindow' ' ' ...
                                    '-custom-close-listener-enable=1' ' ' ...
                                    '-locale=',lang ' ' ...
                                    '--proxy-bypass-list=<local>' ' ' ...
                                    '-processid=',int2str(int32(feature('getpid')))
                                   ];
            end
        end
        
        function startupOptions = buildDefaultStartupOptions(obj, mode)
            startupOptions = [];
            if ~obj.isBrowserRunning(mode)
                disableGPU = false;
                gpuOptions=[];
                % Check if MATLAB is launched woth software openGL or 
                % Check for blacklisted h/w
                if com.mathworks.hg.GraphicsOpenGL.isSoftwareOpenGL || ...
                        ~strcmp(com.mathworks.hg.GraphicsOpenGL.getHardwareSupportLevel(),'full')
                    disableGPU = true;
                end
                % If GPU needs to be disabled add GPU options
                if disableGPU
                    % On MAC disable-gpu disables webGL completely with no software rendering.
                    % Disable only the compositing here
                    if strcmp( computer('arch'),{'maci64'})
                        gpuOptions = [ '--disable-accelerated-2d-canvas' ' ' ...
                                   '--disable-gpu-compositing'];
                    else
                        gpuOptions = '--disable-gpu';
                    end
                else
                    gpuOptions=[];
                end
                % For depolyed apps on linux disable gpu
                if isdeployed && (strcmp( computer('arch'),{'glnxa64'}) || ...
                        strcmp( computer('arch'),{'glnx86'}))
                    gpuOptions = '--disable-gpu';
                end  
                
                startupOptions = [  '-log-severity=disable' ' ' ...
                                    '--disable-background-timer-throttling' ' ' ...
                                    '--disable-renderer-backgrounding' ' ' ...
                                    '-cache-path=',char(tempname)
                                  ];
                if char(gpuOptions)
                    startupOptions = [startupOptions ' ' char(gpuOptions)];
                end                              
                              
                if char(obj.ProxyServer)
                    startupOptions = [startupOptions ' ' obj.ProxyServer];
                end

                % Append any StartupOptions set by user in the end
                % which over-rides the previous options
                if char(obj.StartupOptions)
                    startupOptions = [startupOptions ' ' obj.StartupOptions];
                end
                % DebugPort must be set at the end to over-write the
                % debugport set earlier as it can be set
                % using setStartupOptions()
                if obj.DebugPortExtProc && strcmp(mode,'ExternalProcess')
                    startupOptions = [startupOptions ' ' '-remote-debugging-port=',int2str(obj.DebugPortExtProc)];
                else
                    if obj.DebugPortInProc && strcmp(mode,'InProcess')
                        startupOptions = [startupOptions ' ' '-remote-debugging-port=',int2str(obj.DebugPortInProc)];
                    end
                end                
            
                
                if (computer('arch') == "glnxa64")
                    settingsGroup = settings;
                    desktopSettings = settingsGroup.matlab.desktop;
                    if (desktopSettings.hasSetting('DisplayScaleFactor'))
                        displayScaleFactorSetting = desktopSettings.DisplayScaleFactor;
                        if (displayScaleFactorSetting.hasPersonalValue)
                            displayScaleFactor = displayScaleFactorSetting.ActiveValue;
                            startupOptions = [startupOptions ' ' '--force-device-scale-factor=' num2str(displayScaleFactor)];
                        end
                    end
                end
                
                % Update the StartupOptions value in windowmanager
                obj.CurrentBrowserStartupOptions = startupOptions;
            end

        end               
       
       function readProxyServer(obj, mode)

           if ~obj.isBrowserRunning(mode)
               % Read the env variable if it's set. It takes priority over
               % other values               
               proxyServer = getenv('MATLAB_WEBWINDOW_PROXY');
               if char(proxyServer)
                  obj.ProxyServer = proxyServer;
               else
                   % Read if from Web->Preference only StartupOptions is not set or 
                   % StartupOptions does not have proxy-server 
                   if isempty(obj.StartupOptions) ...
                           || isempty(strfind(obj.StartupOptions,'proxy-server'))
                       % By default we pick the Web-> Preference proxy settings
                       net = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
                       if char(net.getProxyHost())
                            obj.ProxyServer = [ '--proxy-server=',strcat(char(net.getProxyHost()),':',char(net.getProxyPort()))];
                       end
                   end
               end
           end
       end
       
       function credentials = readProxyCredentials(obj) 
           credentials = [];
           if char(obj.ProxyCredentials)
                credentials = obj.ProxyCredentials;
           else
                % Send the aunthentication details if available in settings 
                net = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
                if char(net.getProxyUser())
                    credentials = strcat(char(net.getProxyUser()),':',char(net.getProxyPassword()));
                end
           end
       end
       
       function resetAllExtProcBrowser(obj)
          obj.BrowserRunningExtProc = false;
          obj.DebugPortExtProc = 0;
          obj.ProxyServer = [];
          obj.ProxyCredentials = [];
          obj.CurrentBrowserStartupOptions = [];
          %obj.windowList= matlab.internal.webwindow.empty();
       end
       
       function setBrowserRunStatus(obj, mode, isRunning)
           if strcmp (mode,'InProcess')
               obj.BrowserRunningInProc = isRunning;
           else
               obj.BrowserRunningExtProc = isRunning;
           end
       end       
       
       function setDebugPort(obj, port)
           obj.DebugPortExtProc = port;
           if ~obj.isBrowserRunning('InProcess')
               obj.DebugPortInProc = port;
           end
       end

        function registerWindow(obj,value)
            if strcmp(value.BrowserMode,'ExternalProcess')
                obj.windowList(end+1)=value;
            else
                obj.windowListInProc(end+1)=value;
            end
           
           % Lock the file to prevent warning messages being displayed when
           % clear classes is called.
           mlock;
        end
        
        function deregisterWindow(obj,value)
           if isvalid(obj) && ~isempty(obj.windowList) && strcmp(value.BrowserMode,'ExternalProcess')
              obj.windowList(obj.windowList == value) = [];	
              
              % If the window list is empty, we no longer need to lock the
              % instance.
              if isempty(obj.windowList)
                  munlock;
              end
           else
               if isvalid(obj) && ~isempty(obj.windowListInProc) && strcmp(value.BrowserMode,'InProcess')
                  obj.windowListInProc(obj.windowListInProc == value) = [];	

                  % If the window list is empty, we no longer need to lock the
                  % instance.
                  if isempty(obj.windowListInProc)
                      munlock;
                  end                   
               end
           end
        end
   end
   
   % Pulic methods
   methods
       % Get all startupOptions for the current running browser
       function allOptions = getCurrentStartupOptions(obj)
           allOptions = obj.CurrentBrowserStartupOptions;
       end
        % Gets all the webwindow handle
        function list = findAllWebwindows(obj)
                list= obj.windowList;
        end 
        
        function setProxyCredentials(obj, proxyUser)
            
            narginchk(1, 2);
            validateattributes(proxyUser,{'char'},{'nrows',1});
            if obj.BrowserRunning
                % Display warning to let user know that proxy setting 
                % will be ignored as browser is already running
                warning(message('cefclient:webwindow:ProxyWillBeIgnored'));
            end
            
            if char (proxyUser)
                obj.ProxyCredentials = proxyUser;
            end                
        end
        
        function setStartupOptions(obj,mode, configOptions)
            % If browser is already running display error
            if obj.isBrowserRunning(mode)
                warning(message('cefclient:webwindow:StartupOptionsIgnored'));
            end
            
            if contains(configOptions,'remote-debugging-port')
                error(message('cefclient:webwindow:DebugportInStartupOptions'));
            end
            
            obj.StartupOptions = char(configOptions);
        end  
        
        function value = isBrowserRunning(obj,mode)
            if strcmp(mode,'InProcess')
                value = obj.BrowserRunningInProc;
            else
                value = obj.BrowserRunningExtProc;
            end
        end
        function value = DebugPort(obj,varargin)
            p = inputParser;
            addParameter(p,'BrowserMode','ExternalProcess',@ischar);
            p.parse(varargin{:});
            % If there are no arguments return DebugPort for external
            % process as it's the default.
            if isempty(varargin)
                value = obj.DebugPortExtProc;
            else
                if strcmp(p.Results.BrowserMode,'InProcess')
                    value = obj.DebugPortInProc;
                else
                    value = obj.DebugPortExtProc;
                end 
            end
        end
    end
    
end
