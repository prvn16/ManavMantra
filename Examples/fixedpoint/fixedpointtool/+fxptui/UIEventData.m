classdef UIEventData < event.EventData
% UIEventData Class to package the data that needs to be sent to the
% listeners

% Copyright 2015 The MathWorks, Inc
    
   properties (SetAccess = private, GetAccess = private)
      Data
   end
   methods
      function this = UIEventData(data)
         this.Data = data;
      end
      
      function data = getData(this)
          data = this.Data;
      end 
   end
end
