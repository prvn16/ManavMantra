function clear(this)
   % CLEAR this function clears the data in the interface.
   
   % Copyright 2016 The MathWorks, Inc.
   
   % clear the reverse look up map 
   this.reverseResultLookUp.remove(this.reverseResultLookUp.keys);
   
   % clear the registered data type groups
   this.dataTypeGroups.remove(this.dataTypeGroups.keys);
   
   % clear the registered edges
   this.edges.remove(this.edges.keys);
   
   % clear the connectivity graph
   this.connectivityGraph = '';
   this.connectivityGraph = graph();
   
end