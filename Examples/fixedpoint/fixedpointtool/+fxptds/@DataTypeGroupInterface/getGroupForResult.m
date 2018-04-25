function dataTypeGroup = getGroupForResult(this, result)
   % GETGROUPFORRESULT this function grants access to the reverse look up
   % infrastructure of the interface. This API accepts a result and returns
   % the group that the result belongs to. In a normal workflow a result
   % will always belong to a group, in case that the reverse look up does
   % not find the registered group, an error will be thrown. 
   
   % Copyright 2016 The MathWorks, Inc.
   
   % if the result is registered in the look up, return the group
   if this.reverseResultLookUp.isKey(result.getUniqueIdentifier.UniqueKey)
       dataTypeGroup = ...
           this.reverseResultLookUp(result.getUniqueIdentifier.UniqueKey);
   else % otherwise, error out 
       DAStudio.error('SimulinkFixedPoint:autoscaling:unregisteredResult');
   end
   
   
end