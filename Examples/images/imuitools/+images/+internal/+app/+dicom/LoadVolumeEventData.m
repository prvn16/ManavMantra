% Copyright 2017 The MathWorks, Inc.

classdef (ConstructOnLoad) LoadVolumeEventData < event.EventData
   properties
        Volume
        SpatialDetails
        SliceDim
        Colormap
   end
   
   methods
      function data = LoadVolumeEventData(V, spatial, dim, map)
         data.Volume = V;
         data.SpatialDetails = spatial;
         data.SliceDim = dim;
         data.Colormap = map;
      end
   end
end