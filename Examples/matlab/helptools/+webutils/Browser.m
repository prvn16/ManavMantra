classdef (Hidden=true) Browser < handle
% BROWSER provides an M wrapper for Java web browsers.
% This wrapper can be used to make JavaScript calls from MATLAB to a web
% browser,.
% This class is unsupported and may change at any time.

% Copyright 2008-2011 The MathWorks, Inc.

    properties (Access=private, Hidden=true)
        HtmlComponent;
    end
    
    methods
        function obj = Browser(browserArg)
            % Constructs a browser wrapper.
            if isnumeric(browserArg)
                obj.HtmlComponent = com.mathworks.mlwidgets.html.HtmlComponentRegistry.getHtmlComponent(browserArg);
            elseif isjava(browserArg) && isa(browserArg, 'com.mathworks.html.HtmlComponent')
                obj.HtmlComponent = browserArg;
            elseif isjava(browserArg) && isa(browserArg, 'com.mathworks.html.HtmlComponentClient')
                obj.HtmlComponent = browserArg.getHtmlComponent;
            else
                error(message('MATLAB:webutils:InvalidBrowser'));
            end
        end
        
        function setCurrentLocation(obj, location)
            % Loads a page in the browser.
            obj.getBrowser.setCurrentLocation(location);
        end
        
        function setHtmlText(obj, text)
            % Displays the HTML text in the browser.
            obj.getBrowser.setHtmlText(text);
        end
        
        function javascript(obj, script, varargin)
            % Executes JavaScript in the browser.
            browser = handle(obj.getBrowser,'callbackProperties');
            c = onCleanup(@() browser.delete);
            if ~isempty(varargin) > 0
                callbackObj = webutils.JavaScriptCallback(varargin{1});
                set(browser, 'HtmlDataReceivedCallback', @callbackObj.execute);
            end
            
            try
                browser.executeScript(script);
            catch e %#ok<NASGU>
                if ~isempty(callbackObj)
                    callbackObj.delete;
                end
            end
        end
        
        function html = getHtmlText(obj)
            % Returns the HTML source of the current document.
            browser = obj.getBrowser;
            html = char(browser.getHtmlText);
        end
        
        function loc = getCurrentLocation(obj)
            % Returns the location of the current document.
            browser = obj.getBrowser;
            loc = char(browser.getCurrentLocation);
        end
    end
    
    methods (Access = private)
        function browser = getBrowser(obj)
            browser = com.mathworks.mlwidgets.html.MatlabHtmlComponentBridge(obj.HtmlComponent);
        end
    end
end