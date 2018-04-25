classdef (Sealed) PublishableData < event.EventData
    % This class is undocumented and may change in a future release.    
    %   Copyright 2016 The MathWorks, Inc.
    
   properties (SetAccess = immutable)
      Channel
      CustomData
   end
   
   methods
       function pData = PublishableData(transmittingChannel, customData)
           pData.Channel     = string(transmittingChannel);
           pData.CustomData  = customData;
       end
   end
end