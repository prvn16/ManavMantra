function clearHistogramsForDeletedRun(this, clientData)
%% CLEARHISTOGRAMFORDELETEDRUN function clears histograms for a given deleted run
% in Visualizer Client App 

%   Copyright 2016 The MathWorks, Inc.

   message.publish(this.PublishClearHistogramsChannel, clientData);
     
   % Update data cache and channel information
   this.Data = clientData;
   this.LastUsedChannel = this.PublishClearHistogramsChannel;
end