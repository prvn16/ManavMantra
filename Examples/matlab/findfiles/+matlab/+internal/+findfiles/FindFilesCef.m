% Copyright 2015 - 2017 MathWorks, Inc.

classdef (Sealed = true) FindFilesCef < handle
    
    properties (Access=public)
        CefHandle
        DebugPort
    end
    
    methods (Access = private)
        function newObj = FindFilesCef()
        end
    end
    
    methods (Static)
        function obj = getInstance()
            persistent uniqueFindFilesCef;
            if (isempty(uniqueFindFilesCef))
                obj = matlab.internal.findfiles.FindFilesCef();
                uniqueFindFilesCef = obj;
            else
                obj = uniqueFindFilesCef;
            end
        end
    end
    
    methods (Access = public)
        function launchCefWindow(obj)
            if (~obj.findFilesExists())
                path = '/toolbox/matlab/findfiles/index.html';
                url = connector.getUrl(path);
                obj.DebugPort = matlab.internal.getOpenPort;
                screenSize = get(0,'screensize');
                obj.CefHandle = matlab.internal.webwindow(url, obj.DebugPort);
                obj.CefHandle.CustomWindowClosingCallback = @obj.close;
                obj.setTitle('Find Files');
                obj.setPosition([(ceil(screenSize(3:4)/2) - [425 210]) 854 450]);
                obj.CefHandle.show();
            else
                obj.bringToFront();
            end
        end
        
        function exists = findFilesExists(obj)
            exists = ~(isempty(obj.CefHandle) || ~obj.CefHandle.isWindowValid);
        end
        
        function setMinSize(obj, size)
            obj.CefHandle.setMinSize(size);
        end
        
        function setPosition(obj, position)
            obj.CefHandle.Position = position;
        end
        
        function close(obj, ~, ~)
            obj.CefHandle.close();
            obj.CefHandle = [];
        end
        
        function bringToFront(obj)
            obj.CefHandle.bringToFront();
        end
        
        function setTitle(obj, title)
            obj.CefHandle.Title = char(title);
        end

        function minimize(obj)
            obj.CefHandle.minimize;
        end

        function restore(obj)
            obj.CefHandle.restore;
        end

        function updateUrl(obj, url)
        end
        
        function dialogUrl = getUrl(obj)
            dialogUrl = obj.CefHandle.URL;
        end
        
        function debugPort = getDebugPort(obj)
           debugPort = obj.DebugPort; 
        end
    end
end