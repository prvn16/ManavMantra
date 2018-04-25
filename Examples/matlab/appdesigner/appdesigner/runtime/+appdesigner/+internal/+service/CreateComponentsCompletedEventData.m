classdef CreateComponentsCompletedEventData < event.EventData
    % CREATECOMPONENTSCOMPLETEDEVENTDATA Event data class for 
    % 'AppCreateComponentsExecutionCompleted' event

    % Copyright 2017 The MathWorks, Inc.

   properties
      App
      Figure
      FigureURL
   end

   methods
      function data = CreateComponentsCompletedEventData(app, figure)
         data.App = app;
         data.Figure = figure;         
      end
      
      function URL = get.FigureURL(obj)
          if isempty(obj.FigureURL) && ~isempty(obj.Figure)
              % Call drawnow.startUpdate to force uifigure to create its controller,
              % thereby resulting a valid figure URL.
              %
              % Note: Calling a full drawnow will cause a hang in the case of
              %       Web Apps since view creation is not tied to controller
              %       creation.
              matlab.graphics.internal.drawnow.startUpdate;
              
              obj.FigureURL = matlab.ui.internal.FigureServices.getFigureURL(obj.Figure);
          end
          
          URL = obj.FigureURL;
      end
   end
end
