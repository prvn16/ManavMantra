classdef FigurePlatformHostFactory < handle

    % FIGUREPLATFORMHOSTFACTORY is the factory class that creates a FigurePlatformHost instance
    %                           for the environment in which the FigureController is created.
    % 
    % Copyright 2016-2017 The MathWorks, Inc.

    methods (Access = public)

        % constructor
        function this = FigurePlatformHostFactory()
        end % constructor

        % createHost - create a FigurePlatformHost for the current platform
        function figurePlatformHost = createHost(this, controllerInfo, updatesFromClientImpl)
            
            % get the appropriate host class and instantiate it
            hostClass = this.getPlatformHostClass(controllerInfo);
            figurePlatformHost = hostClass(updatesFromClientImpl);
            
        end % createHost()

    end % public methods

    methods (Access = private)

        % getPlatformHostClass - detect the platform and
        %                        get the FigurePlatformHost class appropriate for it
        function platformHost = getPlatformHostClass(~, controllerInfo)
            if isfield(controllerInfo, 'desktop')
                % Desktop designation takes priority over all other conditions
                platformHost = @matlab.ui.internal.controller.platformhost.DesktopFigurePlatformHost;
            else
                s = settings;
                if (s.matlab.ui.figure.ShowInWebApps.ActiveValue || ...
                   (isdeployed && matlab.internal.environment.context.isWebAppServer))
                    platformHost = @matlab.ui.internal.controller.platformhost.WebAppsFigurePlatformHost;
                elseif s.matlab.ui.figure.ShowInMATLABOnline.ActiveValue
                    platformHost = @matlab.ui.internal.controller.platformhost.MOFigurePlatformHost;
                else
                    platformHost = @matlab.ui.internal.controller.platformhost.CEFFigurePlatformHost;
                end
            end
        end % getPlatformHostClass()

    end % private methods

end