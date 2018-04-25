classdef LoginCefWindow < handle
    % LoginCefWindow handles displaying the Login Window dialog to users.
    
    
    properties (Access = 'private')
        Window
        debugPort
        URL
    end
    
    properties (Access = 'private', Constant)
        Width = 470
        Height = 474
        Title = message('MATLAB:matlablogin:LogIn').getString();        
    end
    
    methods (Access = 'private')
        function obj = LoginCefWindow(varargin)
            connector.ensureServiceOn;
        end
        
        function doShow(obj)
            import internal.matlab.desktop.login.LoginCefWindow;            
            
            % Shows the web window. Creates it if it doesn't exist.            
            if isempty(obj.Window) || ~obj.Window.isWindowValid
                
                LoginCefWindow.getInstance().doInitializeWindow();
                LoginCefWindow.getInstance().doSetupAndShowWindow();
                
                % Ensure that we think the window has gone if the user clicks the close button
                obj.Window.CustomWindowClosingCallback = @(~, ~) obj.Window.hide;
            elseif ~obj.Window.isVisible
                LoginCefWindow.getInstance().doSetupAndShowWindow();                
            else
                obj.Window.URL = getURL();
                obj.Window.Position = getCenteredLocation(); 
                obj.Window.bringToFront();
            end
        end
        
        function doInitializeWindow(obj, varargin)
            import internal.matlab.desktop.login.LoginCefWindow;            
            
            if isempty(obj.Window) || ~obj.Window.isWindowValid               
                obj.debugPort = matlab.internal.getOpenPort;                
                obj.Window = matlab.internal.webwindow(getURL(), 'DebugPort', obj.debugPort, 'Position', getCenteredLocation() ,'WindowType', 'FixedSize');                
                obj.Window.Title = LoginCefWindow.Title;
				               
                % Ensure that we think the window has gone if the user clicks the close button
                obj.Window.CustomWindowClosingCallback = @(~, ~) obj.Window.hide;
            end            
        end
        
        function doSetupAndShowWindow(obj)
            import internal.matlab.desktop.login.LoginCefWindow;
            obj.Window.URL = getURL();
            obj.Window.Position = getCenteredLocation();
            obj.Window.show();
            obj.Window.bringToFront();
        end
        
        function doHide(obj)            
            if ~isempty(obj.Window)
                obj.Window.hide();                
            end
        end
        
        function doDispose(obj)            
            if ~isempty(obj.Window)
                obj.Window.delete();
                obj.Window = [];
            end
        end
        
        function delete(obj)
            if ~isempty(obj.Window)
                obj.Window.delete();
            end
        end
        
        function debugPort = getDebuggingPort(obj)
            debugPort = obj.debugPort;
        end
        
        function windowURL = getWindowURL(obj)
            windowURL = obj.Window.URL;
        end
    end
    
    methods (Static, Access = 'private')
        function instance = getInstance()
            import internal.matlab.desktop.login.LoginCefWindow;
            % getInstance - Get the instance of the Login Dialog Window
            persistent sInstance
            if isempty(sInstance)
                sInstance = LoginCefWindow();
            end
            instance = sInstance;
        end
    end
    
    methods (Static)
        function show()
            import internal.matlab.desktop.login.LoginCefWindow;
            LoginCefWindow.getInstance().doShow();
        end        
        function dispose()
            import internal.matlab.desktop.login.LoginCefWindow;
            LoginCefWindow.getInstance().doDispose();
        end
        function hide()
            import internal.matlab.desktop.login.LoginCefWindow;
            LoginCefWindow.getInstance().doHide();
        end
        function initWindow()
            import internal.matlab.desktop.login.LoginCefWindow;
            LoginCefWindow.getInstance().doInitializeWindow();
        end
        function port = getPort()
            import internal.matlab.desktop.login.LoginCefWindow;
            port = LoginCefWindow.getInstance().getDebuggingPort();
        end
        function url = getURL()
            import internal.matlab.desktop.login.LoginCefWindow;
            url = LoginCefWindow.getInstance().getWindowURL();
        end
    end 
    
end

function location = getCenteredLocation()
    import internal.matlab.desktop.login.LoginCefWindow;
    desiredWidth = LoginCefWindow.Width;
    desiredHeight = LoginCefWindow.Height;
    
    screenSize = getPositionOfScreenMatlabIsOn();    
    screenWidth = screenSize(3);    
    screenHeight = screenSize(4);   
    
    xPos = screenSize(1)+(screenWidth - desiredWidth)/2;
    yPos = screenSize(2)+(screenHeight - desiredHeight)/2;
    
    location = [xPos, yPos, desiredWidth, desiredHeight];
end

function pos = getPositionOfScreenMatlabIsOn()
    pos = get(groot,'MonitorPositions');
    dPos = getDesktopPosition();
    % For multiple monitor setup, determine which screen contains the major 
    % part of MATLAB to figure out which screen MATLAB is currently on 
    [~, scrnIdx] = max(rectint(dPos, pos));    
    pos = pos(scrnIdx, :);
end

function pos = getDesktopPosition()
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    desktopMainFrame = desktop.getMainFrame;
    bounds = desktopMainFrame.getBounds;
    x      = bounds.getX;
    y      = bounds.getY;
    width  = bounds.getWidth;
    height = bounds.getHeight;
    pos = [x, y, width, height];
end

function url = getURL()
    url = connector.getUrl('/toolbox/matlab/matlab_login_framework/web/LoginPanelContainer.html');
end
