classdef (ConstructOnLoad) SelectionEventData < event.EventData

    % Copyright 2017 The MathWorks, Inc.

    properties
       StudyIndex
       SeriesIndex
   end
   
   methods
      function data = SelectionEventData(study, series)
         data.StudyIndex = study;
         data.SeriesIndex = series;
      end
   end
end