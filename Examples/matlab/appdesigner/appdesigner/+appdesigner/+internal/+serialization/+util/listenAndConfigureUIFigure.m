function onCleanupObject = listenAndConfigureUIFigure()
    % Apply default value settings to a newly instantiated figure upon
    % loading from a serialized file to ensure children under this figure has
    % the correct default property values.
    % For example: 
    %    default FontSize for uipanel: 12px
    % see g1573715 and g1680194.
    
    % Copyright 2017 The MathWorks, Inc.
    
    % apply the figures default system to all the components

   figureCreatedListener = event.listener(?matlab.ui.Figure, 'InstanceCreated', ...
       @(o,e)matlab.ui.internal.FigureServices.configureFigureForAppBuilding(e.Instance));

   onCleanupObject = onCleanup(@()delete(figureCreatedListener));   
end
