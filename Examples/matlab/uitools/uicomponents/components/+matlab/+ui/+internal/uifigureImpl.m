function varargout = uifigureImpl(varargin)
% internal implementation of uifigure creation
% Copyright 2017 The MathWorks, Inc.

nargoutchk(0,1);

controllerInfo.ControllerClassName = 'matlab.ui.internal.controller.FigureController';

% Create the uifigure, configured for app building
% Set defaults for unsupported properties first.
% After setting ControllerInfo, unsupported property sets will error.
window = appwindowfactory('WindowStyle','normal',...
                          'DockControls','off',...
                          'HandleVisibility','off',...
                          'IntegerHandle','off',...
                          'MenuBar','none',...
                          'NumberTitle','off',...
                          'Toolbar','none',...
                          'ControllerInfo',controllerInfo,...
                          'AutoResizeChildren', 'on',...
                          varargin{:});
                      
% configure the new figure for application building
matlab.ui.internal.FigureServices.configureFigureForAppBuilding(window);

if (nargout > 0)
    varargout{1} = window;
end

end
