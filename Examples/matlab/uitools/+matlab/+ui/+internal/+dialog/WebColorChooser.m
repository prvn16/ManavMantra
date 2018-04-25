classdef WebColorChooser < matlab.ui.internal.dialog.Dialog
    % This function is undocumented and will change in a future release
    
    % Copyright 2014-2016 The MathWorks, Inc.
    
    properties
        Title = getString(message('MATLAB:uistring:uisetcolor:TitleColor'));
        InitialColor = [1 1 1];
        
        SelectedColor;
        
        Browser;
        BrowserPanel;
        
        URL;
        
        RecentColors;
    end
    
    properties (Dependent)
        InitialHexColor;
    end
    
    methods
        function obj = WebColorChooser()
            obj.setupRecentColors();
            obj.setupURL();
            % Create modal JDialog peer
            obj.Peer = handle(javaObjectEDT(com.mathworks.mwswing.WindowUtils.createDialogToParent(obj.getParentFrame(), obj.Title, true)),'callbackproperties');
            obj.Peer.setName('BasicColorDialog');            
            obj.Peer.setResizable(false);
            obj.Peer.setCloseOnEscapeEnabled(true);
        end
        
        function set.Title(obj,v)
            if ~ischar(v)
                error('MATLAB:uidialog:InvalidTitle', getString(message('MATLAB:UiColorChooser:InvalidTitle')));
            end
            if ~isempty(v)
                obj.Title = v;
            end
            obj.Peer.setTitle(obj.Title);
        end
        
        function set.InitialColor(obj, v)
            %We are not going to allow values like [true false false]
            %as valid colors
            if ~isnumeric(v)
                error(message('MATLAB:UiColorChooser:InvalidColorType'));
            end
            %if multidimensional or column wise vector is given, extract color values
            obj.InitialColor = convert(obj,v);
            obj.setupURL();
        end
        
        function delete(obj)
            % Dispose Peer and Browser
            if ~isempty(obj.Peer)
                if ~isempty(obj.Browser)
                    obj.Browser.dispose();
                    obj.Peer.remove(obj.BrowserPanel);
                end
                obj.Peer.dispose();
            end
        end
        
        function show(obj)
            returnSubsciption = message.subscribe('/gbt/dialogs/uisetcolor/return',@(val) obj.onReturn(val));
            c = onCleanup(@() message.unsubscribe(returnSubsciption));
            
            % Create Browser in JDialog
            obj.Browser = javaObjectEDT(com.mathworks.mlwidgets.html.LightweightBrowserFactory.createLightweightBrowser());
            obj.BrowserPanel = obj.Browser.getComponent();
            
            % initialize the Zoom Scale:
            zoomScale = 1;
            FrameLoadPending = true;
            b = handle(obj.BrowserPanel.getBrowser(),'callbackproperties');
            b.OnFinishLoadingFrameCallback = @(o,e) frameLoadedHandler(o,e);            
            
            function frameLoadedHandler(~,~)
            try
                zoomScale = 1.2 ^ (obj.BrowserPanel.getBrowser().getZoomLevel());                
                FrameLoadPending = false;                
            catch
            end
            end
        
            obj.Browser.load(obj.URL);
            obj.Peer.add(obj.BrowserPanel);
            t0 = tic;
            while FrameLoadPending && toc(t0) <= 5 % Dont wait for more than 5 seconds
                drawnow limitrate
            end
            b.OnFinishLoadingFrameCallback = [];
            
            % Size the browser;
            width = zoomScale * 226;
            height = zoomScale * 321;
            if (isunix || (ispc && (com.mathworks.util.PlatformInfo.getVirtualScreenDPI() > 120)))
                width = com.mathworks.util.ResolutionUtils.scaleSize(width);
                height = com.mathworks.util.ResolutionUtils.scaleSize(height);
            end
            obj.BrowserPanel.setPreferredSize(java.awt.Dimension(width, height));
            obj.Peer.pack();
                        
            % Position centered and 1/3 of the way down on parent.
            bounds = obj.getParentFrame().getBounds();
            dialogSize = obj.Peer.getSize();
            bounds.x = bounds.x + ((bounds.width - dialogSize.width) / 2);
            bounds.y = bounds.y + ((bounds.height - dialogSize.height) / 3);
            obj.Peer.setLocation(bounds.x, bounds.y);        

            obj.blockMATLAB();
            drawnow;
        end
        
        function out = get.InitialHexColor(obj)
            v = round(255 * obj.InitialColor);
            out = lower([dec2hex(v(1),2) dec2hex(v(2),2) dec2hex(v(3),2)]);
        end
    end
    
    methods(Access = protected)
        function onReturn (obj, value)
            if strcmpi(value,'cancel')
                obj.SelectedColor = [];
            else
                if contains(value, obj.InitialHexColor, 'IgnoreCase', true)
                    % If initial value is the same as value returned then
                    % do nothing and take initial value to avoid rounding.
                    obj.SelectedColor = obj.InitialColor;
                else
                    % Convert incoming hex value to a MATLAB based 0-1 3 element color array
                    c = [hex2dec(value(2:3)) hex2dec(value(4:5)) hex2dec(value(6:7))];
                    obj.SelectedColor = c/255;
                end
                obj.updateRecentColors(value(2:end));
            end
            obj.unblockMATLAB()
        end
        
        function setupURL(obj)
            baseURL = sprintf('/toolbox/matlab/uitools/uidialogs/uisetcolorappjs/index.html?init=%s&recent=%s', obj.InitialHexColor, obj.RecentColors);
            % create web URL
            connector.ensureServiceOn();
            obj.URL = connector.getUrl(baseURL);
        end
        
        function blockMATLAB(obj)
            % On Showing the JWebDialog it is modal and blocks the MATLAB thread.
            obj.Peer.setVisible(true);
        end
        
        function unblockMATLAB(obj)
            % To Unblock we will simply dispose the JavaWebDialog
            obj.Peer.setVisible(false);
            drawnow;
        end
    end
    
    methods (Access = private)
        function setupRecentColors(obj)
            s = settings;
            obj.RecentColors = s.matlab.ui.dialog.uisetcolor.RecentlyUsedColors.ActiveValue;
        end
        
        function updateRecentColors(obj, newColor)
            if (~isempty(strfind(obj.RecentColors, newColor)))
                return;
            end
            obj.RecentColors = [obj.RecentColors(8:end) '-' newColor];
            s = settings;
            s.matlab.ui.dialog.uisetcolor.RecentlyUsedColors.PersonalValue = obj.RecentColors;
        end
        
        function bool = isvalidmultidimensional(~, v)
            sizeofv = size(v);
            occurrencesofthree = find(sizeofv==3);
            if (length(occurrencesofthree)~=1  && prod(sizeofv)~=3)
                bool =false;
            else
                bool = true;
            end
        end
        
        function color = convert(obj, v)
            if isvalidmultidimensional(obj, v)
                color = [v(1) v(2) v(3)];
            else
                error(message('MATLAB:UiColorChooser:InvalidColorDimension'));
            end
            %Checking range of rgb values
            if ismember(0,((color(:)<=1) & (color(:)>=0)))
                error(message('MATLAB:UiColorChooser:InvalidRGBRange'));
            end
        end
    end
end