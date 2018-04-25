classdef FPTEventHandler < handle
%% FPTEventHandler class that handles all GUI dialog invoking events
% for all results

%   Copyright 2016 The MathWorks, Inc.

  % All Events are triggered by fxptds.AbstractResult
   events
       SetAccept
       SetAcceptForMLFB
       SetAcceptForGroup
       SetProposedDTForGroup
   end
   properties    
       % GUIHandler interface is the gateway to all FPT GUI calls
       GUIHandler;
       
       % ResultHandler class handles all special handling of results (with
       % and without groups) for Accept and ProposedDT properties
       % ResultHandler is a concrete implementation created out of factory
       % method (initResultHandler) depending upon on the type of result
       % on which the handlers are called.
       ResultHandler
       
       % logical flag to check if its a MLFB Handler 
       isMLFBHandler = false;
   end
   methods
      function this = FPTEventHandler(res)
           % initialize GUIHandler
           this.GUIHandler = fxptds.FPTEventHandler.getGUIHandler;
           
           % setup handlers on the events and result handler
           this.setup(res);   
      end 
   end
   methods(Hidden)
      setup(this, res);
      
      % factory method to initialize result handler based on the type of
      % result
      initializeResultHandler(this, res);
      
      % Method to update result handler with the context information of the
      % top model on which Accept / ProposedDT is changed
      updateResultHandler(this, result);
      
      % listener for setAccept event
      setAcceptHandler(this, eventSrc, eventData);
      
      % listener for setProposedDT event
      setProposedDTHandler(this, eventSrc, eventData);
   end
   
   methods (Static)
       % method to initialize appropriate GUIHandler based on FPTWeb
       % feature 
       guiHandler = getGUIHandler();
   end
  

end

% LocalWords:  FPT
