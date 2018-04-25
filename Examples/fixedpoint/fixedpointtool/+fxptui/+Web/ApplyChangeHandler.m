classdef ApplyChangeHandler < handle
 % APPLYCHANGEHANDLER Handles changing the proposed data type from the
 % client and update the client after the backend is changed
 
 % Copyright 2016 The MathWorks, Inc.
    
   properties (Access = private)
      Listener;
      Result;
      CollectedResults = [];
   end
    
   methods
       function this = ApplyChangeHandler(result)
           if ~isa(result, 'fxptds.AbstractResult')
               [msg, id] = fxptui.message('incorrectInputType','fxptds.AbstractResult',class(result));
               throw(MException(id, msg));
           end
          this.Listener = addlistener(result, 'UpdatedResultsOnProposedOrApplyChange', @(s, e)this.updateApplyResults);
          this.Result = result;
       end
       
       function processChange(this, clientData)
           this.Result.batchSetAccept(clientData.newValue);
       end
   end
   
   methods (Access = private)             
       function  updateApplyResults(this)
           fptInstance = fxptui.FixedPointTool.getExistingInstance;
           % Clear the listeners.
           for i = 1:numel(this.Listener)
               delete(this.Listener(i));
           end
           this.Listener = [];                     
           fptInstance.getDataController.updateData('append', this.Result.getRunName);
           % De-associate listeners and results after the processing is
           % done.
           this.Result = [];
       end
   end
end
