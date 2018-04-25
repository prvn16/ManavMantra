function initializeResultHandler(this, res)
%% INITRESULTHANDLER function intiializes ResultHandler instance of FPTEventHandler 
% based on the type of the result

%   Copyright 2016 The MathWorks, Inc.

    % Factory method to switch between MLFB or generic result handlers
    if isa(res, 'fxptds.MATLABVariableResult')
        this.ResultHandler = fxptds.ResultHandler.MLFBResultHandlerFactory();
        this.isMLFBHandler = true;
    else
         this.ResultHandler = fxptds.ResultHandler.GenericResultHandlerFactory();
         this.isMLFBHandler = false;
    end
end