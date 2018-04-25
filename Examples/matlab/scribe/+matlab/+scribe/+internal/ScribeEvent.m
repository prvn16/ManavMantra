classdef (ConstructOnLoad) ScribeEvent < event.EventData & matlab.mixin.SetGet
%SCRIBEEVENT Data for a scribe event

% Copyright 2014-2017 The MathWorks, Inc.

   properties
      Figure;
      ObjectsCreated;
      SelectedObjects;
   end
end
