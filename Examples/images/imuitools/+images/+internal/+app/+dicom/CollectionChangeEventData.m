classdef (ConstructOnLoad) CollectionChangeEventData < event.EventData

    % Copyright 2017 The MathWorks, Inc.
    
   properties
       StudyDetails
       SeriesDetails
   end
   
   methods
      function data = CollectionChangeEventData(StudyDetails_, SeriesDetails_)
         data.StudyDetails = StudyDetails_;
         data.SeriesDetails = SeriesDetails_;
      end
   end
end