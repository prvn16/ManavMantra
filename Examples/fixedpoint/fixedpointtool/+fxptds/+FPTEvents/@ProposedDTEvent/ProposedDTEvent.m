classdef (ConstructOnLoad) ProposedDTEvent < event.EventData
%% PROPOSEDDTEVENT EventData class
% Used to capture "ProposedDT" field change event from FPT GUI

%   Copyright 2016 The MathWorks, Inc.

   properties
      ProposedDTValue = '';
   end
   methods
      function eventData = ProposedDTEvent(value)
         eventData.ProposedDTValue = value;
      end
   end
end