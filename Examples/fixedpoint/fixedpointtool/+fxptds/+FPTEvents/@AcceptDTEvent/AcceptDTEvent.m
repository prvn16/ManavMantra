classdef (ConstructOnLoad) AcceptDTEvent < event.EventData
%% ACCEPTDTEVENT EventData class
% Used to capture "Accept" field change event from FPT GUI

%   Copyright 2016 The MathWorks, Inc.

   properties
      AcceptDTValue = 0;
   end
   methods
      function eventData = AcceptDTEvent(value)
         eventData.AcceptDTValue = value;
      end
   end
end