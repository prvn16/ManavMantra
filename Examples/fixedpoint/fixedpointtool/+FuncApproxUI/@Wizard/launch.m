function launch(debug)
    % LAUNCH Launch the Lookup Table wizard.
    
    % Copyright 2017 The MathWorks, Inc.
    
    if nargin < 1
        debug = false;
    end    
    lutInstance = FuncApproxUI.Wizard.getExistingInstance;       
    if debug
        debugPort = matlab.internal.getOpenPort;
        lutInstance.open(debugPort);
    else
        lutInstance.open;
    end
end
