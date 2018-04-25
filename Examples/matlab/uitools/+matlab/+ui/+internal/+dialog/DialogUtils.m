classdef ( Sealed ) DialogUtils < handle
    % This class is undocumented and will change in a future release
    
    % Copyright 2014 The MathWorks, Inc.
    % This dialog utility is used as a switch to determine which dialogs to
    % show. Also it creates the appropriate dialog.
    
    methods (Static)     
        function retObj = createColorChooser()
            s = settings; 
            colorChooser = str2func(s.matlab.ui.dialog.uisetcolor.ControllerName.ActiveValue);
            retObj = colorChooser();
        end
        
        function retObj = createFontChooser()
            retObj = matlab.ui.internal.dialog.FontChooser();
        end
        
        function c = disableAllWindowsSafely()
            % This will disable all CEF windows (if any) from visual
            % interaction and activation.
            % This returns an onCleanup object that will re-enable the CEF
            % windows when it goes out of scope or is deleted.
            webWindows = matlab.internal.webwindowmanager.instance.findAllWebwindows();
            if isempty(webWindows)
                c = [];
                return;
            end
            w = webWindows(1); % Use the first one available.
            w.setActivateAllWindows(false);
            c = onCleanup(@() w.setActivateAllWindows(true));
        end
        
        function [iconData, alphaData] = imreadDefaultIcon(iconName)
            % This is a helper to read in the icons in uitools/private
            % directory. These are the standard icons used by error, warn,
            % help and quest dlg functions.
            iconFileName = fullfile(toolboxdir('matlab'), 'uitools', 'private', ['icon_' iconName '_32.png']);
            [iconData, ~, alphaData] = imread(iconFileName, 'BackgroundColor', 'none');
        end
    end
    
    methods (Hidden, Access = private)
        function obj = DialogUtils()
        end
    end
end