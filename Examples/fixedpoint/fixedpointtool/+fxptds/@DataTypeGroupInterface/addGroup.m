function addGroup(this, dataTypeGroup)
   % ADDGROUP this function provides an API for the FPTRun to add a new 
   % data type group in the data set. At the time of registration of a
   % group in the data set the reverse look up map is also populated so
   % that a mapping between results (composite element) and grous (parent 
   % element).
   
   % Copyright 2016 The MathWorks, Inc.
   
   % add the group to the internal collection of groups if it is not
   % already registered
   if ~this.dataTypeGroups.isKey(int2str(dataTypeGroup.id))
       % add the group to the map using the id
       % NOTE: there is an assumption that the ID needs to be unique, this
       % is a limitation here to use an ID since MATLAB containers cannot
       % have objects as keys
       this.dataTypeGroups(int2str(dataTypeGroup.id)) = dataTypeGroup;
       
       % register the group's elements in the reverse look up map
       this.registerGroupInLookUpMap(dataTypeGroup);
   end
   
end