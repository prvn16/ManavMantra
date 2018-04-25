function deleteRun(this, runName)
   % DELETERUN this function finds the run object associated with the run 
   % name in the dataset and deletes it 
   % Copyright 2016-2017 The MathWorks, Inc.
   
   % get the run object using the run name
   runObj = this.getRun(runName);
   
   % clear the run object (this function call will delete the object and
   % invalidate it)
   runObj.clearResults();
   
   % clear the run name from the run name maps of the dataset
   this.cleanupForRunDeletion({runName});
   if strcmpi(this.LastModifiedRun, runName)
       this.LastModifiedRun = '';
   end
end