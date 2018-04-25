classdef ProposedDTChangeHandler < handle
 % PROPOSEDTCHANGEHANDLER Handles changing the proposed data type from the
 % client and update the client after the backend is changed
 
 % Copyright 2016 The MathWorks, Inc.
    
   properties (Access = private)
      Listener;
      Result;
   end
    
   methods
       function this = ProposedDTChangeHandler(result)
           if ~isa(result, 'fxptds.AbstractResult')
               [msg, id] = fxptui.message('incorrectInputType','fxptds.AbstractResult',class(result));
               throw(MException(id, msg));
           end
          this.Listener = addlistener(result, 'UpdatedResultsOnProposedOrApplyChange', @(s, e)this.updateProposeresults); 
          this.Result = result;
       end
       
       function processChange(this, clientData)
           this.Result.batchSetProposedDT(clientData.newValue);
       end
   end
   
   methods (Access = private)
       function updateProposeresults(this)
           delete(this.Listener);
           this.Listener = [];
           fptInstance = fxptui.FixedPointTool.getExistingInstance;
           if ~isempty(fptInstance)
				%find all results in the same group based on this result
				groupResults = fxptds.Utils.getGroupResults(this.Result); 
               fptInstance.getDataController.updateOnProposedDTChange([groupResults{:}]);
				% update result info
               fptInstance.getResultInfoController.publishDataForResult(this.Result);
               fptInstance.getExternalViewer.proposedTypeAnnotated(this.Result);
           end
           % De-associate listeners and results after the processing is
           % done.
           this.Result = [];           
       end
   end
end
