classdef DesktopFigurePlatformHost < matlab.ui.internal.controller.platformhost.FigurePlatformHost

    % FigurePlatformHost class containing the Desktop platform-specific functions for
    % the matlab.ui.internal.controller.FigureController object
    % 
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access = protected)
        ReleaseHTMLFile = 'componentContainer.html'; 
    end
    
    methods (Access = public)

        % constructor
        function this = DesktopFigurePlatformHost(updatesFromClientImpl)
            this = this@matlab.ui.internal.controller.platformhost.FigurePlatformHost(updatesFromClientImpl);
        end % constructor

        % destructor
        function delete(~)
        end % delete()
        
        % isDrawnowSyncSupported() - platform-specific function to return whether or not drawnow synchronization is supported
        function status = isDrawnowSyncSupported(this)
            status = true;
        end

        %
        % methods delegated to by FigureController and implemented by this FigurePlatformHost child class
        %
        
        % NO DELEGATED METHODS CURRENTLY REQUIRED

    end % public methods

end