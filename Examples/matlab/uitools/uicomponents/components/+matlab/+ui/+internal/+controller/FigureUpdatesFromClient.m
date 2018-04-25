classdef (Abstract) FigureUpdatesFromClient < handle

    % abstract base class defining an interface that must be implemented in order for 
    % the figure to receive notification of property changes made by the client
    % 
    % Copyright 2016-2017 The MathWorks, Inc.

    methods (Access = public)

        % updatePositionFromClient() - update the figure Position
        updatePositionFromClient(this, Position)

        % updateWindowStateFromClient() - update the window state when maximized, etc.
        updateWindowStateFromClient(this, NewWindowState)
        
        % windowClosed() - notification that the figure window has been closed
        windowClosed(this)

    end % public methods

end
