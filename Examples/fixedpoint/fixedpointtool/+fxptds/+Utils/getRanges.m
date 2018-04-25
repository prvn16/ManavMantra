function ranges = getRanges(result)
%% GETRANGES function collects all ranges from result object returns it as a struct

%   Copyright 2016-2017 The MathWorks, Inc.

   ranges = struct('Design', [], 'Derived', [], 'Sim', []);
   ranges.Design = [result.DesignMin, result.DesignMax];
   ranges.Derived = [result.DerivedMin, result.DerivedMax];
   if isempty(result.SimMin) && isempty(result.SimMax)
       rawData = result.getTimeseriesData();
       ranges.Sim = fxptds.Range(fxptds.RangeType.Simulation, min(rawData), max(rawData));
   else
       ranges.Sim =fxptds.Range(fxptds.RangeType.Simulation, result.SimMin, result.SimMax);
   end
end