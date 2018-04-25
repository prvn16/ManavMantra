function varargout = desktopfigure(varargin)
%DESKTOPFIGURE Create a web figure configured for use in desktop applications
%    DESKTOPFIGURE creates a web figure using default property values configured
%    for building apps in AppContainer/UIContainer.
%
%    DESKTOPFIGURE(Name, Value) specifies properties using one or more Name,
%    Value pair arguments.
%
%    fig = DESKTOPFIGURE(___) returns the figure object, fig. Use this
%    option with any of the input argument combinations in the previous
%    syntaxes.
%
%    Example 1: Create Default desktopfigure
%       fig = matlab.ui.internal.desktopfigure;
%
%    Example 2: Create a desktopfigure with a specific Color.
%       fig = matlab.ui.internal.desktopfigure('Color', [.9 .95 1]);
%
%    See also UIFIGURE

%    Copyright 2017 The MathWorks, Inc.


nargoutchk(0,1);

% signal that this is not only a web figure but also a desktopfigure
% presence of desktop member is all that is needed to indicate desktop as of July 2017
controllerInfo.ControllerClassName = 'matlab.ui.internal.controller.FigureController';
controllerInfo.desktop = 'on';

% Create the desktopfigure, configured for app building with AppContainer/UIContainer.
% Set defaults for unsupported properties first.
% After setting ControllerInfo, unsupported property sets will error.
% Set Internal true to protect from close all, findobj, findall, allchild,
% gcf, and gco: the app is responsible for tracking its content.
window = appwindowfactory('WindowStyle','normal',...
                          'DockControls','off',...
                          'HandleVisibility','off',...
                          'IntegerHandle','off',...
                          'MenuBar','none',...
                          'NumberTitle','off',...
                          'Toolbar','none',...
                          'ControllerInfo',controllerInfo,...
                          'AutoResizeChildren', 'on',...
                          'Internal', true,...
                          varargin{:});

% configure the new figure for application building
matlab.ui.internal.FigureServices.configureFigureForAppBuilding(window);

if (nargout > 0)
    varargout{1} = window;
end
