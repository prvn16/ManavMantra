function addEmbeddedRunName(this, embeddedRunName)
   % ADDEMBEDDEDRUNNAME this function add a run name to the catalog of run 
   % names marked as embedded
   
   % Copyright 2017 The MathWorks, Inc.
   
   if ~any(ismember(this.EmbeddedRunNames, embeddedRunName))
       this.EmbeddedRunNames{end+1} = embeddedRunName;
   end
end