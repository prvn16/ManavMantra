classdef Root < handle & matlab.mixin.Heterogeneous    
    %Helper class for heterogeneous tree nodes
  methods(Sealed)
      % Methods sealed so that they work on heterogeneous arrays
   function ret = eq(obj,obj1)
      ret = eq@handle(obj,obj1);
   end
end
end

