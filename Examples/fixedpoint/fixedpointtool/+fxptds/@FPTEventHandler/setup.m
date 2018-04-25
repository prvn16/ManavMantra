function setup(this, res)
%% SETUP function initializes FPTEventHandler with appropriate event handlers

%   Copyright 2016 The MathWorks, Inc.

    addlistener(res, 'SetAccept', @this.setAcceptHandler);
    addlistener(res, 'SetProposedDT', @this.setProposedDTHandler);    

    initializeResultHandler(this, res);
end
