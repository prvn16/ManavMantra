function removeEmbeddedRunName(this, embeddedRunName)
   % REMOVEEMBEDDEDRUNNAME this function removes a run name from the 
   % catalog of run names marked as embedded
   
   % Copyright 2017 The MathWorks, Inc.
   
   indices = ismember(this.EmbeddedRunNames, embeddedRunName);
   if any(indices)
       this.EmbeddedRunNames(indices) = '';
   end
   
end