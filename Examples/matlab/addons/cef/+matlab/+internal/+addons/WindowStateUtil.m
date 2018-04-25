classdef (Sealed = true) WindowStateUtil < handle
    %%%%%%%%%%
    %
    %  Copyright: 2016-2017 The MathWorks, Inc.
    %
    %%%%%%%%%%
    
    properties (Constant, Access = private)
            DEFAULT_CLIENT_WIDTH = 1280;
            DEFAULT_CLIENT_HEIGHT = 720;
            WINDOW_TITLE_BAR_HEIGHT = 22;
    end
    
    methods (Access = {?matlab.internal.addons.Explorer, ?matlab.internal.addons.Manager})
    
        function position = getPositionForExplorer(obj)
            s = settings;
            if (s.matlab.addons.explorer.Position.hasPersonalValue)
                position = obj.getValidPosition(s.matlab.addons.explorer.Position.PersonalValue);
            else
                position = obj.getDefaultPosition;
            end
        end
        
        function position = getPositionForManager(obj)
            s = settings;
            if (s.matlab.addons.manager.Position.hasPersonalValue)
                position = obj.getValidPosition(s.matlab.addons.manager.Position.PersonalValue);
            else
                position = obj.getDefaultPosition;
            end
        end
        
        function setExplorerPositionSetting(obj, position)
            s = settings;
            s.matlab.addons.explorer.Position.PersonalValue = position;
        end
        
        function setManagerPositionSetting(obj, position)
            s = settings;
            s.matlab.addons.manager.Position.PersonalValue = position;
        end
        
        function setExplorerWindowMaximizedSetting(~, maximized)
            s = settings;
            s.matlab.addons.explorer.Maximized.PersonalValue = maximized;
        end
        
        function setManagerWindowMaximizedSetting(~, maximized)
            s = settings;
            s.matlab.addons.manager.Maximized.PersonalValue = maximized;
        end
        
        function windowState = getExplorerWindowMaximizedSetting(~)
            s = settings;
            if(~s.matlab.addons.explorer.Maximized.hasPersonalValue)
                s.matlab.addons.explorer.Maximized.PersonalValue = false;
            end
            windowState = s.matlab.addons.explorer.Maximized.PersonalValue;
        end
        
        function windowState = getManagerWindowMaximizedSetting(~)
            s = settings;
            if(~s.matlab.addons.manager.Maximized.hasPersonalValue)
                s.matlab.addons.manager.Maximized.PersonalValue = false;
            end
            windowState = s.matlab.addons.manager.Maximized.PersonalValue;
        end
        
    end
    
    methods (Access = private)
        
        %%%%%%%
        %   Adjusts the Position as required to keep the window on the
        %   screen or screens in case of multiple desktop environment
        %%%%%%%
        function position = getValidPosition(obj, position)
            point = java.awt.Point(position(1), position(2));
            dimension = java.awt.Dimension(position(3), position(4));
            pointToBeUsed = com.mathworks.mwswing.WindowUtils.ensureOnScreen(point, dimension, 0);
            position = [pointToBeUsed.x pointToBeUsed.y position(3) position(4)];
        end
        
        function defaultPosition = getDefaultPosition(obj)
            screenSize = get(groot,'screensize');
            yPosition = screenSize(4) - obj.DEFAULT_CLIENT_HEIGHT - obj.WINDOW_TITLE_BAR_HEIGHT;
            if (yPosition < 0) 
                yPosition = 0;
            end
            defaultPosition = [0, yPosition, obj.DEFAULT_CLIENT_WIDTH, obj.DEFAULT_CLIENT_HEIGHT];
        end
    end
end